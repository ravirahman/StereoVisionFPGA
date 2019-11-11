// This file contains the interface and implementation of the block that keeps track of the lowest 
// score in a given search area.

import FIFO::*;
import FixedPoint::*;


interface UpdateScore#(numeric type sbt, numeric type pbt);
	method Action putScore (UInt#(sbt) score, UInt#(pbt) distance);
        method ActionValue#(UInt#(pbt)) getBestDistance;
	method Action restart;
endinterface


module mkUpdateScore(UpdateScore#(sbt, pbt));

	Reg#(Maybe#(UInt#(sbt))) bestScore <- mkReg(tagged Invalid);
	Reg#(Maybe#(UInt#(pbt))) bestDistance <- mkReg(tagged Invalid);

	method Action putScore( UInt#(sbt) score, UInt#(pbt) distance);
	
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

	method ActionValue#(UInt#(pbt)) getBestDistance();

		return fromMaybe(0, bestDistance);

	endmethod

        method Action restart;

		bestScore <= tagged Invalid;
                bestDistance <= tagged Invalid;		

	endmethod

endmodule
