import Types::*;
import ComputeDistance::*;
import UpdateScore::*;
import ComputeScore::*;
import FixedPoint::*;
import LoadBlocks::*;
import StereoVisionSinglePoint::*;
import StereoVisionMultiplePoints::*;
import DDR3User::*;
import DDR3ReaderWrapper::*; 
import DDR3Sim::*;


typedef ComputeDistance#(PB, FPBI, FPBF) SynthComputeDistance;
(* synthesize *)
module mkSynthComputeDistance(FixedPoint#(FPBI, FPBF) real_world_cte, SynthComputeDistance ifc);
    SynthComputeDistance x <- mkComputeDistance(focal_dist, real_world_cte);
    return x;
endmodule

typedef ComputeScore#(NPIXELS, PD, PIXELWIDTH) SynthComputeScore;
(* synthesize *)
module mkSynthComputeScore(SynthComputeScore);
    SynthComputeScore x <- mkComputeScore();
    return x;
endmodule

typedef LoadBlocks#(0, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) SynthLoadRefBlock;
(* synthesize *)
module mkSynthLoadRefBlock(SynthLoadRefBlock);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);
    LoadBlocks#(0, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) x <- mkLoadBlocks(readerWrapper);
    return x;
endmodule


typedef LoadBlocks#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) SynthLoadCompBlocks;
(* synthesize *)
module mkSynthLoadCompBlock(SynthLoadCompBlocks);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);
    LoadBlocks#(0, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) x <- mkLoadBlocks(readerWrapper);
    return x;
endmodule

typedef StereoVisionSinglePoint#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionSinglePoint;
(* synthesize *)
module mkSynthStereoVisionSinglePoint(FixedPoint#(FPBI, FPBF) focal_distance, FixedPoint#(FPBI, FPBF) real_world_cte, SynthStereoVisionSinglePoint ifc);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);
    StereoVisionSinglePoint#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionSinglePoint(readerWrapper, focal_distance, real_world_cte);
    return x;
endmodule

typedef StereoVisionMultiplePoints#(N, COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionMultiplePoints;
(* synthesize *)
module mkSynthStereoVisionMultiplePoints(FixedPoint#(FPBI, FPBF) focal_distance, FixedPoint#(FPBI, FPBF) real_world_cte, SynthStereoVisionMultiplePoints ifc);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    DDR3ReaderWrapper readerWrapper <- mkDDR3ReaderWrapper(ddr3_user);
    StereoVisionMultiplePoints#(N, COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionMultiplePoints(readerWrapper, focal_distance, real_world_cte);
    return x;
endmodule

(* synthesize *)
module mkSynthUpdateScore(UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH));
	UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH) x <- mkUpdateScore();
	return x;
endmodule
