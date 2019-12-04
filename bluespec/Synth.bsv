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
import Vector::*;


typedef ComputeDistance#(PB, SEARCHAREA, NPIXELS, FPBI, FPBF) SynthComputeDistance;
(* synthesize *)
module mkSynthComputeDistance(SynthComputeDistance ifc);
    ComputeDistance#(PB, SEARCHAREA, NPIXELS, FPBI, FPBF) x <- mkComputeDistance(focal_dist, real_world_cte);
    return x;
endmodule

typedef ComputeScore#(NPIXELS, PD, PIXELWIDTH) SynthComputeScore;
(* synthesize *)
module mkSynthComputeScore(SynthComputeScore);
    SynthComputeScore x <- mkComputeScore();
    return x;
endmodule

typedef UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH) SynthUpdateScore;
(* synthesize *)
module mkSynthUpdateScore(SynthUpdateScore);
	UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH) x <- mkUpdateScore();
	return x;
endmodule


typedef StereoVisionSinglePoint#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionSinglePoint;
module mkSynthStereoVisionSinglePoint(DDR3ReaderWrapper readerWrapper, SynthStereoVisionSinglePoint ifc);
    LoadBlocks#(0, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) loadRefBlock <- mkLoadBlocks(readerWrapper);
    LoadBlocks#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) loadCompBlock <- mkLoadBlocks(readerWrapper);
    SynthComputeScore cs <- mkSynthComputeScore();
    SynthComputeDistance cd <- mkSynthComputeDistance();
    SynthUpdateScore us <- mkSynthUpdateScore();
    StereoVisionSinglePoint#(COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionSinglePointInternal(
        loadRefBlock,
        loadCompBlock,
        cs,
        cd,
        us);
    return x;
endmodule

typedef StereoVisionMultiplePoints#(N, COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionMultiplePoints;
module mkSynthStereoVisionMultiplePoints(DDR3ReaderWrapper readerWrapper, SynthStereoVisionMultiplePoints ifc);
    Vector#(N, SynthStereoVisionSinglePoint) stereoVisionModules <- replicateM(mkSynthStereoVisionSinglePoint(readerWrapper));
    StereoVisionMultiplePoints#(N, COMP_BLOCK_DRAM_OFFSET, IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionMultiplePointsInternal(stereoVisionModules);
    return x;
endmodule
