/*
 * Generated by Bluespec Compiler, version 2017.07.A (build 1da80f1, 2017-07-21)
 * 
 * On Sun Nov 10 19:16:48 EST 2019
 * 
 */
#include "bluesim_primitives.h"
#include "model_mkTest.h"

#include <cstdlib>
#include <time.h>
#include "bluesim_kernel_api.h"
#include "bs_vcd.h"
#include "bs_reset.h"


/* Constructor */
MODEL_mkTest::MODEL_mkTest()
{
  mkTest_instance = NULL;
}

/* Function for creating a new model */
void * new_MODEL_mkTest()
{
  MODEL_mkTest *model = new MODEL_mkTest();
  return (void *)(model);
}

/* Schedule functions */

static void schedule_posedge_CLK(tSimStateHdl simHdl, void *instance_ptr)
       {
	 MOD_mkTest &INST_top = *((MOD_mkTest *)(instance_ptr));
	 tUInt8 DEF_INST_top_DEF_svsp_compCounter_13_ULT_3___d514;
	 tUInt8 DEF_INST_top_DEF_svsp_xs_i_notFull__79_AND_svsp_ys_i_notFull__80___d581;
	 tUInt8 DEF_INST_top_DEF_svsp_realDistances_i_notEmpty____d592;
	 tUInt8 DEF_INST_top_DEF_svsp_xs_i_notEmpty____d482;
	 tUInt8 DEF_INST_top_DEF_svsp_ys_i_notEmpty____d483;
	 INST_top.DEF_x__h78738 = INST_top.INST_check.METH_read();
	 DEF_INST_top_DEF_svsp_realDistances_i_notEmpty____d592 = INST_top.INST_svsp_realDistances.METH_i_notEmpty();
	 INST_top.DEF_CAN_FIRE_RL_c0 = DEF_INST_top_DEF_svsp_realDistances_i_notEmpty____d592 && (INST_top.DEF_x__h78738) == (tUInt8)0u;
	 INST_top.DEF_WILL_FIRE_RL_c0 = INST_top.DEF_CAN_FIRE_RL_c0;
	 INST_top.DEF_CAN_FIRE_RL_c1 = DEF_INST_top_DEF_svsp_realDistances_i_notEmpty____d592 && (INST_top.DEF_x__h78738) == (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_c1 = INST_top.DEF_CAN_FIRE_RL_c1;
	 INST_top.DEF_CAN_FIRE_RL_c2 = DEF_INST_top_DEF_svsp_realDistances_i_notEmpty____d592 && (INST_top.DEF_x__h78738) == (tUInt8)2u;
	 INST_top.DEF_WILL_FIRE_RL_c2 = INST_top.DEF_CAN_FIRE_RL_c2;
	 INST_top.DEF_x__h78733 = INST_top.INST_feed.METH_read();
	 DEF_INST_top_DEF_svsp_xs_i_notFull__79_AND_svsp_ys_i_notFull__80___d581 = INST_top.INST_svsp_xs.METH_i_notFull() && INST_top.INST_svsp_ys.METH_i_notFull();
	 INST_top.DEF_CAN_FIRE_RL_f0 = DEF_INST_top_DEF_svsp_xs_i_notFull__79_AND_svsp_ys_i_notFull__80___d581 && (INST_top.DEF_x__h78733) == (tUInt8)0u;
	 INST_top.DEF_WILL_FIRE_RL_f0 = INST_top.DEF_CAN_FIRE_RL_f0;
	 INST_top.DEF_CAN_FIRE_RL_f1 = DEF_INST_top_DEF_svsp_xs_i_notFull__79_AND_svsp_ys_i_notFull__80___d581 && (INST_top.DEF_x__h78733) == (tUInt8)1u;
	 INST_top.DEF_WILL_FIRE_RL_f1 = INST_top.DEF_CAN_FIRE_RL_f1;
	 INST_top.DEF_CAN_FIRE_RL_finish = (INST_top.DEF_x__h78733) == (tUInt8)3u && (INST_top.DEF_x__h78738) == (tUInt8)3u;
	 INST_top.DEF_WILL_FIRE_RL_finish = INST_top.DEF_CAN_FIRE_RL_finish;
	 INST_top.DEF_CAN_FIRE_RL_f2 = DEF_INST_top_DEF_svsp_xs_i_notFull__79_AND_svsp_ys_i_notFull__80___d581 && (INST_top.DEF_x__h78733) == (tUInt8)2u;
	 INST_top.DEF_WILL_FIRE_RL_f2 = INST_top.DEF_CAN_FIRE_RL_f2;
	 INST_top.DEF_svsp_compCounter__h74868 = INST_top.INST_svsp_compCounter.METH_read();
	 DEF_INST_top_DEF_svsp_ys_i_notEmpty____d483 = INST_top.INST_svsp_ys.METH_i_notEmpty();
	 DEF_INST_top_DEF_svsp_xs_i_notEmpty____d482 = INST_top.INST_svsp_xs.METH_i_notEmpty();
	 INST_top.DEF_CAN_FIRE_RL_svsp_computeRealWorldDistanceRule = (DEF_INST_top_DEF_svsp_xs_i_notEmpty____d482 && (DEF_INST_top_DEF_svsp_ys_i_notEmpty____d483 && INST_top.INST_svsp_realDistances.METH_i_notFull())) && (INST_top.DEF_svsp_compCounter__h74868) == (tUInt8)3u;
	 INST_top.DEF_WILL_FIRE_RL_svsp_computeRealWorldDistanceRule = INST_top.DEF_CAN_FIRE_RL_svsp_computeRealWorldDistanceRule;
	 INST_top.DEF_svsp_referenceBlockStored__h38972 = INST_top.INST_svsp_referenceBlockStored.METH_read();
	 DEF_INST_top_DEF_svsp_compCounter_13_ULT_3___d514 = (INST_top.DEF_svsp_compCounter__h74868) < (tUInt8)3u;
	 INST_top.DEF_CAN_FIRE_RL_svsp_computeScoreRule = (INST_top.INST_svsp_loadCompBlock_blocks.METH_i_notEmpty() && (INST_top.INST_svsp_cs_refBlocks.METH_i_notFull() && (INST_top.INST_svsp_cs_compBlocks.METH_i_notFull() && (INST_top.DEF_svsp_referenceBlockStored__h38972 || INST_top.INST_svsp_loadRefBlock_blocks.METH_i_notEmpty())))) && DEF_INST_top_DEF_svsp_compCounter_13_ULT_3___d514;
	 INST_top.DEF_WILL_FIRE_RL_svsp_computeScoreRule = INST_top.DEF_CAN_FIRE_RL_svsp_computeScoreRule;
	 INST_top.DEF_CAN_FIRE_RL_svsp_cs_compute = INST_top.INST_svsp_cs_refBlocks.METH_i_notEmpty() && (INST_top.INST_svsp_cs_compBlocks.METH_i_notEmpty() && INST_top.INST_svsp_cs_scores.METH_i_notFull());
	 INST_top.DEF_WILL_FIRE_RL_svsp_cs_compute = INST_top.DEF_CAN_FIRE_RL_svsp_cs_compute;
	 INST_top.DEF_CAN_FIRE_RL_svsp_loadCompBlock_compute = INST_top.INST_svsp_loadCompBlock_xs.METH_i_notEmpty() && (INST_top.INST_svsp_loadCompBlock_ys.METH_i_notEmpty() && INST_top.INST_svsp_loadCompBlock_blocks.METH_i_notFull());
	 INST_top.DEF_WILL_FIRE_RL_svsp_loadCompBlock_compute = INST_top.DEF_CAN_FIRE_RL_svsp_loadCompBlock_compute;
	 INST_top.DEF_CAN_FIRE_RL_svsp_loadRefBlock_compute = INST_top.INST_svsp_loadRefBlock_xs.METH_i_notEmpty() && (INST_top.INST_svsp_loadRefBlock_ys.METH_i_notEmpty() && INST_top.INST_svsp_loadRefBlock_blocks.METH_i_notFull());
	 INST_top.DEF_WILL_FIRE_RL_svsp_loadRefBlock_compute = INST_top.DEF_CAN_FIRE_RL_svsp_loadRefBlock_compute;
	 INST_top.DEF_CAN_FIRE_RL_svsp_updateScoreRule = INST_top.INST_svsp_cs_scores.METH_i_notEmpty() && DEF_INST_top_DEF_svsp_compCounter_13_ULT_3___d514;
	 INST_top.DEF_WILL_FIRE_RL_svsp_updateScoreRule = INST_top.DEF_CAN_FIRE_RL_svsp_updateScoreRule;
	 INST_top.DEF_b__h38645 = INST_top.INST_svsp_loadCounter.METH_read();
	 INST_top.DEF_svsp_referenceBlockLoaded__h38671 = INST_top.INST_svsp_referenceBlockLoaded.METH_read();
	 INST_top.DEF_CAN_FIRE_RL_svsp_retrieveBlock = (DEF_INST_top_DEF_svsp_xs_i_notEmpty____d482 && (DEF_INST_top_DEF_svsp_ys_i_notEmpty____d483 && (INST_top.INST_svsp_loadCompBlock_xs.METH_i_notFull() && (INST_top.INST_svsp_loadCompBlock_ys.METH_i_notFull() && (INST_top.DEF_svsp_referenceBlockLoaded__h38671 || (INST_top.INST_svsp_loadRefBlock_xs.METH_i_notFull() && INST_top.INST_svsp_loadRefBlock_ys.METH_i_notFull())))))) && (INST_top.DEF_b__h38645) < (tUInt8)3u;
	 INST_top.DEF_WILL_FIRE_RL_svsp_retrieveBlock = INST_top.DEF_CAN_FIRE_RL_svsp_retrieveBlock;
	 if (INST_top.DEF_WILL_FIRE_RL_f0)
	   INST_top.RL_f0();
	 if (INST_top.DEF_WILL_FIRE_RL_f1)
	   INST_top.RL_f1();
	 if (INST_top.DEF_WILL_FIRE_RL_f2)
	   INST_top.RL_f2();
	 if (INST_top.DEF_WILL_FIRE_RL_c0)
	   INST_top.RL_c0();
	 if (INST_top.DEF_WILL_FIRE_RL_c1)
	   INST_top.RL_c1();
	 if (INST_top.DEF_WILL_FIRE_RL_c2)
	   INST_top.RL_c2();
	 if (INST_top.DEF_WILL_FIRE_RL_finish)
	   INST_top.RL_finish();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_computeScoreRule)
	   INST_top.RL_svsp_computeScoreRule();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_cs_compute)
	   INST_top.RL_svsp_cs_compute();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_retrieveBlock)
	   INST_top.RL_svsp_retrieveBlock();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_computeRealWorldDistanceRule)
	   INST_top.RL_svsp_computeRealWorldDistanceRule();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_updateScoreRule)
	   INST_top.RL_svsp_updateScoreRule();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_loadRefBlock_compute)
	   INST_top.RL_svsp_loadRefBlock_compute();
	 if (INST_top.DEF_WILL_FIRE_RL_svsp_loadCompBlock_compute)
	   INST_top.RL_svsp_loadCompBlock_compute();
	 if (do_reset_ticks(simHdl))
	 {
	   INST_top.INST_svsp_realDistances.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_xs.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_ys.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadCounter.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_svsp_compCounter.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_svsp_referenceBlockLoaded.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_svsp_referenceBlockStored.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_svsp_loadRefBlock_xs.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadRefBlock_ys.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadRefBlock_blocks.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadCompBlock_xs.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadCompBlock_ys.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_loadCompBlock_blocks.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_cs_refBlocks.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_cs_compBlocks.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_cs_scores.rst_tick_clk((tUInt8)1u);
	   INST_top.INST_svsp_us_bestScore.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_svsp_us_bestDistance.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_passed.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_feed.rst_tick__clk__1((tUInt8)1u);
	   INST_top.INST_check.rst_tick__clk__1((tUInt8)1u);
	 }
       };

/* Model creation/destruction functions */

void MODEL_mkTest::create_model(tSimStateHdl simHdl, bool master)
{
  sim_hdl = simHdl;
  init_reset_request_counters(sim_hdl);
  mkTest_instance = new MOD_mkTest(sim_hdl, "top", NULL);
  bk_get_or_define_clock(sim_hdl, "CLK");
  if (master)
  {
    bk_alter_clock(sim_hdl, bk_get_clock_by_name(sim_hdl, "CLK"), CLK_LOW, false, 0llu, 5llu, 5llu);
    bk_use_default_reset(sim_hdl);
  }
  bk_set_clock_event_fn(sim_hdl,
			bk_get_clock_by_name(sim_hdl, "CLK"),
			schedule_posedge_CLK,
			NULL,
			(tEdgeDirection)(POSEDGE));
  (mkTest_instance->INST_svsp_realDistances.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_xs.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_ys.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadRefBlock_xs.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadRefBlock_ys.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadRefBlock_blocks.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadCompBlock_xs.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadCompBlock_ys.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_loadCompBlock_blocks.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_cs_refBlocks.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_cs_compBlocks.set_clk_0)("CLK");
  (mkTest_instance->INST_svsp_cs_scores.set_clk_0)("CLK");
  (mkTest_instance->set_clk_0)("CLK");
}
void MODEL_mkTest::destroy_model()
{
  delete mkTest_instance;
  mkTest_instance = NULL;
}
void MODEL_mkTest::reset_model(bool asserted)
{
  (mkTest_instance->reset_RST_N)(asserted ? (tUInt8)0u : (tUInt8)1u);
}
void * MODEL_mkTest::get_instance()
{
  return mkTest_instance;
}

/* Fill in version numbers */
void MODEL_mkTest::get_version(unsigned int *year,
			       unsigned int *month,
			       char const **annotation,
			       char const **build)
{
  *year = 2017u;
  *month = 7u;
  *annotation = "A";
  *build = "1da80f1";
}

/* Get the model creation time */
time_t MODEL_mkTest::get_creation_time()
{
  
  /* Mon Nov 11 00:16:48 UTC 2019 */
  return 1573431408llu;
}

/* Control run-time licensing */
tUInt64 MODEL_mkTest::skip_license_check()
{
  return 0llu;
}

/* State dumping function */
void MODEL_mkTest::dump_state()
{
  (mkTest_instance->dump_state)(0u);
}

/* VCD dumping functions */
MOD_mkTest & mkTest_backing(tSimStateHdl simHdl)
{
  static MOD_mkTest *instance = NULL;
  if (instance == NULL)
  {
    vcd_set_backing_instance(simHdl, true);
    instance = new MOD_mkTest(simHdl, "top", NULL);
    vcd_set_backing_instance(simHdl, false);
  }
  return *instance;
}
void MODEL_mkTest::dump_VCD_defs()
{
  (mkTest_instance->dump_VCD_defs)(vcd_depth(sim_hdl));
}
void MODEL_mkTest::dump_VCD(tVCDDumpType dt)
{
  (mkTest_instance->dump_VCD)(dt, vcd_depth(sim_hdl), mkTest_backing(sim_hdl));
}