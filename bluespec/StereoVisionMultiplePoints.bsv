// This file contains the interface and implementation of the block that performs the full StereoVision for
// several image points in parallel

import Vector::*;
import FixedPoint::*;
import Types::*;
import StereoVisionSinglePoint::*;
import GetPut::*;
import ClientServer::*;
import XYPoint::*;
import Pixel::*;
import DDR3User::*;

typedef Server#(
	Vector#(n, XYPoint#(pb)),
	Vector#(n, FixedPoint#(fpbi, fpbf))
) StereoVisionMultiplePoints#(numeric type imageWidth, numeric type n, numeric type pb, numeric type searchAreaUInt, numeric type npixelst, numeric type pd, numeric type pixelWidth, numeric type fpbi, numeric type fpbf);

module mkStereoVisionMultiplePoints(DDR3_6375User ddr3_user, FixedPoint#(fpbi, fpbf) real_world_cte, StereoVisionMultiplePoints#(imageWidth, n, pb, searchAreaUInt, npixelst, pd, pixelWidth, fpbi, fpbf) ifc)
	provisos(
		Add#(1, a__, TMul#(npixelst, npixelst))
		, Add#(b__, pb, TAdd#(DDR3_Addr_Size, TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)))))
		, Add#(c__, pb, 26)
		, Add#(TAdd#(pb, 1), d__, fpbi)
	);

	Vector#(N, StereoVisionSinglePoint#(imageWidth, pb, searchAreaUInt, npixelst, pd, pixelWidth, fpbi, fpbf)) stereoVisionModules <- replicateM(mkStereoVisionSinglePoint(ddr3_user, real_world_cte));

	// Interface methods
	interface Put request;
		method Action put(Vector#(n, XYPoint#(pb)) points);
			for (Integer i = 0; i < valueOf(n); i = i+1) begin
				stereoVisionModules[i].request.put(points[i]);
			end
		endmethod
	endinterface

	interface Get response;
		method ActionValue#(Vector#(n, FixedPoint#(fpbi, fpbf))) get;
			Vector#(n, FixedPoint#(fpbi, fpbf)) dists = newVector;
			for (Integer i = 0; i < valueOf(n); i = i+1) begin
				let distance <- stereoVisionModules[i].response.get();
				dists[i] = distance;
			end

			return dists;
		endmethod
	endinterface

endmodule
