// This file contains the interface and implementation of the block that computes the score between two given blocks

import Vector::*;
import FIFO::*;
import Pixel::*;
import ClientServer::*;
import GetPut::*;

typedef struct {
	Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)) refBlock;
	Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)) compBlock;
} BlockPair#(numeric type npixelst, numeric type pd, numeric type pixelWidth) deriving(Bits, Eq);

typedef UInt#(TAdd#(pixelWidth, TLog#(TMul#(TMul#(npixelst, npixelst), pd)))) ScoreT#(numeric type npixelst, numeric type pd, numeric type pixelWidth);

typedef Server#(
	BlockPair#(npixelst, pd, pixelWidth),
	ScoreT#(npixelst, pd, pixelWidth)
) ComputeScore#(numeric type npixelst, numeric type pd, numeric type pixelWidth);

module mkComputeScore(ComputeScore#(npixelst, pd, pixelWidth))
	provisos(
		Add#(1, a__, TMul#(npixelst, npixelst)),
		Add#(b__, pixelWidth, TLog#(TMul#(pixelWidth, TMul#(TMul#(npixelst, npixelst), pd))))
	);

	FIFO#(BlockPair#(npixelst, pd, pixelWidth)) inFIFO <- mkFIFO();
	FIFO#(ScoreT#(npixelst, pd, pixelWidth)) outFIFO <- mkFIFO();

	function ScoreT#(npixelst, pd, pixelWidth) abs_diff (Pixel#(pd, pixelWidth) a, Pixel#(pd, pixelWidth) b);
		ScoreT#(npixelst, pd, pixelWidth) df = 0;
		for (Integer i = 0; i < valueOf(pd); i = i + 1) begin

			if (a[i] > b[i]) begin
				df = df + extend(a[i] - b[i]);
			end else begin
				df = df + extend(b[i] - a[i]);
			end
		end
		//$display("Pixel difference is ", unpack(df));		
		return df;
	endfunction

	rule compute (True);

		let refB = inFIFO.first().refBlock;
		let compB = inFIFO.first().compBlock;
		inFIFO.deq();

		let score_vec = zipWith(abs_diff, refB, compB);
		let score = fold(\+ , score_vec);
		//ScoreT#(npixelst, pd, pixelWidth) score = 0;

		//$display("--------------------------------------------");
		//for (Integer i = 0; i < valueOf(TMul#(npixelst,npixelst)); i = i+1) begin
		//		/for (Integer k = 0; k < valueOf(pd); k = k+1) begin
		//		$display("Ref Block Position (%d, %d) is %d", i, k, refB[i][k]);
		//		$display("Comp Block Position (%d,%d) is %d", i, k, compB[i][k]);
		//		if (refB[i][k]>compB[i][k]) begin
		//			$display("The difference is ", refB[i][k]-compB[i][k]);
		//		end else begin
		//			$display("The difference is ", compB[i][k]-refB[i][k]);
		//		end
		//		
		//		end
		//		$display(score_vec[i]);
		//		score = score + score_vec[i];
		//		$display(score);
		//end 
		//$display("Score is: ", score);
		//$display("--------------------------------------------");
		outFIFO.enq(score);
	endrule

	interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule
