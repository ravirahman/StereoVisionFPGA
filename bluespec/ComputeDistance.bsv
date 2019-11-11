// This file contains the interface and implementation of the block that computes the real
// world distance given the distance in pixels between the block in the left and right images

import FIFO::*;
import FixedPoint::*;
import Types::*;


interface ComputeDistance;
	method Action putPixelDistance (UInt#(PB) distance);
        method ActionValue#(FixedPoint#(FPBI, FPBF)) getRealDistance;
endinterface


module mkComputeDistance(ComputeDistance);

	FIFO#(UInt#(PB)) pixelDistances <- mkFIFO();
        FIFO#(FixedPoint#(FPBI, FPBF)) realDistances <- mkFIFO();


	rule compute (True);

		let pixelDist = pixelDistances.first();
		pixelDistances.deq();
		
		FixedPoint#(FPBI, FPBF) fxptPixelDist = fromUInt(pixelDist);
		FixedPoint#(FPBI, FPBF) realDist =  real_world_cte/fxptPixelDist;
		realDistances.enq(realDist);	
				
	endrule


	method Action putPixelDistance( UInt#(PB) distance);
	
		pixelDistances.enq(distance);
	
	endmethod	

	method ActionValue#(FixedPoint#(FPBI, FPBF)) getRealDistance();
	
		realDistances.deq();
		return realDistances.first();

	endmethod
endmodule
