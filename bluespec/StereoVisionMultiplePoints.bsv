// This file contains the interface and implementation of the block that performs the full StereoVision for
// several image points in parallel

import Vector::*;
import FixedPoint::*;
import Types::*;
import StereoVisionSinglePoint::*;


interface StereoVisionMultiplePoints;
	method Action putImagePoints (Vector#(N, UInt#(PB)) xs, Vector#(N, UInt#(PB)) ys);
        method ActionValue#(Vector#(N, FixedPoint#(FPBI, FPBF))) getDistances;
endinterface


module mkStereoVisionMultiplePoints(StereoVisionMultiplePoints);
	
	Vector#(N, StereoVisionSinglePoint) stereoVisionModules <- replicateM(mkStereoVisionSinglePoint());

	// Interface methods
	method Action putImagePoints (Vector#(N, UInt#(PB)) xs, Vector#(N, UInt#(PB)) ys);
		for (Integer i = 0; i < valueOf(N); i = i+1) begin
			stereoVisionModules[i].putImagePoint(xs[i], ys[i]);
		end
	endmethod

        method ActionValue#(Vector#(N, FixedPoint#(FPBI, FPBF))) getDistances;
		
		Vector#(N, FixedPoint#(FPBI, FPBF)) dists = newVector;
	
		for (Integer i = 0; i < valueOf(N); i = i+1) begin
			let distance <- stereoVisionModules[i].getDistance();
			dists[i] = distance;
		end

		return dists;
	endmethod


endmodule
