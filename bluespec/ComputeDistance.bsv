// This file contains the interface and implementation of the block that computes the real
// world distance given the distance in pixels between the block in the left and right images

import FIFO::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;
import XYPointDistance::*;
import XYPoint::*;
import Vector::*;

typedef 320 IMAGEHEIGHT;

typedef Server#(
	XYPointDistance#(pb),
	Vector#(3, FixedPoint#(fpbi, fpbf))
) ComputeDistance#(numeric type pb, numeric type searchArea, numeric type npixelst, numeric type fpbi, numeric type fpbf);

module mkComputeDistance(FixedPoint#(fpbi, fpbf) focalDistance, FixedPoint#(fpbi, fpbf) real_world_cte, ComputeDistance#(pb, searchArea, npixelst, fpbi, fpbf) ifc)
	provisos(
		Add#(TAdd#(pb, 1), a__, fpbi)
	);

	FIFO#(XYPointDistance#(pb)) pixelDistances <- mkFIFO();
	FIFO#(Vector#(3, FixedPoint#(fpbi, fpbf))) realDistances <- mkFIFO();

	Vector#(TAdd#(TAdd#(searchArea, npixelst), 1), FixedPoint#(fpbi, fpbf)) factors = ?;
	factors[0] = 0;
	for (Integer i = 1; i < valueOf(TAdd#(TAdd#(searchArea, npixelst), 1)); i = i + 1) begin
		UInt#(pb) i_uint = fromInteger(i);
		FixedPoint#(fpbi, fpbf) d = fromUInt(i_uint);
		factors[i] = real_world_cte / d;
	end

	rule compute (True);
		let pixelDist = pixelDistances.first();
		pixelDistances.deq();
		// $display("Search area is", valueOf(searchArea));
		// $display("The input pixel distance is ", pixelDist.distance);
		FixedPoint#(fpbi, fpbf) factor = factors[pixelDist.distance];
		FixedPoint#(fpbi, fpbf) x = fromUInt(pixelDist.point.x);
		UInt#(pb) realY = fromInteger(valueOf(IMAGEHEIGHT)) - pixelDist.point.y;
		FixedPoint#(fpbi, fpbf) y = fromUInt(realY);

		Vector#(3, FixedPoint#(fpbi, fpbf)) ans = ?;
		// $display("distance of ", d);
		ans[0] = fxptTruncate(factor * x);  // X
		ans[1] = fxptTruncate(factor * y);  // Y
		ans[2] = fxptTruncate(factor * focalDistance);  // Z
		realDistances.enq(ans);
	endrule

	interface Put request = toPut(pixelDistances);
	interface Get response = toGet(realDistances);
endmodule
