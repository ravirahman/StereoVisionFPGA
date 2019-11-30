import Vector::*;
import FIFO::*;
import ClientServer::*;
import XYPoint::*;
import GetPut::*;
import Pixel::*;
import DDR3User::*;
import Assert::*;

typedef TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)) NumPixelsPerLine#(numeric type pd, numeric type pixelWidth);

interface LoadBlocks#(numeric type dramOffset, numeric type imageWidth, numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);
	interface Put#(XYPoint#(pb)) request;
	interface Get#(Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))) response;
	method Action setMemoryStatus(Bool memoryStatus);
	method Bool getMemoryStatus();
endinterface

module mkLoadBlocks(DDR3_6375User ddr3_user, LoadBlocks#(dramOffset, imageWidth, pb, npixelst, pd, pixelWidth) ifc)
	provisos(
		Add#(a__, pb, DDR3_Addr_Size)
		, Add#(b__, pb, TAdd#(DDR3_Addr_Size, TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)))))
	);
	// staticAssert(valueOf(TExp#(TLog#(SizeOf#(Pixel#(pd, pixelWidth))))) == valueOf(SizeOf#(Pixel#(pd, pixelWidth))), "SizeOf#(Pixel#(pd, pixelWidth)) must be an exact power of two");
	FIFO#(XYPoint#(pb)) inFIFO <- mkFIFO();
	FIFO#(XYPoint#(pb)) poiFIFO <- mkFIFO();

	Reg#(UInt#(pb)) currentReqDx <- mkReg(0);
	Reg#(UInt#(pb)) currentReqDy <- mkReg(0);
	Reg#(Bool) memoryLoaded <- mkReg(False);

	Maybe#(Pixel#(pd, pixelWidth)) invalidPixel = tagged Invalid;
	
	Vector#(TMul#(npixelst, npixelst), Reg#(Maybe#(Pixel#(pd, pixelWidth)))) blockReg <- replicateM(mkReg(invalidPixel));

	FIFO#(Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))) outFIFO <- mkFIFO();

	function DDR3_Addr getDDR3AddrFromXYPoint(XYPoint#(pb) point);
		UInt#(26) rowMajorLoc = zeroExtend(point.y) * fromInteger(valueOf(imageWidth));
		rowMajorLoc = rowMajorLoc + zeroExtend(point.x);
		DDR3_Addr dramRow = pack((rowMajorLoc >> fromInteger(valueOf(TLog#(NumPixelsPerLine#(pd, pixelWidth))))) + fromInteger(valueOf(dramOffset)));  // division
		return zeroExtend(dramRow);
	endfunction

	function XYPoint#(pb) getXYPointFromDDR3Addr(DDR3_Addr addr);
		let locInPixelRowMajor = (unpack(addr) - fromInteger(valueOf(dramOffset))) << fromInteger(valueOf(TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)))));
		XYPoint#(pb) p;
		p.y = truncate(locInPixelRowMajor / fromInteger(valueOf(imageWidth)));
		p.x = truncate(locInPixelRowMajor % fromInteger(valueOf(imageWidth)));
		return p;
	endfunction

	function Bool areAllValid();
		Bool allValid = True;
		for (Integer i = 0; i < valueOf(TMul#(npixelst, npixelst)); i = i + 1) begin
			if (!isValid(blockReg[i])) begin
				allValid = False;
			end
		end
		return allValid;
	endfunction

	rule requestFromDRAM if (memoryLoaded);
		let xy = inFIFO.first();
		if (currentReqDx == 0 && currentReqDy == 0) begin
			//$display("Ruesting cachelines from dram for point", fshow(xy));
			poiFIFO.enq(xy);
		end
		XYPoint#(pb) poi;
		poi.x = xy.x + currentReqDx;
		poi.y = xy.y + currentReqDy;
		DDR3_Addr location = getDDR3AddrFromXYPoint(poi);
		$display($format("Requesting address %d for point", location, fshow(poi)));
		let req = DDR3_LineReq{ write: False, line_addr: truncate(location), data_in: 0};
		ddr3_user.request.put(req);
		if (currentReqDx + 1 < fromInteger(valueOf(npixelst))) begin
			currentReqDx <= currentReqDx + fromInteger(valueOf(NumPixelsPerLine#(pd, pixelWidth)));
		end else if (currentReqDy + 1 < fromInteger(valueOf(npixelst))) begin
			currentReqDx <= 0;
			currentReqDy <= currentReqDy + 1;
		end else begin
			inFIFO.deq();
			$display("Finished request");
			currentReqDx <= 0;
			currentReqDy <= 0;
		end
	endrule

	rule responseFromDRAM (!areAllValid());
		let poi = poiFIFO.first();
		let resp <- ddr3_user.response.get();
		let drampoint = getXYPointFromDDR3Addr(resp.line_addr);
		$display($format("Processing response for address %d in context of poi", resp.line_addr, fshow(poi)));
		// $display("Calculated point for start of block", fshow(drampoint));
		Integer j = 0;
		for (Integer i = 0; i < valueOf(NumPixelsPerLine#(pd, pixelWidth)); i = i + 1) begin
			// do we want this pixel?
			if (poi.x <= drampoint.x + fromInteger(i)) begin
				if (drampoint.x + fromInteger(i) < poi.x + fromInteger(valueOf(npixelst))) begin
					if (poi.y <= drampoint.y) begin
						if (drampoint.y < poi.y + fromInteger(valueOf(npixelst))) begin
							// $display("keeping pixel at (%d,%d)", drampoint.x + fromInteger(i), drampoint.y);
							let startI = i * valueOf(TMul#(pd, pixelWidth));
							let endI = startI + valueOf(TSub#(TMul#(pd, pixelWidth), 1));
							let pixelAsBytes = resp.data_out[endI:startI];
							Pixel#(pd, pixelWidth) pixel = unpack(pixelAsBytes);
							// $display("pixel value: ", fshow(pixel));
							let blockPixelI = (drampoint.y - poi.y) * fromInteger(valueOf(npixelst)) + (drampoint.x + fromInteger(i) - poi.x);
							blockReg[blockPixelI] <= tagged Valid pixel;
						end
					end
				end
			end
		end
	endrule

	rule finishProcessing (areAllValid());
		$display("Finishing and returning");
		Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)) answer;
		for (Integer i = 0; i < valueOf(TMul#(npixelst, npixelst)); i = i + 1) begin
			answer[i] = fromMaybe(replicate(0), blockReg[i]);
			blockReg[i] <= tagged Invalid;
		end
		outFIFO.enq(answer);
		poiFIFO.deq();
	endrule

	method Action setMemoryStatus(Bool memoryStatus);
		memoryLoaded <= memoryStatus;
	endmethod

	method Bool getMemoryStatus();
		return memoryLoaded;
	endmethod

	interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule
