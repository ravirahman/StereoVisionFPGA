`include "ConnectalProjectConfig.bsv"
import FIFO::*;
import Vector::*;
import DefaultValue::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;
import FShow::*;

// Connectal
import Top_Pins::*;
import HostInterface::*;

// DRAM
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;

//constants
import Types::*;
import StereoVisionSinglePoint::*;
import ClientServer::*;
import GetPut::*;
import Pixel::*;
import XYPoint::*;
import UpdateScore::*;
import LoadBlocks::*;
import ComputeScore::*;
import ComputeDistance::*;

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

// interface used by software
interface MyDutRequest;
    method Action loadDRAM (Bit#(32) line_addr, DRAM_Line line_data);
    method Action readDRAM (Bit#(32) line_addr);
    method Action reset_dut;
endinterface

// interface used by hardware to send a message back to software
interface MyDutIndication;
    method Action returnOutput (DRAM_Line resp);
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
    MakeResetIfc my_rst <- mkReset(1, True, connectal_clk); // inherits parent's reset (hidden) and introduce extra reset method (OR condition)\
    rule clearResetting if (isResetting);
        resetCnt <= resetCnt + 1;
        if (resetCnt == 3) isResetting <= False;
    endrule

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

    /////////////////////////
    // Your design
    /////////////////////////

    StereoVisionSinglePoint#(IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) svsp <- mkStereoVisionSinglePoint(ddr3_user, real_world_cte);


    // DDR3_6375User definition in DDR3User.bsv
    // DDR3_LineReq definition in DDR3User.bsv
    //  see the rule / methods below to learn how to use 'ddr3_user' module

    // Send a message back to sofware whenever the response is ready
    rule indicationToSoftware;
        DDR3_LineRes d <- ddr3_user.response.get;
        DRAM_Line data = unpack(d.data_out);
        indication.returnOutput(data); 
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
    endinterface

    interface Top_Pins pins;
`ifndef SIMULATION
        interface DDR3_Pins_VC707_1GB pins_ddr3 =  ddr3_ctrl_200mhz.ddr3;
`endif
    endinterface
endmodule
