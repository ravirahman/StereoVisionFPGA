// This file contains the interface and implementation of the block that performs the full StereoVision for
// one image point

import FIFO::*;
import Vector::*;
import FixedPoint::*;
import Types::*;
import ComputeScore::*;
import UpdateScore::*;
import ComputeDistance::*;
import LoadBlocks::*;


interface StereoVisionSinglePoint;
	method Action putImagePoint (UInt#(PB) x, UInt#(PB) y);
        method ActionValue#(FixedPoint#(FPBI, FPBF)) getDistance;
endinterface


module mkStereoVisionSinglePoint(StereoVisionSinglePoint);
	
	function FixedPoint#(FPBI, FPBF) computeRealWorldDistance (UInt#(PB) pixelDist);
		FixedPoint#(FPBI, FPBF) fxptPixelDist = fromUInt(pixelDist);
		FixedPoint#(FPBI, FPBF) realDist =  real_world_cte/fxptPixelDist;
		return realDist;	
	endfunction

	FIFO#(FixedPoint#(FPBI, FPBF)) realDistances <- mkFIFO();
	FIFO#(UInt#(PB)) xs <- mkFIFO();
     	FIFO#(UInt#(PB)) ys <- mkFIFO();

	// Counter to keep track of the number of blocks we have loaded in memory
        Reg#(UInt#(PB)) loadCounter <- mkReg(0);
	// Counter to keep track of the number of blocks that have been processed
	Reg#(UInt#(PB)) compCounter <- mkReg(0);

	// Boolean to check if the reference block has been loaded
	Reg#(Bool) referenceBlockLoaded <- mkReg(False);

	// Register to hold the reference block
	Reg#(Vector#(NPIXELS, UInt#(PIXELWIDTH))) refBlock <- mkRegU();
	Reg#(Bool) referenceBlockStored <- mkReg(False); 

	// Modules that make the different operations
        LoadBlock#(PB, NPIXELS, PIXELWIDTH) loadRefBlock <- mkLoadBlock();
	LoadBlock#(PB, NPIXELS, PIXELWIDTH) loadCompBlock <- mkLoadCompBlock();
	ComputeScore#(SB, NPIXELS, PIXELWIDTH) cs <- mkComputeScore();
        UpdateScore#(SB, PB) us <- mkUpdateScore();	
	
	// This rules keeps asking for blocks to be loaded until
	// we have loaded all the necessary blocks in the search area
	rule retrieveBlock if (loadCounter < searchAreaUInt);
		let x = xs.first();
		let y = ys.first();
		
		if (referenceBlockLoaded == False) begin
			loadRefBlock.putImagePoint(x, y);
			loadCompBlock.putImagePoint(x, y);
			referenceBlockLoaded <= True;
		end else begin
			loadCompBlock.putImagePoint(x+loadCounter, y);
		end
		loadCounter <= loadCounter + 1;
	endrule

	rule computeScoreRule if (compCounter < searchAreaUInt);
		if (referenceBlockStored == False) begin
			let b <- loadRefBlock.getBlock();
			let c <- loadCompBlock.getBlock();
			//$display("Ref Block: ", b);
			//$display("Comp block: ", c);
			cs.loadBlocks(b, c);
			refBlock <= b;
			referenceBlockStored <= True;
		end else begin
			let c <- loadCompBlock.getBlock();
			//$display("Ref Block: ", refBlock);
			//$display("Comp block: ", c);
			cs.loadBlocks(refBlock, c);
		end
	endrule

	rule updateScoreRule if (compCounter < searchAreaUInt);
		let sc <- cs.getScore();
		$display("Block score is: ", sc);
		us.putScore(sc, compCounter);
		compCounter <= compCounter+1;
	endrule

	rule computeRealWorldDistanceRule if (compCounter == searchAreaUInt);
		// If we are here, it means we have completed the search over the whole search area.
		let bd <- us.getBestDistance();
		$display("Best distance is: ", bd);
		let d = computeRealWorldDistance(bd);
		realDistances.enq(d);
		// Restart the counters
		$display("Dequeued");
		loadCounter <= 0;
		compCounter <= 0;
		referenceBlockLoaded <= False;
		referenceBlockStored <= False;
		us.restart();
		xs.deq();
		ys.deq();
	endrule


	// Interface methods
	method Action putImagePoint (UInt#(PB) x, UInt#(PB) y);
		xs.enq(x);
		ys.enq(y);
	endmethod

	method ActionValue#(FixedPoint#(FPBI, FPBF)) getDistance();
		let a = realDistances.first();
		realDistances.deq();
		return a;
	endmethod


endmodule
