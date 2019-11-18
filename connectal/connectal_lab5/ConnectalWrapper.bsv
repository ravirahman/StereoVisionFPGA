`include "ConnectalProjectConfig.bsv"

import ProcTypes::*;

`ifdef MULTICYCLE 
import MultiCycle::*;
`endif

`ifdef TWOSTAGEEHR
import TwoStageEhr::*;
`endif

`ifdef TWOSTAGEREDIR
import TwoStageRedir::*;
`endif

`ifdef TWOSTAGEBTB
import TwoStageBtb::*;
`endif

`ifdef THREESTAGE 
import ThreeStage::*;
`endif

`ifdef THREESTAGEBYPASS 
import ThreeStageBypass::*;
`endif


import Ifc::*;
import ProcTypes::*;
import Types::*;
import Ehr::*;
import MemTypes::*;
import GetPut::*;

// Connectal imports
import HostInterface::*;
import Clocks::*;
import Connectable::*;

// import Xilinx::*;

// DRAM imports
import DDR3Util::*;

import DDR3Common::*;
import DDR3Controller::*;
import DefaultValue::*;

import DDR3Sim::*;

interface ConnectalWrapper;
   interface ConnectalProcRequest connectProc;
   interface ConnectalMemoryInitialization initProc;
   interface Top_Pins pins;
endinterface

module mkConnectalWrapper#(HostInterface host, ConnectalProcIndication ind)(ConnectalWrapper);
   Reg#(Bool) ready <- mkReg(False);
   Reg#(Bool) isResetting <- mkReg(False);
   Reg#(Bit#(2)) resetCnt <- mkReg(0);
   Clock connectal_clk <- exposeCurrentClock;
   MakeResetIfc my_rst <- mkReset(1, True, connectal_clk); // inherits parent's reset (hidden) and introduce extra reset method (OR condition)
   rule clearResetting if (isResetting);
      resetCnt <= resetCnt + 1;
      if (resetCnt == 3) isResetting <= False;
   endrule
   
   Proc riscv_processor <- mkProc(reset_by my_rst.new_rst);
   
   let ddr3_client_delay <- mkDDR3ClienDelay(riscv_processor.ddr3client);   
   /////////////DDR3 stuff/////////////
   `ifdef SIMULATION
   let ddr3_ctrl_user <- mkDDR3Simulator;
   mkConnection(ddr3_client_delay, ddr3_ctrl_user);
   `else 
   Clock clk200 = host.tsys_clk_200mhz_buf;
   Reset ddr3ref_rst_n <- mkAsyncResetFromCR(4, clk200 );
   
   DDR3_Configure_1G ddr3_cfg = defaultValue;
   ddr3_cfg.reads_in_flight = 32;   // adjust as needed
   DDR3_Controller_VC707_1GB ddr3_ctrl <- mkDDR3Controller_VC707_2_1(ddr3_cfg, clk200, clocked_by clk200, reset_by ddr3ref_rst_n);
         
   Clock ddr3clk = ddr3_ctrl.user.clock;
   Reset ddr3rstn = ddr3_ctrl.user.reset_n;
   
   let ddr3_client_200mhz <- mkDDR3ClientSync(ddr3_client_delay, clockOf(ddr3_client_delay), resetOf(ddr3_client_delay), ddr3clk, ddr3rstn);
   mkConnection(ddr3_client_200mhz, ddr3_ctrl.user);
   `endif
   

   rule relayMessage;
	  let mess <- riscv_processor.cpuToHost();
      ind.sendMessage(pack(mess));	
   endrule
   interface ConnectalProcRequest connectProc;
      method Action hostToCpu(Bit#(32) startpc) if (!isResetting&&ready);
         $display("Received software req to start pc\n");
         $fflush(stdout);
	     riscv_processor.hostToCpu(unpack(startpc));
      endmethod
      method Action softReset();
         my_rst.assertReset; // assert my_rst.new_rst signal
         isResetting <= True;
         ready<=True;
      endmethod
   endinterface
   interface ConnectalMemoryInitialization initProc;
      method Action done() if (!isResetting&&ready);
		 $display("Done memory initialization");
		 riscv_processor.memInit.request.put(tagged InitDone);
	  endmethod
      method Action request(Bit#(32) addr, Bit#(32) data) if (!isResetting&&ready);
		 $display("Request %x %x",addr, data);
		 ind.wroteWord(0);
		 riscv_processor.memInit.request.put(tagged InitLoad (MemInitLoad {addr: addr, data: data}));
	  endmethod 
   endinterface
   
   interface Top_Pins pins;
      `ifndef SIMULATION
      interface DDR3_Pins_VC707_1GB pins_ddr3 = ddr3_ctrl.ddr3;
      `endif
   endinterface
endmodule
