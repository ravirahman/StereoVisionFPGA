typedef struct {
    UInt#(pb) x;
    UInt#(pb) y;
} XYPoint#(numeric type pb) deriving(Bits, Eq);
