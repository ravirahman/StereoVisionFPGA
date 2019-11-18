/*
 * Generated by Bluespec Compiler, version 2017.07.A (build 1da80f1, 2017-07-21)
 * 
 * On Sat Nov 16 22:39:52 EST 2019
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkMemServerIndicationOutputPipes_h__
#define __mkMemServerIndicationOutputPipes_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkMemServerIndicationOutputPipes module */
class MOD_mkMemServerIndicationOutputPipes : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_Reg<tUInt64> INST_addrResponse_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_addrResponse_responseAdapter_count;
  MOD_Reg<tUInt8> INST_addrResponse_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt8> INST_addrResponse_responseAdapter_shift;
  MOD_Reg<tUWide> INST_error_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_error_responseAdapter_count;
  MOD_Reg<tUInt8> INST_error_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt32> INST_error_responseAdapter_shift;
  MOD_Reg<tUInt64> INST_reportMemoryTraffic_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_reportMemoryTraffic_responseAdapter_count;
  MOD_Reg<tUInt8> INST_reportMemoryTraffic_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt8> INST_reportMemoryTraffic_responseAdapter_shift;
  MOD_Reg<tUWide> INST_reportStateDbg_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_reportStateDbg_responseAdapter_count;
  MOD_Reg<tUInt8> INST_reportStateDbg_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt8> INST_reportStateDbg_responseAdapter_shift;
 
 /* Constructor */
 public:
  MOD_mkMemServerIndicationOutputPipes(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
  tUInt8 PORT_EN_methods_error_enq;
  tUInt8 PORT_EN_portalIfc_indications_0_deq;
  tUInt8 PORT_EN_portalIfc_indications_1_deq;
  tUInt8 PORT_EN_portalIfc_indications_2_deq;
  tUInt8 PORT_EN_portalIfc_indications_3_deq;
  tUInt8 PORT_EN_methods_addrResponse_enq;
  tUInt8 PORT_EN_methods_reportStateDbg_enq;
  tUInt8 PORT_EN_methods_reportMemoryTraffic_enq;
  tUInt32 PORT_portalIfc_messageSize_size_methodNumber;
  tUWide PORT_methods_error_enq_v;
  tUInt64 PORT_methods_addrResponse_enq_v;
  tUWide PORT_methods_reportStateDbg_enq_v;
  tUInt64 PORT_methods_reportMemoryTraffic_enq_v;
  tUInt32 PORT_portalIfc_intr_channel;
  tUInt8 PORT_portalIfc_intr_status;
  tUInt32 PORT_portalIfc_messageSize_size;
  tUInt8 PORT_RDY_portalIfc_messageSize_size;
  tUInt8 PORT_RDY_portalIfc_intr_status;
  tUInt8 PORT_RDY_portalIfc_intr_channel;
  tUInt8 PORT_RDY_methods_error_enq;
  tUInt8 PORT_methods_error_notFull;
  tUInt8 PORT_RDY_methods_error_notFull;
  tUInt32 PORT_portalIfc_indications_0_first;
  tUInt8 PORT_RDY_portalIfc_indications_0_first;
  tUInt8 PORT_RDY_portalIfc_indications_0_deq;
  tUInt8 PORT_portalIfc_indications_0_notEmpty;
  tUInt8 PORT_RDY_portalIfc_indications_0_notEmpty;
  tUInt32 PORT_portalIfc_indications_1_first;
  tUInt8 PORT_RDY_portalIfc_indications_1_first;
  tUInt8 PORT_RDY_portalIfc_indications_1_deq;
  tUInt8 PORT_portalIfc_indications_1_notEmpty;
  tUInt8 PORT_RDY_portalIfc_indications_1_notEmpty;
  tUInt32 PORT_portalIfc_indications_2_first;
  tUInt8 PORT_RDY_portalIfc_indications_2_first;
  tUInt8 PORT_RDY_portalIfc_indications_2_deq;
  tUInt8 PORT_portalIfc_indications_2_notEmpty;
  tUInt8 PORT_RDY_portalIfc_indications_2_notEmpty;
  tUInt32 PORT_portalIfc_indications_3_first;
  tUInt8 PORT_RDY_portalIfc_indications_3_first;
  tUInt8 PORT_RDY_portalIfc_indications_3_deq;
  tUInt8 PORT_portalIfc_indications_3_notEmpty;
  tUInt8 PORT_RDY_portalIfc_indications_3_notEmpty;
  tUInt8 PORT_RDY_methods_addrResponse_enq;
  tUInt8 PORT_methods_addrResponse_notFull;
  tUInt8 PORT_RDY_methods_addrResponse_notFull;
  tUInt8 PORT_RDY_methods_reportStateDbg_enq;
  tUInt8 PORT_methods_reportStateDbg_notFull;
  tUInt8 PORT_RDY_methods_reportStateDbg_notFull;
  tUInt8 PORT_RDY_methods_reportMemoryTraffic_enq;
  tUInt8 PORT_methods_reportMemoryTraffic_notFull;
  tUInt8 PORT_RDY_methods_reportMemoryTraffic_notFull;
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_CAN_FIRE_portalIfc_intr_channel;
  tUInt8 DEF_CAN_FIRE_portalIfc_intr_status;
  tUInt8 DEF_CAN_FIRE_portalIfc_messageSize_size;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_2_deq;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_1_deq;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_0_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_2_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_2_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_2_first;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_first;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_first;
  tUInt8 DEF_WILL_FIRE_methods_error_enq;
  tUInt8 DEF_CAN_FIRE_methods_error_notFull;
  tUInt8 DEF_CAN_FIRE_methods_error_enq;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_3_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_3_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_3_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_3_first;
  tUInt8 DEF_error_responseAdapter_notEmptyReg__h894;
  tUInt8 DEF_reportMemoryTraffic_responseAdapter_notEmptyReg__h846;
  tUInt8 DEF_reportStateDbg_responseAdapter_notEmptyReg__h774;
  tUInt8 DEF_addrResponse_responseAdapter_notEmptyReg__h723;
  tUInt8 DEF_WILL_FIRE_methods_reportMemoryTraffic_enq;
  tUInt8 DEF_WILL_FIRE_methods_reportStateDbg_enq;
  tUInt8 DEF_WILL_FIRE_methods_addrResponse_enq;
  tUInt8 DEF_NOT_error_responseAdapter_notEmptyReg___d8;
  tUInt8 DEF_CAN_FIRE_methods_reportMemoryTraffic_notFull;
  tUInt8 DEF_CAN_FIRE_methods_reportMemoryTraffic_enq;
  tUInt8 DEF_NOT_reportMemoryTraffic_responseAdapter_notEmp_ETC___d6;
  tUInt8 DEF_CAN_FIRE_methods_reportStateDbg_notFull;
  tUInt8 DEF_CAN_FIRE_methods_reportStateDbg_enq;
  tUInt8 DEF_NOT_reportStateDbg_responseAdapter_notEmptyReg___d4;
  tUInt8 DEF_CAN_FIRE_methods_addrResponse_notFull;
  tUInt8 DEF_CAN_FIRE_methods_addrResponse_enq;
  tUInt8 DEF_NOT_addrResponse_responseAdapter_notEmptyReg___d2;
 
 /* Local definitions */
 private:
  tUWide DEF_x__h1578;
  tUWide DEF_x__h1314;
  tUInt64 DEF_x__h1446;
  tUInt64 DEF_x__h1181;
  tUWide DEF_error_responseAdapter_bits_BITS_159_TO_0___h1689;
  tUWide DEF_reportStateDbg_responseAdapter_bits_BITS_95_TO_0___h1425;
  tUWide DEF_x__h1682;
  tUWide DEF_x__h1418;
 
 /* Rules */
 public:
 
 /* Methods */
 public:
  tUInt32 METH_portalIfc_messageSize_size(tUInt32 ARG_portalIfc_messageSize_size_methodNumber);
  tUInt8 METH_RDY_portalIfc_messageSize_size();
  void METH_methods_addrResponse_enq(tUInt64 ARG_methods_addrResponse_enq_v);
  tUInt8 METH_RDY_methods_addrResponse_enq();
  tUInt8 METH_methods_addrResponse_notFull();
  tUInt8 METH_RDY_methods_addrResponse_notFull();
  void METH_methods_reportStateDbg_enq(tUWide ARG_methods_reportStateDbg_enq_v);
  tUInt8 METH_RDY_methods_reportStateDbg_enq();
  tUInt8 METH_methods_reportStateDbg_notFull();
  tUInt8 METH_RDY_methods_reportStateDbg_notFull();
  void METH_methods_reportMemoryTraffic_enq(tUInt64 ARG_methods_reportMemoryTraffic_enq_v);
  tUInt8 METH_RDY_methods_reportMemoryTraffic_enq();
  tUInt8 METH_methods_reportMemoryTraffic_notFull();
  tUInt8 METH_RDY_methods_reportMemoryTraffic_notFull();
  void METH_methods_error_enq(tUWide ARG_methods_error_enq_v);
  tUInt8 METH_RDY_methods_error_enq();
  tUInt8 METH_methods_error_notFull();
  tUInt8 METH_RDY_methods_error_notFull();
  tUInt32 METH_portalIfc_indications_0_first();
  tUInt8 METH_RDY_portalIfc_indications_0_first();
  void METH_portalIfc_indications_0_deq();
  tUInt8 METH_RDY_portalIfc_indications_0_deq();
  tUInt8 METH_portalIfc_indications_0_notEmpty();
  tUInt8 METH_RDY_portalIfc_indications_0_notEmpty();
  tUInt32 METH_portalIfc_indications_1_first();
  tUInt8 METH_RDY_portalIfc_indications_1_first();
  void METH_portalIfc_indications_1_deq();
  tUInt8 METH_RDY_portalIfc_indications_1_deq();
  tUInt8 METH_portalIfc_indications_1_notEmpty();
  tUInt8 METH_RDY_portalIfc_indications_1_notEmpty();
  tUInt32 METH_portalIfc_indications_2_first();
  tUInt8 METH_RDY_portalIfc_indications_2_first();
  void METH_portalIfc_indications_2_deq();
  tUInt8 METH_RDY_portalIfc_indications_2_deq();
  tUInt8 METH_portalIfc_indications_2_notEmpty();
  tUInt8 METH_RDY_portalIfc_indications_2_notEmpty();
  tUInt32 METH_portalIfc_indications_3_first();
  tUInt8 METH_RDY_portalIfc_indications_3_first();
  void METH_portalIfc_indications_3_deq();
  tUInt8 METH_RDY_portalIfc_indications_3_deq();
  tUInt8 METH_portalIfc_indications_3_notEmpty();
  tUInt8 METH_RDY_portalIfc_indications_3_notEmpty();
  tUInt8 METH_portalIfc_intr_status();
  tUInt8 METH_RDY_portalIfc_intr_status();
  tUInt32 METH_portalIfc_intr_channel();
  tUInt8 METH_RDY_portalIfc_intr_channel();
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkMemServerIndicationOutputPipes &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkMemServerIndicationOutputPipes &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkMemServerIndicationOutputPipes &backing);
};

#endif /* ifndef __mkMemServerIndicationOutputPipes_h__ */
