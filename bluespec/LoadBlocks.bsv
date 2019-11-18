// This file contains the interface and implementation of the blocks that load image blocks given the center coordinates,
// both for the reference and the compare images.

import Vector::*;
import FIFO::*;


interface LoadBlock#(numeric type pbt, numeric type npixelst, numeric type pixelwidtht);
	method Action putImagePoint (UInt#(pbt) x, UInt#(pbt) y);
	method ActionValue#(Vector#(npixelst, UInt#(pixelwidtht))) getBlock;
endinterface


module mkLoadBlock(LoadBlock#(pbt, npixelst, pixelwidtht));


	FIFO#(UInt#(pbt)) xs <- mkFIFO();
	FIFO#(UInt#(pbt)) ys <- mkFIFO();
        FIFO#(Vector#(npixelst, UInt#(pixelwidtht))) blocks <- mkFIFO();


	rule compute (True);

		let x = xs.first();
		let y = ys.first();
		xs.deq();
		ys.deq();
		
		// Here, we would need to talk to the cache, memory to get the 
		// block. For now, let´s make up the block so that we can
		// test everything.
                Vector#(npixelst, UInt#(pixelwidtht)) block = newVector; 
		
		for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
			block[i] = 1;
		end

		//$display("block load ref : ", block[0]);

		blocks.enq(block);	
				
	endrule


	method Action putImagePoint( UInt#(pbt) x, UInt#(pbt) y);
		//$display("y enqueued: ", y);	
		xs.enq(x);
		ys.enq(y);

	endmethod	

	method ActionValue#(Vector#(npixelst, UInt#(pixelwidtht))) getBlock();
	
		blocks.deq();
		return blocks.first();

	endmethod


endmodule



module mkLoadCompBlock(LoadBlock#(pbt, npixelst, pixelwidtht));


	FIFO#(UInt#(pbt)) xs <- mkFIFO();
	FIFO#(UInt#(pbt)) ys <- mkFIFO();
        FIFO#(Vector#(npixelst, UInt#(pixelwidtht))) blocks <- mkFIFO();


	rule compute (True);

		let x = xs.first();
		let y = ys.first();
		xs.deq();
		ys.deq();
		
		// Here, we would need to talk to the cache, memory to get the 
		// block. For now, let´s make up the block so that we can
		// test everything.
                Vector#(npixelst, UInt#(pixelwidtht)) block = newVector; 
		
		//$display("x: ", x);
		
		if (x == 10) begin
			if (y == 0) begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 2;
				end
			end else begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 3;
				end
			end
		end else if (x == 11) begin		
			if (y == 0) begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 1;
				end
			end else begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 3;
				end
			end
		end else begin
		
			if (y == 0) begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 5;
				end
			end else begin
				for (Integer i = 0; i < valueOf(npixelst); i = i+1) begin
					block[i] = 1;
				end
			end
		end

		//$display("block load comp ", block[0]);

		blocks.enq(block);	
				
	endrule


	method Action putImagePoint( UInt#(pbt) x, UInt#(pbt) y);
		//$display("y enqueued: ", y);	
		xs.enq(x);
		ys.enq(y);

	endmethod	

	method ActionValue#(Vector#(npixelst, UInt#(pixelwidtht))) getBlock();
	
		blocks.deq();
		return blocks.first();

	endmethod


endmodule
