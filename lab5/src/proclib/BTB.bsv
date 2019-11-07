import RegFile::*;
import Types::*;

interface NAP#(numeric type logn);
    method Word predictedNextPC(Word pc);
    method Action train(Word pc, Word nextPC);
endinterface

module mkBTB(NAP#(logn)) provisos (
    Add#(a__, logn, 32),
    Alias#(tagT, Bit#(TSub#(12, logn))),
    Alias#(indexT, Bit#(logn)));
    
    // typedef struct {
    //    Word nextPC;
    //    TagT tag;
    //    Bool valid;
    //    } BTBRow deriving (Bits, Eq, FShow);

    RegFile#(indexT, Tuple3#(Word, tagT, Bool)) btb_array <- mkRegFileFull;
    method Word predictedNextPC(Word pc);
        indexT index = truncate(pc >> 2);
        tagT tag = truncate(pc >> (valueOf(logn) + 2));
        let {row_nextPC, row_tag, row_valid} = btb_array.sub(index);
        if (row_tag == tag && row_valid) begin
            return row_nextPC;
        end else begin
            return pc + 4;
        end
    endmethod
    method Action train(Word pc, Word nextPC);
        indexT index = truncate(pc >> 2);
        tagT tag = truncate(pc >> (valueOf(logn) + 2));
        let {row_nextPC, row_tag, row_valid} = btb_array.sub(index);
        if (nextPC == pc + 4) begin
            if (row_tag == tag && row_valid) begin
                row_valid = False;
                btb_array.upd(index, tuple3(row_nextPC, row_tag, row_valid));
            end
        end else begin
            row_valid = True;
            row_tag = tag;
            row_nextPC = nextPC;
            btb_array.upd(index, tuple3(row_nextPC, row_tag, row_valid));
        end
    endmethod
endmodule
