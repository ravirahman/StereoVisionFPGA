source "board.tcl"
source "$connectaldir/scripts/connectal-synth-ip.tcl"

variable myLocation [file normalize [info script]]
set curr_dir [file dirname $myLocation]

connectal_synth_ip mig_7series 4.1 ddr3_v2_0 [list CONFIG.XML_INPUT_FILE "$curr_dir/vc707-ddr3-800mhz.prj" CONFIG.RESET_BOARD_INTERFACE {Custom} CONFIG.MIG_DONT_TOUCH_PARAM {Custom} CONFIG.BOARD_MIG_PARAM {Custom}]
