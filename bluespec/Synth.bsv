import Types::*;
import ComputeDistance::*;
import UpdateScore::*;
import ComputeScore::*;
import FixedPoint::*;
import LoadBlocks::*;
import StereoVisionSinglePoint::*;
import StereoVisionMultiplePoints::*;
import DDR3User::*; 
import DDR3Sim::*;


typedef ComputeDistance#(PB, FPBI, FPBF) SynthComputeDistance;
(* synthesize *)
module mkSynthComputeDistance(FixedPoint#(FPBI, FPBF) real_world_cte, SynthComputeDistance ifc);
    SynthComputeDistance x <- mkComputeDistance(real_world_cte);
    return x;
endmodule

typedef ComputeScore#(NPIXELS, PD, PIXELWIDTH) SynthComputeScore;
(* synthesize *)
module mkSynthComputeScore(SynthComputeScore);
    SynthComputeScore x <- mkComputeScore();
    return x;
endmodule

typedef LoadBlocks#(IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) SynthLoadBlocks;
(* synthesize *)
module mkSynthLoadBlocks(LoadBlocks#(IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH));
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    LoadBlocks#(IMAGEWIDTH, PB, NPIXELS, PD, PIXELWIDTH) x <- mkLoadBlocks(ddr3_user);
    return x;
endmodule

typedef StereoVisionSinglePoint#(IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionSinglePoint;
(* synthesize *)
module mkSynthStereoVisionSinglePoint(FixedPoint#(FPBI, FPBF) focal_distance, FixedPoint#(FPBI, FPBF) real_world_cte, SynthStereoVisionSinglePoint ifc);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    StereoVisionSinglePoint#(IMAGEWIDTH, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionSinglePoint(ddr3_user, focal_distance, real_world_cte);
    return x;
endmodule

typedef StereoVisionMultiplePoints#(IMAGEWIDTH, N, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) SynthStereoVisionMultiplePoints;
(* synthesize *)
module mkSynthStereoVisionMultiplePoints(FixedPoint#(FPBI, FPBF) focal_distance, FixedPoint#(FPBI, FPBF) real_world_cte, SynthStereoVisionMultiplePoints ifc);
    let ddr3_ctrl <- mkDDR3Simulator;
    // We are using wrapper for easy use
    DDR3_6375User ddr3_user <- mkDDR3WrapperSim(ddr3_ctrl);
    StereoVisionMultiplePoints#(IMAGEWIDTH, N, PB, SEARCHAREA, NPIXELS, PD, PIXELWIDTH, FPBI, FPBF) x <- mkStereoVisionMultiplePoints(focal_distance, ddr3_user, real_world_cte);
    return x;
endmodule

(* synthesize *)
module mkSynthUpdateScore(UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH));
	UpdateScore#(PB, NPIXELS, PD, PIXELWIDTH) x <- mkUpdateScore();
	return x;
endmodule
