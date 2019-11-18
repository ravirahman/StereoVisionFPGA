// This file contains the interface and implementation of the block that performs the full StereoVision for
// one image point

import FIFO::*;
import Vector::*;
import FixedPoint::*;
import XYPoint::*;
import Pixel::*;
import ComputeScore::*;
import ClientServer::*;
import GetPut::*;
import UpdateScore::*;
import ComputeDistance::*;
import LoadBlocks::*;
import DDR3Common::*;
import DDR3Controller::*;
import DDR3Sim::*;
import DDR3User::*;
import DefaultValue::*;
import FShow::*;

// Connectal HW-SW can use a struct type
// However, the components must have a type of Bit#(n)
//  data7 corresponds to [511:448]
//  data0 corresponds to [31:0]
typedef struct{
    Bit#(64) data7;
    Bit#(64) data6;
    Bit#(64) data5;
    Bit#(64) data4;
    Bit#(64) data3;
    Bit#(64) data2;
    Bit#(64) data1;
    Bit#(64) data0;
} DRAM_Line deriving (Bits);



typedef Server#(
	XYPoint#(pb),
	FixedPoint#(fpbi, fpbf)
) StereoVisionSinglePoint#(numeric type imageWidth, numeric type pb, numeric type searchAreaUInt, numeric type npixelst, numeric type pd, numeric type pixelWidth, numeric type fpbi, numeric type fpbf);

module mkStereoVisionSinglePoint(DDR3_6375User ddr3_user, FixedPoint#(fpbi, fpbf) real_world_cte, StereoVisionSinglePoint#(imageWidth, pb, searchAreaUInt, npixelst, pd, pixelWidth, fpbi, fpbf) ifc)
	provisos(
		Add#(1, a__, TMul#(npixelst, npixelst))
		, Add#(b__, TAdd#(TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth))), 1), pb)
		, Add#(c__, pb, 26)
		, Add#(TAdd#(pb, 1), d__, fpbi)
	);
	
	function FixedPoint#(fpbi, fpbf) computeRealWorldDistance (UInt#(pb) pixelDist);
		FixedPoint#(fpbi, fpbf) fxptPixelDist = fromUInt(pixelDist);
		FixedPoint#(fpbi, fpbf) realDist =  real_world_cte/fxptPixelDist;
		return realDist;	
	endfunction

	FIFO#(FixedPoint#(fpbi, fpbf)) realDistances <- mkFIFO();
	FIFO#(XYPoint#(pb)) inFIFO <- mkFIFO();

	// Counter to keep track of the number of blocks we have loaded in memory
	Reg#(UInt#(pb)) loadCounter <- mkReg(0);
	// Counter to keep track of the number of blocks that have been processed
	Reg#(UInt#(pb)) compCounter <- mkReg(0);

	// Boolean to check if the reference block has been loaded
	Reg#(Bool) referenceBlockLoaded <- mkReg(False);

	// Register to hold the reference block
	Reg#(Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))) refBlock <- mkRegU();
	Reg#(Bool) referenceBlockStored <- mkReg(False); 

	// Modules that make the different operations
    LoadBlock#(imageWidth, pb, npixelst, pd, pixelWidth) loadRefBlock <- mkLoadBlock(ddr3_user);
	LoadBlock#(imageWidth, pb, npixelst, pd, pixelWidth) loadCompBlock <- mkLoadBlock(ddr3_user);
	ComputeScore#(npixelst, pd, pixelWidth) cs <- mkComputeScore();
	ComputeDistance#(pb, fpbi, fpbf) cd <- mkComputeDistance(real_world_cte);
	UpdateScore#(pb, npixelst, pd, pixelWidth) us <- mkUpdateScore();	
	
	// This rules keeps asking for blocks to be loaded until
	// we have loaded all the necessary blocks in the search area
	rule retrieveBlock if (loadCounter < fromInteger(valueOf(searchAreaUInt)));
		let xy = inFIFO.first();
		
		if (referenceBlockLoaded == False) begin
			loadRefBlock.request.put(xy);
			loadCompBlock.request.put(xy);
			referenceBlockLoaded <= True;
		end else begin
			XYPoint#(pb) p = ?;
			p.x = xy.x + loadCounter;
			p.y = xy.y;
			loadCompBlock.request.put(p);
		end
		loadCounter <= loadCounter + 1;
	endrule

	rule computeScoreRule if (compCounter < fromInteger(valueOf(searchAreaUInt)));
		if (referenceBlockStored == False) begin
			let b <- loadRefBlock.response.get();
			let c <- loadCompBlock.response.get();
			//$display("Ref Block: ", b);
			//$display("Comp block: ", c);
			BlockPair#(npixelst, pd, pixelWidth) bp;
			bp.refBlock = b;
			bp.compBlock = c;
			cs.request.put(bp);
			refBlock <= b;
			referenceBlockStored <= True;
		end else begin
			let c <- loadCompBlock.response.get();
			BlockPair#(npixelst, pd, pixelWidth) bp;
			bp.refBlock = refBlock;
			bp.compBlock = c;
			//$display("Ref Block: ", refBlock);
			//$display("Comp block: ", c);
			cs.request.put(bp);
		end
	endrule

	rule updateScoreRule if (compCounter < fromInteger(valueOf(searchAreaUInt)));
		let sc <- cs.response.get();
		$display("Block score is: ", sc);
		ScoreDistanceT#(pb, npixelst, pd, pixelWidth) sd;
		sd.score = sc;
		sd.distance = compCounter;
		us.request.put(sd);
		compCounter <= compCounter+1;
	endrule

	rule computeRealWorldDistanceRule if (compCounter == fromInteger(valueOf(searchAreaUInt)));
		// If we are here, it means we have completed the search over the whole search area.
		let bd <- us.response.get();
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
		inFIFO.deq();
	endrule

	interface Put request = toPut(inFIFO);

	interface Get response = toGet(realDistances);
endmodule
