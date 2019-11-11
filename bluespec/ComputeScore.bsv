// This file contains the interface and implementation of the block that computes the score between two given blocks

//import Types::*;
import Vector::*;
import FIFO::*;

interface ComputeScore#(numeric type sbt, numeric type npixelst, numeric type pixelwidtht);
	method Action loadBlocks ( Vector#(npixelst, UInt#(pixelwidtht)) refBlock,
				   Vector#(npixelst, UInt#(pixelwidtht)) compBlock);
        method ActionValue#(UInt#(sbt)) getScore;
endinterface


module mkComputeScore(ComputeScore#(sbt, npixelst, pixelwidtht)) provisos (Add#(a__, pixelwidtht, sbt), Add#(1, b__, npixelst));

	FIFO#(Vector#(npixelst, UInt#(pixelwidtht))) refBlocks <- mkFIFO();
        FIFO#(Vector#(npixelst, UInt#(pixelwidtht))) compBlocks <- mkFIFO();
        FIFO#(UInt#(sbt)) scores <- mkFIFO();

	function UInt#(sbt) abs_diff (UInt#(pixelwidtht) a, UInt#(pixelwidtht) b);
		UInt#(pixelwidtht) df = ?;
		if (a>b) begin
			df = a-b;
		end else begin
			df = b-a;
		end
		UInt#(sbt) df_ext = extend(df);
		return df_ext;
	endfunction

	rule compute (True);

		let refB = refBlocks.first();
                let compB = compBlocks.first();
		refBlocks.deq();
		compBlocks.deq();

		let score_vec = zipWith(abs_diff, refB, compB);
		let score = fold(\+ , score_vec);
		scores.enq(score);		

	endrule


	method Action loadBlocks( Vector#(npixelst, UInt#(pixelwidtht)) refBlock,
				  Vector#(npixelst, UInt#(pixelwidtht)) compBlock);
	
		refBlocks.enq(refBlock);
		compBlocks.enq(compBlock);
	
	endmethod	

	method ActionValue#(UInt#(sbt)) getScore();
	
		scores.deq();
		return scores.first();

	endmethod
endmodule
