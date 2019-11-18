`include "ConnectalProjectConfig.bsv"
import FIFO::*;
import Vector::*;
import DefaultValue::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;
import FShow::*;
import FixedPoint::*;
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


// Struct to request multiple (x,y) image points in parallel. The number of
// (x,y) points in parallel is equal to the number of StereoVisionSinglePoint
// modules we have in parallel 
typedef struct{
    Bit#(6) y1;
    Bit#(6) x1;
    Bit#(6) y0;
    Bit#(6) x0;
} Point_Coords deriving (Bits);


// Struct to get back multiple distances in parallel. The number of
// distances in parallel is equal to the number of StereoVisionSinglePoint
// modules we have in parallel 
typedef struct{
    Bit#(16) dist1;
    Bit#(16) dist0;
} Dist_List deriving (Bits);

// interface used by software
interface MyDutRequest;
    
    method Action readDRAM (Bit#(32) line_addr);
    
    // This method will be used to load the images onto the DRAM
    method Action loadDRAM (Bit#(32) line_addr, DRAM_Line line_data);
    
    // This method sends the image points whose distance we want to compute
    method Action requestPoints (Point_Coords point);
    
    // If we want to reset the FPGA
    method Action reset_dut;

endinterface

// interface used by hardware to send a message back to software
interface MyDutIndication;
    method Action returnOutputDDR (DRAM_Line resp);
    method Action returnOutputSV (Dist_List distances);
endinterface

// interface of the connectal wrapper (mkMyDut) of your design
//   pins added for DRAM connection
interface MyDut;
    interface MyDutRequest request;
    interface Top_Pins pins;
endinterface

module mkMyDut#(HostInterface host, MyDutIndication indication) (MyDut); // HostInterface for DDR clocks

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

    StereoVisionMultiplePoints svmp <- mkStereoVisionMultiplePoints();

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


    // SW and HW methods

    // Send a message back to sofware whenever the response is ready
    rule indicationToSoftwareDDR;
        let d <- ddr3_user.response.get;
        DRAM_Line data = unpack(d);
        indication.returnOutputDDR(data); 
    endrule

    rule indicationToSoftwareSV;
        let d <- svmp.getDistances();     
        Bit#(TAdd#(FPBI, FPBF)) dst0 = pack(d[0]);
        Bit#(TAdd#(FPBI, FPBF)) dst1 = pack(d[1]);
	let a = Dist_List{dist1: dst1, dist0: dst0};
        indication.returnOutputSV(a); 
    endrule
    
    // Interface used by software (MyDutRequest)
    interface MyDutRequest request;
        method Action loadDRAM (Bit#(32) line_addr, DRAM_Line line_data) if (!isResetting);
            // write request (no response)
            let req = DDR3_LineReq{ write: True, line_addr: truncate(line_addr), data_in: pack(line_data)};
            ddr3_user.request.put(req);
        endmethod
        
	method Action readDRAM (Bit#(32) line_addr) if (!isResetting);
            // read request
            let req = DDR3_LineReq{ write: False, line_addr: truncate(line_addr), data_in: 0};
            ddr3_user.request.put(req);
        endmethod
        
	method Action reset_dut;
            my_rst.assertReset; // assert my_rst.new_rst signal
            isResetting <= True;
        endmethod
        
	method Action requestPoints (Point_Coords point) if (!isResetting); 
            UInt#(PB) x1 = unpack(point.x1);
            UInt#(PB) y1 = unpack(point.y1);
            UInt#(PB) x0 = unpack(point.x0);
            UInt#(PB) y0 = unpack(point.y0);
  	    Vector#(N, UInt#(PB)) xs = newVector();
            Vector#(N, UInt#(PB)) ys = newVector();
	    xs[0] = x0;
	    xs[1] = x1;
	    ys[0] = y0;
	    ys[1] = y1;
	    svmp.putImagePoints(xs, ys);
        endmethod
    endinterface

    interface Top_Pins pins;
`ifndef SIMULATION
        interface DDR3_Pins_VC707_1GB pins_ddr3 =  ddr3_ctrl_200mhz.ddr3;
`endif
    endinterface
endmodule