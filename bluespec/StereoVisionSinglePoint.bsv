// This file contains the interface and implementation of the block that performs the full StereoVision for
// one image point

import FIFO::*;
import Vector::*;
import FixedPoint::*;
import XYPoint::*;
import Pixel::*;
import ComputeScore::*;
import ClientServer::*;
import ComputeDistance::*;
import GetPut::*;
import UpdateScore::*;
import LoadBlocks::*;
import DDR3ReaderWrapper::*;
import DDR3User::*;
import XYPointDistance::*;
import XYPoint::*;

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
	Vector#(3, FixedPoint#(fpbi, fpbf))
) StereoVisionSinglePoint#(numeric type compBlockDramOffset, numeric type imageWidth, numeric type pb, numeric type searchArea, numeric type npixelst, numeric type pd, numeric type pixelWidth, numeric type fpbi, numeric type fpbf);


module mkStereoVisionSinglePoint(
	DDR3ReaderWrapper ddr3_user,
	FixedPoint#(fpbi, fpbf) focal_distance,
	FixedPoint#(fpbi, fpbf) real_world_cte,
	StereoVisionSinglePoint#(compBlockDramOffset, imageWidth, pb, searchArea, npixelst, pd, pixelWidth, fpbi, fpbf) ifc
)	provisos(
		Add#(1, a__, TMul#(npixelst, npixelst))
		, Add#(b__, pb, TAdd#(DDR3_Addr_Size, TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)))))
		, Add#(c__, pb, 26)
		, Add#(TAdd#(pb, 1), d__, fpbi)
	);

	FIFO#(Vector#(3, FixedPoint#(fpbi, fpbf))) realDistances <- mkFIFO();
	FIFO#(XYPoint#(pb)) inFIFO <- mkFIFO();

	Reg#(Bool) refBlockRequested <- mkReg(False);

	// Counter to keep track of the number of blocks we have loaded in memory
	Reg#(UInt#(pb)) loadCounter <- mkReg(0);
	// Counter to keep track of the number of blocks that have been processed
	Reg#(UInt#(pb)) compCounter <- mkReg(0);

	// Register to hold the reference block
	Reg#(Maybe#(Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)))) refBlock <- mkReg(tagged Invalid);

	// Modules that make the different operations
	LoadBlocks#(0,                   imageWidth, pb, npixelst, pd, pixelWidth) loadRefBlock <- mkLoadBlocks(ddr3_user);
	LoadBlocks#(compBlockDramOffset, imageWidth, pb, npixelst, pd, pixelWidth) loadCompBlock <- mkLoadBlocks(ddr3_user);
	ComputeScore#(npixelst, pd, pixelWidth) cs <- mkComputeScore();
	ComputeDistance#(pb, fpbi, fpbf) cd <- mkComputeDistance(focal_distance, real_world_cte);
	UpdateScore#(pb, npixelst, pd, pixelWidth) us <- mkUpdateScore();

	rule requestRefBlock if (!refBlockRequested);
		$display("Requesting ref block");
		let xy = inFIFO.first();
		loadRefBlock.request.put(xy);
		refBlockRequested <= True;
	endrule

	rule storeRefBlock;
		$display("Receiving ref block");
		let b <- loadRefBlock.response.get();
		// $display("Ref Block: ", b);
		refBlock <= tagged Valid b;
	endrule

	// This rules keeps asking for blocks to be loaded until
	// we have loaded all the necessary blocks in the search area
	rule requestCompBlock if (isValid(refBlock) && loadCounter < fromInteger(valueOf(searchArea)));  // only request the comp block if we have the ref block, so we can deque comp ASAP
		XYPoint#(pb) p = ?;
		let xy = inFIFO.first();
		p.x = xy.x + loadCounter;
		p.y = xy.y;
		loadCompBlock.request.put(p);
		loadCounter <= loadCounter + 1;
		// $display("Comp Block Counter is: ", loadCounter);
	endrule



	rule computeScoreRule if (isValid(refBlock));  // guard should always be true whenever loadCompBlock has a response
		// $display("Receiving comp block");
		let c <- loadCompBlock.response.get();
		// $display("Comp block: ", c);

		BlockPair#(npixelst, pd, pixelWidth) bp;
		bp.compBlock = c;
		bp.refBlock = fromMaybe(?, refBlock);
		// $display("Comp block put for comparison");
		cs.request.put(bp);
	endrule

	rule updateScoreRule if (compCounter < fromInteger(valueOf(searchArea)));
		// $display("updating score");
		let sc <- cs.response.get();
		// $display("Block score is: ", sc);
		ScoreDistanceT#(pb, npixelst, pd, pixelWidth) sd;
		sd.score = sc;
		sd.distance = compCounter;
		us.request.put(sd);
		compCounter <= compCounter+1;
		// $display("Comp counter is ", compCounter);
	endrule

	rule computeRealWorldDistanceRule if (compCounter == fromInteger(valueOf(searchArea)));
		$display("computing real world distance");
		// If we are here, it means we have completed the search over the whole search area.
		let bd <- us.response.get();  // getting also invalidates the response
		// $display("got response");
		// $display("Best distance is: ", bd);
		XYPointDistance#(pb) pointDistance = ?;
		pointDistance.point = inFIFO.first();
		pointDistance.distance = bd;
		cd.request.put(pointDistance);
		compCounter <= compCounter+1;
		// $display("put compute distance request");
	endrule

	rule finishUp;
		$display("finishing up");
		let d <- cd.response.get();
		// $display("Computed x is: ", fshow(d[0]));
		// $display("Computed y is: ", fshow(d[1]));
		// $display("Computed z is: ", fshow(d[2]));
		realDistances.enq(d);
		// Restart the counters
		// $display("Dequeued");
		loadCounter <= 0;
		compCounter <= 0;
		refBlockRequested <= False;
		refBlock <= tagged Invalid;
		inFIFO.deq();
	endrule

	interface Put request = toPut(inFIFO);

	interface Get response = toGet(realDistances);
endmodule
