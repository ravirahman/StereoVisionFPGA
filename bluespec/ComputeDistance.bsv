// This file contains the interface and implementation of the block that computes the real
// world distance given the distance in pixels between the block in the left and right images

import FIFO::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;
import XYPointDistance::*;
import XYPoint::*;
import Vector::*;

typedef Server#(
	XYPointDistance#(pb),
	Vector#(3, FixedPoint#(fpbi, fpbf))
) ComputeDistance#(numeric type pb, numeric type fpbi, numeric type fpbf);

module mkComputeDistance(FixedPoint#(fpbi, fpbf) focalDistance, FixedPoint#(fpbi, fpbf) real_world_cte, ComputeDistance#(pb, fpbi, fpbf) ifc)
	provisos(
		Add#(TAdd#(pb, 1), a__, fpbi)
	);

	FIFO#(XYPointDistance#(pb)) pixelDistances <- mkFIFO();
	FIFO#(Vector#(3, FixedPoint#(fpbi, fpbf))) realDistances <- mkFIFO();

	rule compute (True);
		let pixelDist = pixelDistances.first();
		pixelDistances.deq();

		// const fp32_t<fpbf> denom = (_pixelPitch * in.offset);
		// const fp32_t<fpbf> denom_recrip = fp32_t<fpbf * 2>(1.0) / denom;
		// // bit shifting to preserve precision
		// const fp32_t<fpbf*2> x = (_cameraDistance * in.ref.x) * denom_recrip;
		// const fp32_t<fpbf*2> y = (_cameraDistance * in.ref.y) * denom_recrip;
		// const fp32_t<fpbf*2> z = (_cameraDistance * _focalLength) * denom_recrip / fp32_t<fpbf>(1.0);
		FixedPoint#(fpbi, fpbf) x = fromUInt(pixelDist.point.x);
		FixedPoint#(fpbi, fpbf) y = fromUInt(pixelDist.point.y);
		FixedPoint#(fpbi, fpbf) d = fromUInt(pixelDist.distance);
	
		Vector#(3, FixedPoint#(fpbi, fpbf)) ans = ?;
		// FixedPoint#(TMul#(fpbi, 2), TMul#(fpbf, 2)) expandedNum = fxptZeroExtend(real_world_cte);
		FixedPoint#(fpbi, fpbf) factor = real_world_cte / d;
		FixedPoint#(fpbi, fpbf) realX = fxptTruncate(factor * x);
		ans[0] = fxptTruncate(factor * x);  // X
		ans[1] =  fxptTruncate(factor * y);  // Y
		ans[2] =  fxptTruncate(factor * focalDistance);  // Z
		realDistances.enq(ans);	
	endrule

	interface Put request = toPut(pixelDistances);
	interface Get response = toGet(realDistances);
endmodule
