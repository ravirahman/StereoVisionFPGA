// This file tests the implementation of the ComputeDistance block
import LoadBlocks::*;
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

typedef Vector#(TMul#(NPIXELS, NPIXELS), Pixel#(PD, PIXELWIDTH)) Block;
typedef 3 NUM_SAMPLES;

module mkTest();
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);


	LoadBlocks#(0, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) loadBlocks <- mkLoadBlocks(readerWrapper);
	Reg#(Bool) passed <- mkReg(True);
	Reg#(Bit#(8)) feed <- mkReg(0);
    Reg#(Bit#(8)) check <- mkReg(0);
    Reg#(Int#(26)) nextBlockToLoad <- mkReg(0);
    
    
	function Action dofeed(XYPoint#(PB) xy);
        action
            $display("Test x, y: ", xy.x, xy.y);
            loadBlocks.request.put(xy);
            feed <= feed + 1;
		endaction
	endfunction

	function Action docheck(Block expBlock);
		action
			let actBlock <- loadBlocks.response.get();
			if (actBlock != expBlock) begin
				$display("Wanted: ", fshow(expBlock));
				$display("Got: ", fshow(actBlock));
				passed <= False;
			end else begin
                // $display("Check passed");
            end
			check <= check+1;
		endaction
    endfunction

    
    
    Pixel#(PD, PIXELWIDTH) blackPixel = replicate(0);
    Pixel#(PD, PIXELWIDTH) whitePixel = replicate(1);

    Vector#(TDiv#(512, TMul#(PD, PIXELWIDTH)), Pixel#(PD, PIXELWIDTH)) whitePixelLine = replicate(whitePixel);
    Vector#(TDiv#(512, TMul#(PD, PIXELWIDTH)), Pixel#(PD, PIXELWIDTH)) blackPixelLine = replicate(blackPixel);
    
    rule loadMemory (feed == 0 && check == 0);
        DDR3_LineReq req = ?;
        req.write = True;
        req.line_addr = pack(nextBlockToLoad);
        // doing a checkerboard pattern of data loading
        // 512 bits of 0, followed by 512 bits of 1. This corresponds do 16 pixels of 0, then 16 pixels of 1
        if (nextBlockToLoad % 2 == 0) begin
            req.data_in = pack(blackPixelLine);
        end
        else begin
            req.data_in = pack(whitePixelLine);
        end
        ddr3_user.request.put(req);

        if (nextBlockToLoad == 0) begin
            $display("Loading memory");
        end
        
        if (nextBlockToLoad == 256) begin
            $display("Finished loading memory");
            feed <= feed + 1;
            check <= check + 1;  // nothing to check here
        end
        nextBlockToLoad <= nextBlockToLoad + 1;
        
    endrule

    // assumes that the image width is a multiple of 16 but not 32 since 16 pixels (32 bits each) are stored in a 512-bit dram line, and that NPIXELS=5

    XYPoint#(PB) p1;
    p1.x = 0;
    p1.y = 0;

    XYPoint#(PB) p2;
    p2.x = 14;
    p2.y = 0;

    Vector#(TMul#(NPIXELS, NPIXELS), Pixel#(PD, PIXELWIDTH)) to1;  // checkboard
    Vector#(TMul#(NPIXELS, NPIXELS), Pixel#(PD, PIXELWIDTH)) to2;  // ofset checkerboard

    for (Integer r = 0; r < valueOf(NPIXELS); r = r+1) begin
        for (Integer c = 0; c < valueOf(NPIXELS); c = c+1) begin
            if (r % 2 == 0) begin
                to1[r * valueOf(NPIXELS) + c] = blackPixel;
                if (c < 2) begin 
                    to2[r * valueOf(NPIXELS) + c] = blackPixel;
                end else begin
                    to2[r * valueOf(NPIXELS) + c] = whitePixel;
                end
            end
            else begin
                to1[r * valueOf(NPIXELS) + c] = whitePixel;
                if (c < 2) begin 
                    to2[r * valueOf(NPIXELS) + c] = whitePixel;
                end else begin
                    to2[r * valueOf(NPIXELS) + c] = blackPixel;
                end
            end
            
        end
    end

    rule feed_rule if (feed > 0 && feed < fromInteger(valueOf(NUM_SAMPLES)));
        if (feed % 2 == 0) begin
            dofeed(p1);
        end else begin
            dofeed(p2);
        end
    endrule

    rule check_rule if (check > 0 && check < fromInteger(valueOf(NUM_SAMPLES)));
        if (check % 2 == 0) begin
            docheck(to1);
        end else begin
            docheck(to2);
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
