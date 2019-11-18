// This file tests the implementation of the ComputeDistance block

import StereoVisionMultiplePoints::*;
import Types::*;
import FixedPoint::*;
import FShow::*;
import Vector::*;

module mkTest();

	StereoVisionMultiplePoints svmp <- mkStereoVisionMultiplePoints();
	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(Vector#(N, UInt#(PB)) xs, Vector#(N, UInt#(PB)) ys);
		action
			feed <= feed + 1;
			svmp.putImagePoints(xs, ys);
		endaction
	endfunction

	function Action docheck(Vector#(N, FixedPoint#(FPBI, FPBF)) expDist);
		action
			let compDistance <- svmp.getDistances();
			for (Integer i = 0; i < valueOf(N); i = i + 1) begin
				if (compDistance[i] != expDist[i]) begin
					$display("Wanted: ", fshow(expDist[i]));
					$display("Got: ", fshow(compDistance[i]));
				end
			end
			passed <= False;
			check <= check+1;
		endaction
	endfunction

    UInt#(PB) x1 = 10;
    UInt#(PB) x2 = 10;
    UInt#(PB) x3 = 10;
	
    UInt#(PB) y1 = 0;
    UInt#(PB) y2 = 1;
    UInt#(PB) y3 = 2;

    Vector#(N, UInt#(PB)) xs = newVector();
    xs[0] = x1;
    xs[1] = x2;
    //xs[2] = x3;
    //xs[3] = x3;

    Vector#(N, UInt#(PB)) ys = newVector();
    ys[0] = y1;
    ys[1] = y2;
    //ys[2] = y3;
    //ys[3] = y3;

    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.45063;
    FixedPoint#(FPBI, FPBF) to3 = 6.73925;

    Vector#(N, FixedPoint#(FPBI, FPBF)) tos = newVector();
    tos[0] = to1;
    tos[1] = to2;
    //tos[2] = to3;
    //tos[3] = to3;

    rule f0 (feed == 0); dofeed(xs, ys); endrule
    rule f1 (feed == 1); dofeed(xs, ys); endrule
    rule f2 (feed == 2); dofeed(xs, ys); endrule
    
    rule c0 (check == 0); docheck(tos); endrule
    rule c1 (check == 1); docheck(tos); endrule
    rule c2 (check == 2); docheck(tos); endrule


    rule finish (feed == 3 && check == 3);
        if (passed) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end
        $finish();
    endrule


endmodule
