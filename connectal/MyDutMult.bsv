`include "ConnectalProjectConfig.bsv"
import FIFO::*;
import Vector::*;
import DefaultValue::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;
import FShow::*;
import Types::*;
import StereoVisionMultiplePoints::*;


// Connectal
import Top_Pins::*;
import HostInterface::*;

// DRAM
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;

// Connectal HW-SW can use a struct type
// However, the components must have a type of Bit#(n)
//  data7 corresponds to [511:448]
//  data0 corresponds to [31:0]
typedef struct{
    Bit#(64) data7;
    Bit#(64) data6;
    Bit#(64) data5;
    Bit#(64) data4;
    Bit#(64) data3;
    Bit#(64) data2;
    Bit#(64) data1;
    Bit#(64) data0;
} DRAM_Line deriving (Bits);


// The structs to talk to the StereoVisionMultiplePoint are defined
// in StereoVisionMultiplePoints.bsv

// Struct to request multiple (x,y) image points in parallel. The number of
// (x,y) points in parallel is equal to the number of StereoVisionSinglePoint
// modules we have in parallel 
typedef struct{

    Bit#(PB) y3;
    Bit#(PB) x3;
    Bit#(PB) y2;
    Bit#(PB) x2;
    Bit#(PB) y1;
    Bit#(PB) x1;
    Bit#(PB) y0;
    Bit#(PB) x0;
} Points_Ensemble deriving (Bits);


// Struct to get multiple real world distances back in parallel. The number of
// distance in parallel is equal to the number of StereoVisionSinglePoint
// modules we have in parallel 
typedef struct{
    Bit#(TAdd#(FPBI, FPBF)) dist3;
    Bit#(TAdd#(FPBI, FPBF)) dist2;
    Bit#(TAdd#(FPBI, FPBF)) dist1;
    Bit#(TAdd#(FPBI, FPBF)) dist0;
} Real_Points_Ensemble deriving (Bits);


// This interface contains all the methods (and subinterfaces if desired)
// that can be called from software (i.e, form the host processor)
// Bit#(n) is the only argument type for request methods
interface MyDutRequest;

    // This method will be used to load the images onto the DRAM
    method Action loadDRAM (Bit#(32) line_addr, DRAM_Line line_data);
    
    // This method sends the image points whose distance we want to compute
    method Action requestPoints (Points_Ensemble points);

    // If we want to reset the FPGA
    method Action reset_dut;

endinterface


// interface used by hardware to send a message back to software
// Again, only Bit#(n) is allowed as return type
interface MyDutIndication;
    // Gets the distance from the ensemble points 
    method Action returnOutput (Real_Points_Ensemble resp);
endinterface



// This is the actual interface that MyDUt will have. We are adding the interface with the
// pins for DRAM connection
interface MyDut;
    interface MyDutRequest request;
    interface Top_Pins pins;
endinterface



module mkMyDut#(HostInterface host, MyDutIndication indication) (MyDut); // HostInterface is for DDR clocks

    /////////////////////////
    // Soft reset generator
    /////////////////////////

    Reg#(Bool) isResetting <- mkReg(False);
    Reg#(Bit#(2)) resetCnt <- mkReg(0);
    Clock connectal_clk <- exposeCurrentClock;
    MakeResetIfc my_rst <- mkReset(1, True, connectal_clk); // inherits parent's reset (hidden) and introduce extra reset method (OR condition)
    rule clearResetting if (isResetting);
        resetCnt <= resetCnt + 1;
        if (resetCnt == 3) isResetting <= False;
    endrule

    /////////////////////////
    // Your design
    /////////////////////////

    StereoVisionMultiplePoints svmp <- mkStereoVisionMultiplePoint(reset_by my_rst.new_rst);

    /////////////////////////
    // DRAM instantitation: ddr3_user (Does not need to be reset, just overwrite new data)
    /////////////////////////

`ifdef SIMULATION // verilator or bluesim
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
`else // VC707
    Clock clk200 = host.tsys_clk_200mhz_buf;
    Reset ddr3ref_rst_n <- mkAsyncResetFromCR(4, clk200);
  
    // Instantiate a DDR controller (Xilinx VC 707)
    //  This module runs in a different clock domain - ddr_usr_clk 200 MHz
    //  so you cannot use this module's interface directly
    DDR3_Controller_VC707_1GB ddr3_ctrl_200mhz <- mkDDR3Controller_VC707_2_1(defaultValue, clk200, clocked_by clk200, reset_by ddr3ref_rst_n); 

    // Instead, you should use 'ddr3_user' (mkDDR3WrapperSync) which runs on connectal_main_clock
    //   this module internally uses clock synchronizer fifos to 
    //     communicate with ddr3_ctrl_200mhz module
    DDR3_6375User ddr3_user <- mkDDR3WrapperSync(ddr3_ctrl_200mhz.user);
`endif

    // DDR3_6375User definition in DDR3User.bsv
    // DDR3_LineReq definition in DDR3User.bsv
    //  see the rule / methods below to learn how to use 'ddr3_user' module

    
    /////////////////////////
    // Software-Hardware interaction methods
    /////////////////////////
    
    // Send a message back to sofware whenever the response is ready
    rule indicationToSoftware;
        let d <- svmp.getDistances();
        // d is a vector, convert it to the struct.
        let data = Real_Points_Ensemble{dist3: pack(d[3]), dist2: pack(d[2]), dist1:pack(d[1]), dist0:pack(d[0])};
        indication.returnOutput(data); 
    endrule

    // Interface used by software (MyDutRequest)
    interface MyDutRequest request;

        method Action loadDRAM (Bit#(32) line_addr, DRAM_Line line_data) if (!isResetting);
            // write request (no response)
            let req = DDR3_LineReq{ write: True, line_addr: truncate(line_addr), data_in: pack(line_data)};
            ddr3_user.request.put(req);
        endmethod

        method Action requestPoints (Points_Ensemble points) if (!isResetting);
            // Convert from the Points_Ensemble to the Vector
            Vector#(N, UInt#(PB)) x_vec = newVector;
            Vector#(N, UInt#(PB)) y_vec = newVector;
	    x_vec[0] = unpack(points.x0);
            x_vec[1] = unpack(points.x1);
	    x_vec[2] = unpack(points.x2);
            x_vec[3] = unpack(points.x3);
	    y_vec[0] = unpack(points.y0);
            y_vec[1] = unpack(points.y1);
	    y_vec[2] = unpack(points.y2);
            y_vec[3] = unpack(points.y3);
            svmp.putImagePoints(x_vec, y_vec);
        endmethod

        method Action reset_dut;
            my_rst.assertReset; // assert my_rst.new_rst signal
            isResetting <= True;
        endmethod

    endinterface

    interface Top_Pins pins;
`ifndef SIMULATION
        interface DDR3_Pins_VC707_1GB pins_ddr3 =  ddr3_ctrl_200mhz.ddr3;
`endif
    endinterface
endmodule
