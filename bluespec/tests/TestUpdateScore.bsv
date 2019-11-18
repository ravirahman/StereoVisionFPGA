// This file tests the implementation of the ComputeDistance block

import UpdateScore::*;
import Types::*;
import Vector::*;
import GetPut::*;
import ComputeScore::*;
import Pixel::*;


Int#(4) num_distances_lim = 3;

typedef ScoreT#(NPIXELS, PD, PIXELWIDTH) MyScoreT;
typedef Vector#(TMul#(NPIXELS, NPIXELS), Pixel#(PD, PIXELWIDTH)) BlockT;

module mkTest();

	UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH) us <- mkUpdateScore();

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Int#(4)) feed_counter <- mkReg(0);
	Reg#(Bool) all_fed <- mkReg(False);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(MyScoreT score, UInt#(PB) distance);
        action
            ScoreDistanceT#(PB, NPIXELS, PD, PIXELWIDTH) sd = ?;
            sd.score = score;
            sd.distance = distance;
			if (feed_counter < num_distances_lim) begin
                feed_counter <= feed_counter + 1;
				us.request.put(sd);
			end else begin
				us.request.put(sd);
				all_fed <= True;
				feed <= feed + 1;
			end
		endaction
	endfunction

	function Action docheck(UInt#(PB) expDist);
		action
			let bestDistance <- us.response.get();
			us.restart();
			all_fed <= False;
			feed_counter <= 0;
			if (bestDistance != expDist) begin
				$display("Wanted: ", expDist);
				$display("Got: ", bestDistance);
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction

    Vector#(4, UInt#(PB)) dist1 = newVector();
    dist1[0] = 0;
    dist1[1] = 1;
    dist1[2] = 2;
    dist1[3] = 3;

    Vector#(4, UInt#(PB)) dist2 = newVector();
    dist2[0] = 0;
    dist2[1] = 1;
    dist2[2] = 2;
    dist2[3] = 3;

    Vector#(4, UInt#(PB)) dist3 = newVector();
    dist3[0] = 0;
    dist3[1] = 1;
    dist3[2] = 2;
    dist3[3] = 3;

    Vector#(4, MyScoreT) scores1 = newVector();
    scores1[0] = 20;
    scores1[1] = 45;
    scores1[2] = 3;
    scores1[3] = 17;

    Vector#(4, MyScoreT) scores2 = newVector();
    scores2[0] = 45;
    scores2[1] = 5;
    scores2[2] = 10;
    scores2[3] = 78;

    Vector#(4, MyScoreT) scores3 = newVector();
    scores3[0] = 1;
    scores3[1] = 25;
    scores3[2] = 12;
    scores3[3] = 19;

    UInt#(PB) to1 = 2;
    UInt#(PB) to2 = 1;
    UInt#(PB) to3 = 0;

    rule f0 (feed == 0 && all_fed == False); dofeed(scores1[feed_counter], dist1[feed_counter] ); endrule
    rule f1 (feed == 1 && all_fed == False); dofeed(scores2[feed_counter], dist2[feed_counter] ); endrule
    rule f2 (feed == 2 && all_fed == False); dofeed(scores3[feed_counter], dist3[feed_counter]); endrule
    
    rule c0 (check == 0 && all_fed == True); docheck(to1); endrule
    rule c1 (check == 1 && all_fed == True); docheck(to2); endrule
    rule c2 (check == 2 && all_fed == True); docheck(to3); endrule


    rule finish (feed == 3 && check == 3);
        if (passed) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end
        $finish();
    endrule


endmodule
