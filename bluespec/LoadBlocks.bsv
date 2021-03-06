import Vector::*;
import FIFO::*;
import ClientServer::*;
import XYPoint::*;
import GetPut::*;
import Pixel::*;
import DDR3ReaderWrapper::*;
import DDR3User::*;
import Assert::*;

typedef TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)) NumPixelsPerLine#(numeric type pd, numeric type pixelWidth);

typedef Server#(
	XYPoint#(pb),
	Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth))
) LoadBlocks#(numeric type dramOffset, numeric type imageWidth, numeric type pb, numeric type npixelst, numeric type pd, numeric type pixelWidth);

module mkLoadBlocks(DDR3ReaderWrapper ddr3_user, LoadBlocks#(dramOffset, imageWidth, pb, npixelst, pd, pixelWidth) ifc)
	provisos(
		Add#(a__, pb, DDR3_Addr_Size)
		, Add#(b__, pb, TAdd#(DDR3_Addr_Size, TLog#(TDiv#(DDR3_Line_Size, TMul#(pd, pixelWidth)))))
	);
	// staticAssert(valueOf(TExp#(TLog#(SizeOf#(Pixel#(pd, pixelWidth))))) == valueOf(SizeOf#(Pixel#(pd, pixelWidth))), "SizeOf#(Pixel#(pd, pixelWidth)) must be an exact power of two");
	FIFO#(XYPoint#(pb)) inFIFO <- mkFIFO();

	Reg#(UInt#(pb)) currentReqDx <- mkReg(0);
	Reg#(UInt#(pb)) currentReqDy <- mkReg(0);
	Reg#(Bool) finishedRequests <- mkReg(False);

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
		let locInPixelRowMajor = (unpack(addr) - fromInteger(valueOf(dramOffset))) << fromInteger(valueOf(TLog#(NumPixelsPerLine#(pd, pixelWidth))));
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

	rule requestFromDRAM if (!finishedRequests && !areAllValid());
		let xy = inFIFO.first();
		if (currentReqDx == 0 && currentReqDy == 0) begin
			// $display("Ruesting cachelines from dram for point", fshow(xy));
		end
		XYPoint#(pb) poi;
		poi.x = xy.x + currentReqDx;
		poi.y = xy.y + currentReqDy;
		DDR3_Addr location = getDDR3AddrFromXYPoint(poi);
		// $display("Requesting address %d for currentReqDx = %d, currentReqDy = %d, x y, poi", location, currentReqDx, currentReqDy, xy.x, xy.y, poi.x, poi.y);
		let req = DDR3_LineReq{ write: False, line_addr: truncate(location), data_in: 0};
		ddr3_user.request.put(req);
		if (currentReqDx + 1 < fromInteger(valueOf(npixelst))) begin
			currentReqDx <= currentReqDx + fromInteger(valueOf(NumPixelsPerLine#(pd, pixelWidth)));
		end else if (currentReqDy + 1 < fromInteger(valueOf(npixelst))) begin
			currentReqDx <= 0;
			currentReqDy <= currentReqDy + 1;
		end else begin
			finishedRequests <= True;
			// $display("Finished request for upper left point: ", fshow(xy));
		end
	endrule

	rule responseFromDRAM (!areAllValid());
		let poi = inFIFO.first();
		let maybeResp = ddr3_user.get();
		if (isValid(maybeResp)) begin
			let resp = fromMaybe(?, maybeResp);
			let drampoint = getXYPointFromDDR3Addr(resp.addr);
			// $display($format("Processing response for address %d in context of poi", resp.addr, fshow(poi)));
			let blockStartI = (drampoint.y - poi.y) * fromInteger(valueOf(npixelst));
			if (drampoint.x > poi.x) begin
				blockStartI = blockStartI + drampoint.x - poi.x;
			end
			for (Integer i = 0; i < valueOf(NumPixelsPerLine#(pd, pixelWidth)); i = i + 1) begin
				// do we want this pixel?
				if ((poi.x <= drampoint.x + fromInteger(i)) && (drampoint.x + fromInteger(i) < poi.x + fromInteger(valueOf(npixelst)))) begin
					if ((poi.y <= drampoint.y) && (drampoint.y < poi.y + fromInteger(valueOf(npixelst)))) begin
						//let startI = i * valueOf(TMul#(pd, pixelWidth));
						//let endI = startI + valueOf(TSub#(TMul#(pd, pixelWidth), 1));
						// $display("endIOffset is", i * valueOf(TMul#(pd, pixelWidth)));
						let endI = 511 - i * valueOf(TMul#(pd, pixelWidth));
						// $display("endI is", endI);
						// $display("startIoffset is ", valueOf(TSub#(TMul#(pd, pixelWidth), 1)));
						let startI = endI - valueOf(TSub#(TMul#(pd, pixelWidth), 1));
						// $display("startI is ", startI);
						Bit#(TMul#(pd, pixelWidth)) pixelAsBytes = resp.data[endI:startI];
						//let pixelAsBytesRev = reverseBits(pixelAsBytes);
						//$display("The retrieved pixel is ", pixelAsBytes);
						Pixel#(pd, pixelWidth) pixel = unpack(pixelAsBytes);
						let blockPixelI = (drampoint.y - poi.y) * fromInteger(valueOf(npixelst)) + (drampoint.x + fromInteger(i) - poi.x);
						// $display("block start: ", blockStartI);
						if (!isValid(blockReg[blockPixelI])) begin
							if (blockStartI == 0 || isValid(blockReg[blockStartI - 1])) begin
								//$display("keeping pixel at block %d, (%d,%d)", blockPixelI, drampoint.x + fromInteger(i), drampoint.y);
								blockReg[blockPixelI] <= tagged Valid pixel;
							end else begin
								//$display("skipping because out of order. blockStartI = %d; drampoint.x= %d; poi.x = %d", blockStartI, drampoint.x, poi.x);
							end
							end else begin
								//$display("skpping because already valid. blockPixelI: %d", blockPixelI);
							end
						end
					end
				end
		       end
	endrule

	rule finishProcessing (areAllValid());
		//$display("Finishing and returning");
		Vector#(TMul#(npixelst, npixelst), Pixel#(pd, pixelWidth)) answer;
		for (Integer i = 0; i < valueOf(TMul#(npixelst, npixelst)); i = i + 1) begin
			answer[i] = fromMaybe(replicate(0), blockReg[i]);
			blockReg[i] <= tagged Invalid;
		end
		outFIFO.enq(answer);
		inFIFO.deq();
		currentReqDx <= 0;
		currentReqDy <= 0;
		finishedRequests <= False;
	endrule

	interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule
