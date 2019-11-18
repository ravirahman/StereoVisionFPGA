// This file tests the implementation of the ComputeScore block

import ComputeScore::*;
import Vector::*;
import ClientServer::*;
import GetPut::*;
import Types::*;
import Pixel::*;

typedef ScoreT#(NPIXELS, PD, PIXELWIDTH) MyScoreT;
typedef Vector#(TMul#(NPIXELS, NPIXELS), Pixel#(PD, PIXELWIDTH)) BlockT;

module mkTest();
	ComputeScore#(NPIXELS, PD, PIXELWIDTH) cs <- mkComputeScore();

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(BlockT a, BlockT b);
		action
            feed <= feed + 1;
            BlockPair#(NPIXELS, PD, PIXELWIDTH) bp;
            bp.refBlock = a;
            bp.compBlock = b;
			cs.request.put(bp);
		endaction
	endfunction

	function Action docheck(MyScoreT expScore);
		action
			let compScore <- cs.response.get();
			if (compScore != expScore) begin
				$display("Wanted: ", expScore);
				$display("Got: ", compScore);
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction


    BlockT ti1_a = replicate(replicate(0));
    BlockT ti1_b = replicate(replicate(0));
    ti1_a[0][0] = 10;
    ti1_a[1][0] = 250;
    ti1_b[0][0] = 5;
    ti1_b[1][0] = 100;

    MyScoreT to1 = 155;

    BlockT ti2_a = replicate(replicate(0));
    BlockT ti2_b = replicate(replicate(0));
    ti2_a[0][0] = 123;
    ti2_a[1][0] = 25;
    ti2_b[0][0] = 230;
    ti2_b[1][0] = 100;

    MyScoreT to2 = 182;

    
    BlockT ti3_a = replicate(replicate(0));
    BlockT ti3_b = replicate(replicate(0));
    ti3_a[0][0] = 255;
    ti3_a[1][0] = 255;
    ti3_b[0][0] = 0;
    ti3_b[1][0] = 0;

    MyScoreT to3 = 510;


    rule f0 (feed == 0); dofeed(ti1_a, ti1_b); endrule
    rule f1 (feed == 1); dofeed(ti2_a, ti2_b); endrule
    rule f2 (feed == 2); dofeed(ti3_a, ti3_b); endrule
    
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
