// This file contains the interface and implementation of the block that keeps track of the lowest 
// score in a given search area.

import FIFO::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;
import ComputeScore::*;

typedef struct {
	ScoreT#(npixelst, pd, pixelWidth) score;
	UInt#(pb) distance;
} ScoreDistanceT#(numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth) deriving(Bits, Eq);


typedef Server#(
	ScoreDistanceT#(pb, npixelst, pd, pixelWidth),
	UInt#(pb)
) UpdateScore#(numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);

module mkUpdateScore(UpdateScore#(pb, npixelst, pd, pixelWidth));
	Reg#(Maybe#(ScoreT#(npixelst, pd, pixelWidth))) bestScore <- mkReg(tagged Invalid);
	Reg#(UInt#(pb)) bestDistance <- mkRegU();

	interface Put request;
		method Action put(ScoreDistanceT#(pb, npixelst, pd, pixelWidth) scoreDistance);
			let score = scoreDistance.score;
			let distance = scoreDistance.distance;

			if (isValid(bestScore)) begin
				if (fromMaybe(?, bestScore) > score) begin
					bestScore <= tagged Valid score;
					bestDistance <= distance;
				end
				
			end else begin
				bestScore <= tagged Valid score;
				bestDistance <= distance;
			end
		
		endmethod
	endinterface

	interface Get response;
		method ActionValue#(UInt#(pb)) get();
			bestScore <= tagged Invalid;
			return bestDistance;
		endmethod
	endinterface
endmodule
