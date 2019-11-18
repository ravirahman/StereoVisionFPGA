
// This file defines all the parameters necessary for the implementation of the StereoVision system

import FixedPoint::*;

// Number of bits to specify the image point coordinates (both x and y)
typedef 6 PB;

// Number of bits for the integer part of the fixed point number giving the real world distance
typedef 8 FPBI;
// Number of bits for the fractional part of the fixed point number giving the real world distance
typedef 8 FPBF;

// Number of bits per pixel
typedef 8 PIXELWIDTH;

// Number of pixels contained in a block
typedef 64 NPIXELS;

// Number of bits for the score bewteen two block
typedef 8 SB;

// Number of Single Points that we calculate in parallel
typedef 2 N;

// Constant defining the camera system (necessary to compute the real world distance from the
// pixel distance). This constant corresponds to A = focal_distance*distance_between_cameras/pixel_pitch
// In our case, f = 12e-3m , distance_cameras = 100e-3m , pixel_pitch = 8.93e-6m
FixedPoint#(FPBI, FPBF) real_world_cte = 134.3785;

// Search area in pixels
typedef 3 SEARCHAREA;

UInt#(PB) searchAreaUInt = 3;
