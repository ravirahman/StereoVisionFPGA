typedef struct {
    UInt#(pb) x;
    UInt#(pb) y;
} XYPoint#(numeric type pb) deriving(Bits, Eq);

instance FShow#(XYPoint#(pb));
    function Fmt fshow (XYPoint#(pb) value);
    return ($format("", value.x, value.y));
    endfunction
endinstance