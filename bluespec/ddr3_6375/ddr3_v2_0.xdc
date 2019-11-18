set connectal_main [get_clocks -of_objects [get_pins *ep7/clkgen_pll/CLKOUT1]]

create_clock -name ddr3_refclk -period 5 [get_pins host_pcieHostTop_sys_clk_200mhz_buf/O] 
create_generated_clock -name ddr3_usrclk -source [get_pins host_pcieHostTop_sys_clk_200mhz_buf/O] -multiply_by 5 -divide_by 5 [get_pins *ddr3_ctrl_200mhz/u_ddr3_v2_0/*ui_clk]

set_clock_groups -asynchronous -group $connectal_main -group {ddr3_usrclk}
set_clock_groups -asynchronous -group $connectal_main -group {ddr3_refclk}
