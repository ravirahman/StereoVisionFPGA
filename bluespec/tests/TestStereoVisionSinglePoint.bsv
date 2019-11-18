// This file tests the implementation of the ComputeDistance block
import StereoVisionSinglePoint::*;
import Types::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;
import FShow::*;
// DRAM
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;
import XYPoint::*;
import HostInterface::*;
import DDR3Controller::*;

interface Top_Pins;
   interface DDR3_Pins_VC707_1GB pins_ddr3;
endinterface

module mkTest();
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);

	StereoVisionSinglePoint#(IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) svsp <- mkStereoVisionSinglePoint(ddr3_user, real_world_cte);
	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(XYPoint#(PB) xy);
		action
			feed <= feed + 1;
            $display("Test y: ", xy.y);
			svsp.request.put(xy);
		endaction
	endfunction

	function Action docheck(FixedPoint#(FPBI, FPBF) expDist);
		action
			let compDistance <- svsp.response.get();
			if (compDistance != expDist) begin
				$display("Wanted: ", fshow(expDist));
				$display("Got: ", fshow(compDistance));
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction

    XYPoint#(PB) p1;
    p1.x = 10;
    p1.y = 0;

    XYPoint#(PB) p2;
    p2.x = 10;
    p2.y = 1;

    XYPoint#(PB) p3;
    p3.x = 10;
    p3.y = 2;
    
    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.45063;
    FixedPoint#(FPBI, FPBF) to3 = 6.73925;

    rule f0 (feed == 0); dofeed(p1); endrule
    rule f1 (feed == 1); dofeed(p2); endrule
    rule f2 (feed == 2); dofeed(p3); endrule
    
    rule c0 (check == 0); docheck(to1); endrule
    rule c1 (check == 1); docheck(to2); endrule
    rule c2 (check == 2); docheck(to3); endrule


    rule finish (feed == 3 && check == 3);
        if (passed) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end
        $finish();
    endrule

    interface Top_Pins pins;
        interface DDR3_Pins_VC707_1GB pins_ddr3 =  ddr3_ctrl_200mhz.ddr3;
    endinterface


endmodule
