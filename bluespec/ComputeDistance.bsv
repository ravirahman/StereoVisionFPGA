// This file contains the interface and implementation of the block that computes the real
// world distance given the distance in pixels between the block in the left and right images

import FIFO::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;

typedef Server#(
	UInt#(pb),
	FixedPoint#(fpbi, fpbf)
) ComputeDistance#(numeric type pb, numeric type fpbi, numeric type fpbf);

module mkComputeDistance(FixedPoint#(fpbi, fpbf) real_world_cte, ComputeDistance#(pb, fpbi, fpbf) ifc)
	provisos(
		Add#(TAdd#(pb, 1), a__, fpbi)
	);

	FIFO#(UInt#(pb)) pixelDistances <- mkFIFO();
	FIFO#(FixedPoint#(fpbi, fpbf)) realDistances <- mkFIFO();

	rule compute (True);
		let pixelDist = pixelDistances.first();
		pixelDistances.deq();
		
		FixedPoint#(fpbi, fpbf) fxptPixelDist = fromUInt(pixelDist);
		FixedPoint#(fpbi, fpbf) realDist =  real_world_cte/fxptPixelDist;
		realDistances.enq(realDist);	
	endrule

	interface Put request = toPut(pixelDistances);
	interface Get response = toGet(realDistances);
endmodule
