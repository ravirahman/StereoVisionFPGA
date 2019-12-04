// This file tests the implementation of the ComputeDistance block

import ComputeDistance::*;
import Types::*;
import FixedPoint::*;
import FShow::*;
import ClientServer::*;
import GetPut::*;
import XYPointDistance::*;
import XYPoint::*;

module mkTest();

	ComputeDistance#(PB, SEARCHAREA, NPIXELS, FPBI, FPBF) cd <- mkComputeDistance(focal_dist, real_world_cte);

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(XYPointDistance#(PB) d);
		action
			feed <= feed + 1;
			cd.request.put(d);
		endaction
	endfunction

	function Action docheck(FixedPoint#(FPBI, FPBF) expDist);
		action
			let compDistance <- cd.response.get();
			if (abs(compDistance[2] - expDist) > 0.01) begin  // only comparing z for now
				$display("Wanted: ", fshow(expDist));
				$display("Got: ", fshow(compDistance[2]));
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction

	XYPointDistance#(PB) dist1 = mkXYPointDistance(mkXYPoint(0,0), 10);
	XYPointDistance#(PB) dist2 = mkXYPointDistance(mkXYPoint(0,0), 55);
	XYPointDistance#(PB) dist3 = mkXYPointDistance(mkXYPoint(0,0), 20);

    FixedPoint#(FPBI, FPBF) to1 = 13.4378509521484375;
    FixedPoint#(FPBI, FPBF) to2 = 2.4432373046875000;
    FixedPoint#(FPBI, FPBF) to3 = 6.7189178466796875;

    rule f0 (feed == 0); dofeed(dist1); endrule
    rule f1 (feed == 1); dofeed(dist2); endrule
    rule f2 (feed == 2); dofeed(dist3); endrule
    
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


endmodule
