/*
 * Generated by Bluespec Compiler, version 2017.07.A (build 1da80f1, 2017-07-21)
 * 
 * On Sat Nov 16 22:39:52 EST 2019
 * 
 */

/* Generation options: keep-fires */
#ifndef __mkMyDutIndicationOutputPipes_h__
#define __mkMyDutIndicationOutputPipes_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkMyDutIndicationOutputPipes module */
class MOD_mkMyDutIndicationOutputPipes : public Module {
 
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
  MOD_Reg<tUWide> INST_returnOutputDDR_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_returnOutputDDR_responseAdapter_count;
  MOD_Reg<tUInt8> INST_returnOutputDDR_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt32> INST_returnOutputDDR_responseAdapter_shift;
  MOD_Reg<tUInt32> INST_returnOutputSV_responseAdapter_bits;
  MOD_Reg<tUInt8> INST_returnOutputSV_responseAdapter_notEmptyReg;
  MOD_Reg<tUInt8> INST_returnOutputSV_responseAdapter_shift;
 
 /* Constructor */
 public:
  MOD_mkMyDutIndicationOutputPipes(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
  tUInt8 PORT_EN_portalIfc_indications_0_deq;
  tUInt8 PORT_EN_portalIfc_indications_1_deq;
  tUInt8 PORT_EN_methods_returnOutputDDR_enq;
  tUInt8 PORT_EN_methods_returnOutputSV_enq;
  tUInt32 PORT_portalIfc_messageSize_size_methodNumber;
  tUWide PORT_methods_returnOutputDDR_enq_v;
  tUInt32 PORT_methods_returnOutputSV_enq_v;
  tUInt32 PORT_portalIfc_intr_channel;
  tUInt8 PORT_portalIfc_intr_status;
  tUInt32 PORT_portalIfc_messageSize_size;
  tUInt8 PORT_RDY_portalIfc_messageSize_size;
  tUInt8 PORT_RDY_portalIfc_intr_status;
  tUInt8 PORT_RDY_portalIfc_intr_channel;
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
  tUInt8 PORT_RDY_methods_returnOutputDDR_enq;
  tUInt8 PORT_methods_returnOutputDDR_notFull;
  tUInt8 PORT_RDY_methods_returnOutputDDR_notFull;
  tUInt8 PORT_RDY_methods_returnOutputSV_enq;
  tUInt8 PORT_methods_returnOutputSV_notFull;
  tUInt8 PORT_RDY_methods_returnOutputSV_notFull;
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_CAN_FIRE_portalIfc_intr_channel;
  tUInt8 DEF_CAN_FIRE_portalIfc_intr_status;
  tUInt8 DEF_CAN_FIRE_portalIfc_messageSize_size;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_1_deq;
  tUInt8 DEF_WILL_FIRE_portalIfc_indications_0_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_1_first;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_notEmpty;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_deq;
  tUInt8 DEF_CAN_FIRE_portalIfc_indications_0_first;
  tUInt8 DEF_returnOutputSV_responseAdapter_notEmptyReg__h465;
  tUInt8 DEF_returnOutputDDR_responseAdapter_notEmptyReg__h366;
  tUInt8 DEF_WILL_FIRE_methods_returnOutputSV_enq;
  tUInt8 DEF_WILL_FIRE_methods_returnOutputDDR_enq;
  tUInt8 DEF_CAN_FIRE_methods_returnOutputSV_notFull;
  tUInt8 DEF_CAN_FIRE_methods_returnOutputSV_enq;
  tUInt8 DEF_NOT_returnOutputSV_responseAdapter_notEmptyReg___d4;
  tUInt8 DEF_CAN_FIRE_methods_returnOutputDDR_notFull;
  tUInt8 DEF_CAN_FIRE_methods_returnOutputDDR_enq;
  tUInt8 DEF_NOT_returnOutputDDR_responseAdapter_notEmptyReg___d2;
 
 /* Local definitions */
 private:
  tUWide DEF_x__h659;
  tUWide DEF_returnOutputDDR_responseAdapter_bits_BITS_479_TO_0___h771;
  tUWide DEF_x__h763;
 
 /* Rules */
 public:
 
 /* Methods */
 public:
  tUInt32 METH_portalIfc_messageSize_size(tUInt32 ARG_portalIfc_messageSize_size_methodNumber);
  tUInt8 METH_RDY_portalIfc_messageSize_size();
  void METH_methods_returnOutputDDR_enq(tUWide ARG_methods_returnOutputDDR_enq_v);
  tUInt8 METH_RDY_methods_returnOutputDDR_enq();
  tUInt8 METH_methods_returnOutputDDR_notFull();
  tUInt8 METH_RDY_methods_returnOutputDDR_notFull();
  void METH_methods_returnOutputSV_enq(tUInt32 ARG_methods_returnOutputSV_enq_v);
  tUInt8 METH_RDY_methods_returnOutputSV_enq();
  tUInt8 METH_methods_returnOutputSV_notFull();
  tUInt8 METH_RDY_methods_returnOutputSV_notFull();
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
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkMyDutIndicationOutputPipes &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkMyDutIndicationOutputPipes &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkMyDutIndicationOutputPipes &backing);
};

#endif /* ifndef __mkMyDutIndicationOutputPipes_h__ */