import XYPoint::*;

typedef struct {
	XYPoint#(pb) point;
	UInt#(pb) distance;
} XYPointDistance#(numeric type pb) deriving(Bits, Eq);

function XYPointDistance#(pb) mkXYPointDistance(XYPoint#(pb) point, UInt#(pb) distance);
    XYPointDistance#(pb) x;
    x.point = point;
    x.distance = distance;
    return x;
endfunction
