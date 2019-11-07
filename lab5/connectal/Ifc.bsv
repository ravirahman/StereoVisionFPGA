`include "ConnectalProjectConfig.bsv"
import DDR3Controller::*;

interface ConnectalProcIndication;
   method Action sendMessage(Bit#(18) mess);
   method Action wroteWord(Bit#(32) data);
endinterface
interface ConnectalProcRequest;
   method Action hostToCpu(Bit#(32) startpc);
   method Action softReset();
endinterface

interface ConnectalMemoryInitialization;
   method Action done();
   method Action request(Bit#(32) addr, Bit#(32) data);
endinterface

interface Top_Pins;
   `ifndef SIMULATION
   interface DDR3_Pins_VC707_1GB pins_ddr3;
   `endif
endinterface



