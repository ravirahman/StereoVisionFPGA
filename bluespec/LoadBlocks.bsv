// This file contains the interface and implementation of the blocks that load image blocks given the center coordinates,
// both for the reference and the compare images.

import Vector::*;
import FIFO::*;
import ClientServer::*;
import XYPoint::*;
import GetPut::*;
import Pixel::*;
import DDR3User::*;
import Assert::*;

typedef TDiv#(DDR3_Line_Size, SizeOf#(Pixel#(pd, pixelWidth))) PixelsPerLineT#(numeric type pd, numeric type pixelWidth);
typedef UInt#(TAdd#(TLog#(PixelsPerLineT#(pd, pixelWidth)), 1)) OffsetT#(numeric type pd, numeric type pixelWidth);  // adding 1 extra bit just to be safe


typedef struct {
	DDR3_Addr line_addr; // the dram line where the data is stored
	OffsetT#(pd, pixelWidth) offset;  // the offset in the dram line where the data begins
} DRAMLocation#(numeric type pd, numeric type pixelWidth) deriving(Bits, Eq);


typedef Server#(
	XYPoint#(pb),
	Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))
) LoadBlock#(numeric type imageWidth, numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);

module mkLoadBlock(DDR3_6375User ddr3_user, LoadBlock#(imageWidth, pb, npixelst, pd, pixelWidth) ifc)
	provisos(
		Add#(a__, pb, DDR3_Addr_Size)
		, Add#(b__, TAdd#(TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth))), 1), pb)
	);
	// staticAssert(valueOf(TExp#(TLog#(SizeOf#(Pixel#(pd, pixelWidth))))) == valueOf(SizeOf#(Pixel#(pd, pixelWidth))), "SizeOf#(Pixel#(pd, pixelWidth)) must be an exact power of two");
	FIFO#(XYPoint#(pb)) inFIFO <- mkFIFO();
	FIFO#(XYPoint#(pb)) poiFIFO <- mkFIFO();
	

	// Vector#(TMul#(npixelst, npixelst), Reg#(Pixel#(pd, pixelWidth))) blockReg <- replicateM(mkRegU());
	// Reg#(OffsetT#(pd, pixelWidth)) blockPixelI <- mkReg(0); // records the index of the to-be-filled next pixel

	FIFO#(Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))) outFIFO <- mkFIFO();

	function DRAMLocation#(pd, pixelWidth) getDRAMLocationFromXYPoint(XYPoint#(pb) point);
		let rowMajorLoc = point.y * fromInteger(valueOf(imageWidth)) + point.x;
		let dramRow = pack(rowMajorLoc) >> fromInteger(valueOf(TLog#(PixelsPerLineT#(pd, pixelWidth))));
		DRAMLocation#(pd, pixelWidth) loc;
		loc.line_addr = zeroExtend(dramRow);  // division
		OffsetT#(pd, pixelWidth) offset = truncate(rowMajorLoc >> fromInteger(valueOf(TSub#(DDR3_Line_Size, TLog#(PixelsPerLineT#(pd, pixelWidth)))))); // modulo
		loc.offset = offset;
		return loc;
	endfunction

	rule requestFromDRAM (True);
		let xy = inFIFO.first();
		inFIFO.deq();
		poiFIFO.enq(xy);
		for (Integer r = 0; r < valueOf(npixelst); r = r+1) begin
			for (Integer blockNum = 0; blockNum < valueOf(TAdd#(TDiv#(npixelst, PixelsPerLineT#(pd, pixelWidth)), 1)); blockNum = blockNum + 1) begin  // TODO do we need the extra +1?
				XYPoint#(pb) poi;
				poi.x = xy.x + fromInteger(r);
				poi.y = xy.y + fromInteger(blockNum * valueOf(PixelsPerLineT#(pd, pixelWidth)));
				DRAMLocation#(pd, pixelWidth) location = getDRAMLocationFromXYPoint(poi);
				let req = DDR3_LineReq{ write: False, line_addr: truncate(location.line_addr), data_in: 0};
				ddr3_user.request.put(req); // TODO
			end
		end
	endrule

	rule responseFromDRAM (True);
		let poi = poiFIFO.first();
		DRAMLocation#(pd, pixelWidth) dramLocation = getDRAMLocationFromXYPoint(poi);
		XYPoint#(pb) next_point;
		next_point.x = poi.x + zeroExtend(blockPixelI % fromInteger(valueOf(npixelst)));
		next_point.y = poi.y + zeroExtend(blockPixelI / fromInteger(valueOf(npixelst)));
		DRAMLocation#(pd, pixelWidth) ramloc = getDRAMLocationFromXYPoint(next_point);
		let resp <- ddr3_user.response.get();
		if (ramloc.line_addr == resp.line_addr) begin
			Integer j = 0;
			for (OffsetT#(pd, pixelWidth) i = 0; 
				i < fromInteger(valueOf(PixelsPerLineT#(pd, pixelWidth))) - ramloc.offset // didn't exceed the dram line
				&& blockPixelI + fromInteger(j) < fromInteger(valueOf(TMul#(npixelst, npixelst)))  // didn't exceed the block size
				&& ((j == 0) || ((blockPixelI + fromInteger(j)) % fromInteger(valueOf(npixelst)) != 0));  // didn't exceed the line
				i = i +1) begin
					let startI = i << fromInteger(valueOf(PixelsPerLineT#(pd, pixelWidth)));
					let endI = startI + fromInteger(valueOf(SizeOf#(Pixel#(pd, pixelWidth))));
					let pixelAsBytes = resp.data_out[startI:endI];
					Pixel#(pd, pixelWidth) pixel = unpack(pixelAsBytes);
					blockReg[blockPixelI + fromInteger(j)] <= pixel;
				j = j+1;
			end

			if (blockPixelI + fromInteger(j) == fromInteger(valueOf(npixelst))) begin
				Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)) answer;
				for (Integer i = 0; i < valueOf(TMul#(npixelst, npixelst)); i = i + 1) begin
					answer[i] = blockReg[i];
				end
				outFIFO.enq(answer);
				poiFIFO.deq();
			end

			blockPixelI <= (fromInteger(j) + blockPixelI) % fromInteger(valueOf(npixelst));
		end
	endrule

	interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule
