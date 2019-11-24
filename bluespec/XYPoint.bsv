typedef struct {
    UInt#(pb) x;
    UInt#(pb) y;
} XYPoint#(numeric type pb) deriving(Bits, Eq);

function XYPoint#(pb) mkXYPoint(UInt#(pb) x, UInt#(pb) y);
    XYPoint#(pb) point;
    point.x = x;
    point.y = y;
    return point;
endfunction

instance FShow#(XYPoint#(pb));
    function Fmt fshow (XYPoint#(pb) value);
    return ($format("", value.x, value.y));
    endfunction
endinstance