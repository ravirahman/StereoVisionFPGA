`include "ConnectalProjectConfig.bsv"
import DDR3Controller::*;

interface Top_Pins;
`ifndef SIMULATION
   interface DDR3_Pins_VC707_1GB pins_ddr3;
`endif
endinterface
