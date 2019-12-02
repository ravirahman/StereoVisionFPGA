// This file tests the implementation of the ComputeDistance block
import StereoVisionSinglePoint::*;
import Types::*;
import FixedPoint::*;
import ClientServer::*;
import GetPut::*;
import FShow::*;
import Vector::*;
import Pixel::*;
// DRAM
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;
import XYPoint::*;
import DDR3Controller::*;
import DDR3ReaderWrapper::*;

interface Top_Pins;
   interface DDR3_Pins_VC707_1GB pins_ddr3;
endinterface

typedef TDiv#(512, TMul#(PIXELWIDTH, PD)) PIXELS_IN_BLOCK;
typedef TDiv#(IMAGEWIDTH, PIXELS_IN_BLOCK) BLOCKS_IN_ROW;

typedef 100 NUM_SAMPLES;

module mkTest();
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);

	StereoVisionSinglePoint#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) svsp <- mkStereoVisionSinglePoint(readerWrapper, focal_dist, real_world_cte);
	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(TLog#(NUM_SAMPLES))) feed <- mkReg(0);
	Reg#(Bit#(TLog#(NUM_SAMPLES))) check <- mkReg(0);

	function Action dofeed(XYPoint#(PB) xy);
		action
			feed <= feed + 1;
            $display("Test y: ", xy.y);
			svsp.request.put(xy);
		endaction
    endfunction
    Reg#(Int#(26)) nextBlockToLoad <- mkReg(0);
    

    rule loadMemory (feed == 0 && check == 0);
        let blockX = nextBlockToLoad % fromInteger(valueOf(BLOCKS_IN_ROW));
        let y = nextBlockToLoad / fromInteger(valueOf(BLOCKS_IN_ROW));
        Vector#(PIXELS_IN_BLOCK, Pixel#(PD, PIXELWIDTH)) pixels = ?;
        for (Integer i = 0; i < valueOf(PIXELS_IN_BLOCK); i = i+1) begin
            let x = blockX * fromInteger(valueOf(PIXELS_IN_BLOCK)) + fromInteger(i); 
            if (x == 0) begin
                if (y == 0) begin
                    pixels[i] = mkRGBPixel(2,2,2);
                end else begin
                    pixels[i] = mkRGBPixel(3,3,3);
                end
            end else if (x == 16) begin		
                if (y == 0) begin
                    pixels[i] = mkRGBPixel(1,1,1);
                end else begin
                    pixels[i] = mkRGBPixel(3,3,3);
                end
            end else begin
                if (y == 0) begin
                    pixels[i] = mkRGBPixel(5,5,5);
                end else begin
                    pixels[i] = mkRGBPixel(1,1,1);
                end
            end
        end
        DDR3_LineReq req = ?;
        req.write = True;
        req.line_addr = pack(nextBlockToLoad);
        req.data_in = pack(pixels);
        ddr3_user.request.put(req);

        if (nextBlockToLoad == 0) begin
            $display("Loading memory");
        end
        
        if (nextBlockToLoad == 128) begin
            $display("Finished loading memory");
            feed <= feed + 1;
            check <= check + 1;  // nothing to check here
        end
        nextBlockToLoad <= nextBlockToLoad + 1;
    endrule

	function Action docheck(FixedPoint#(FPBI, FPBF) expDist);
		action
			let compDistance <- svsp.response.get();
			if (compDistance[2] != expDist) begin
				$display("Wanted: ", fshow(expDist));
				$display("Got: ", fshow(compDistance));
				passed <= False;
			end
            // $display("check ", check);
            check <= check+1;
		endaction
	endfunction

    XYPoint#(PB) p1;
    p1.x = 204;
    p1.y = 146;

    XYPoint#(PB) p2;
    p2.x = 16;
    p2.y = 1;

    XYPoint#(PB) p3;
    p3.x = 204;
    p3.y = 146;

    FixedPoint#(FPBI, FPBF) to1 = 13.43785;
    FixedPoint#(FPBI, FPBF) to2 = 2.45063;
    FixedPoint#(FPBI, FPBF) to3 = 6.73925;

    rule feed_rule if (feed > 0 && feed < fromInteger(valueOf(NUM_SAMPLES)));
        if (feed % 3 == 0) begin
            dofeed(p1);
        end else if (feed % 3 == 1) begin
            dofeed(p2);
        end else begin
            dofeed(p3);
        end
    endrule

    rule check_rule if (check > 0 && check < fromInteger(valueOf(NUM_SAMPLES)));
        if (check % 3 == 0) begin
            docheck(to1);
        end else if (check % 3 == 1) begin
            docheck(to2);
        end else begin
            docheck(to3);
        end
    endrule

    rule finish (feed == fromInteger(valueOf(NUM_SAMPLES)) && check == fromInteger(valueOf(NUM_SAMPLES)));
        if (passed) begin
            $display("PASSED");
        end else begin
            $display("FAILED");
        end
        $finish();
    endrule
endmodule
