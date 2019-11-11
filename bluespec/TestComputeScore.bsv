// This file tests the implementation of the ComputeScore block

import ComputeScore::*;
import Vector::*;

typedef 10 Sb;
typedef 2 Npixels;
typedef 8 Bitwidth;

module mkTest();

	ComputeScore#(Sb, Npixels, Bitwidth) cs <- mkComputeScore();

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(Vector#(Npixels, UInt#(Bitwidth)) a, 
			       Vector#(Npixels, UInt#(Bitwidth)) b);
		action
			feed <= feed + 1;
			cs.loadBlocks(a, b);
		endaction
	endfunction

	function Action docheck(UInt#(Sb) expScore);
		action
			let compScore <- cs.getScore();
			if (compScore != expScore) begin
				$display("Wanted: ", expScore);
				$display("Got: ", compScore);
				passed <= False;
			end
			check <= check+1;
		endaction
	endfunction


    Vector#(Npixels, UInt#(Bitwidth)) ti1_a = newVector;
    Vector#(Npixels, UInt#(Bitwidth)) ti1_b = newVector;
    ti1_a[0] = 10;
    ti1_a[1] = 250;
    ti1_b[0] = 5;
    ti1_b[1] = 100;

    UInt#(Sb) to1 = 155;


    Vector#(Npixels, UInt#(Bitwidth)) ti2_a = newVector;
    Vector#(Npixels, UInt#(Bitwidth)) ti2_b = newVector;
    ti2_a[0] = 123;
    ti2_a[1] = 25;
    ti2_b[0] = 230;
    ti2_b[1] = 100;

    UInt#(Sb) to2 = 182;

    
    Vector#(Npixels, UInt#(Bitwidth)) ti3_a = newVector;
    Vector#(Npixels, UInt#(Bitwidth)) ti3_b = newVector;
    ti3_a[0] = 255;
    ti3_a[1] = 255;
    ti3_b[0] = 0;
    ti3_b[1] = 0;

    UInt#(Sb) to3 = 510;


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
