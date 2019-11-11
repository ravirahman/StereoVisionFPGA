// This file tests the implementation of the ComputeDistance block

import StereoVisionSinglePoint::*;
import Types::*;
import FixedPoint::*;
import FShow::*;

module mkTest();

	StereoVisionSinglePoint svsp <- mkStereoVisionSinglePoint();
	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(UInt#(PB) x, UInt#(PB) y);
		action
			feed <= feed + 1;
			$display("Test y: ", y);
			svsp.putImagePoint(x, y);
		endaction
	endfunction

	function Action docheck(FixedPoint#(FPBI, FPBF) expDist);
		action
			let compDistance <- svsp.getDistance();
			if (compDistance != expDist) begin
				$display("Wanted: ", fshow(expDist));
				$display("Got: ", fshow(compDistance));
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction

    UInt#(PB) x1 = 10;
    UInt#(PB) x2 = 10;
    UInt#(PB) x3 = 10;

    UInt#(PB) y1 = 0;
    UInt#(PB) y2 = 1;
    UInt#(PB) y3 = 2;
    
    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.45063;
    FixedPoint#(FPBI, FPBF) to3 = 6.73925;

    rule f0 (feed == 0); dofeed(x1, y1); endrule
    rule f1 (feed == 1); dofeed(x2, y2); endrule
    rule f2 (feed == 2); dofeed(x3, y3); endrule
    
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
