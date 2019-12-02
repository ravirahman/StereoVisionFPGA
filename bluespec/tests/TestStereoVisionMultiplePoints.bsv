// This file tests the implementation of the ComputeDistance block

import StereoVisionMultiplePoints::*;
import Types::*;
import FixedPoint::*;
import FShow::*;
import Vector::*;
import XYPoint::*;
import ClientServer::*;
import GetPut::*;
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;
import DDR3ReaderWrapper::*;
import DefaultValue::*;
import FShow::*;

module mkTest();

    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);

	StereoVisionMultiplePoints#(N, COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) svmp <- mkStereoVisionMultiplePoints(readerWrapper, focal_dist, real_world_cte);

	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(4)) feed <- mkReg(0);
	Reg#(Bit#(4)) check <- mkReg(0);

	function Action dofeed(Vector#(N, XYPoint#(PB)) points);
		action
			feed <= feed + 1;
			svmp.request.put(points);
		endaction
	endfunction

	function Action docheck(Vector#(N, FixedPoint#(FPBI, FPBF)) expDist);
		action
			let compDistance <- svmp.response.get();
			for (Integer i = 0; i < valueOf(N); i = i + 1) begin
				if (compDistance[i][2] != expDist[i]) begin  // only comparing zed
					$display("Wanted: ", fshow(expDist[i]));
					$display("Got: ", fshow(compDistance[i]));
				end
			end
			passed <= False;
			check <= check+1;
		endaction
	endfunction

    XYPoint#(PB) p1;
    p1.x = 10;
    p1.y = 0;

    XYPoint#(PB) p2;
    p2.x = 10;
    p2.y = 1;

    XYPoint#(PB) p3;
    p3.x = 10;
    p3.y = 2;

    Vector#(N, XYPoint#(PB)) points = ?;
    points[0] = p1;
    points[1] = p2;
    points[2] = p3;

    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.45063;
    FixedPoint#(FPBI, FPBF) to3 = 6.73925;

    Vector#(N, FixedPoint#(FPBI, FPBF)) tos = ?;
    tos[0] = to1;
    tos[1] = to2;
    tos[2] = to3;

    rule f0 (feed == 0); dofeed(points); endrule
    rule f1 (feed == 1); dofeed(points); endrule
    rule f2 (feed == 2); dofeed(points); endrule
    
    rule c0 (check == 0); docheck(tos); endrule
    rule c1 (check == 1); docheck(tos); endrule
    rule c2 (check == 2); docheck(tos); endrule


    rule finish (feed == 3 && check == 3);
        if (passed) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end
        $finish();
    endrule


endmodule
