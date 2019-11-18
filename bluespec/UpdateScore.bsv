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
} ScoreDistanceT#(numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);


interface UpdateScore#(numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);
	interface Put#(ScoreDistanceT#(pb, npixelst, pd, pixelWidth)) request;
	interface Get#(UInt#(pb)) response;
	method Action restart;
endinterface

module mkUpdateScore(UpdateScore#(pb, npixelst, pd, pixelWidth));

	Reg#(Maybe#(ScoreT#(npixelst, pd, pixelWidth))) bestScore <- mkReg(tagged Invalid);
	Reg#(Maybe#(UInt#(pb))) bestDistance <- mkReg(tagged Invalid);

	interface Put request;
		method Action put(ScoreDistanceT#(pb, npixelst, pd, pixelWidth) scoreDistance);
			let score = scoreDistance.score;
			let distance = scoreDistance.distance;

			if (isValid(bestScore)) begin
				if (fromMaybe(?, bestScore) > score) begin
					bestScore <= tagged Valid score;
					bestDistance <= tagged Valid distance;
				end
				
			end else begin
				bestScore <= tagged Valid score;
				bestDistance <= tagged Valid distance;
			end
		
		endmethod
	endinterface

	interface Get response;
		method ActionValue#(UInt#(pb)) get();
			return fromMaybe(0, bestDistance);
		endmethod
	endinterface

	method Action restart;
		bestScore <= tagged Invalid;
		bestDistance <= tagged Invalid;		
	endmethod
endmodule
