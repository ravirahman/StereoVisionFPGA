// This file tests the implementation of the ComputeDistance block

import ComputeDistance::*;
import Types::*;
import FixedPoint::*;
import FShow::*;
import ClientServer::*;
import GetPut::*;

module mkTest();

	ComputeDistance#(PB, FPBI, FPBF) cd <- mkComputeDistance(real_world_cte);

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(UInt#(PB) d);
		action
			feed <= feed + 1;
			cd.request.put(d);
		endaction
	endfunction

	function Action docheck(FixedPoint#(FPBI, FPBF) expDist);
		action
			let compDistance <- cd.response.get();
			if (compDistance != expDist) begin
				$display("Wanted: ", fshow(expDist));
				$display("Got: ", fshow(compDistance));
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction

    UInt#(PB) dist1 = 10;
    UInt#(PB) dist2 = 55;
    UInt#(PB) dist3 = 20;

    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.4433593750;
    FixedPoint#(FPBI, FPBF) to3 = 6.7187500000;

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
