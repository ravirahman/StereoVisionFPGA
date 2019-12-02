import Connectable::*;
import GetPut::*;
import FIFO::*;
import ClientServer::*;
import DDR3User::*;


interface DDR3ReaderWrapper;
    interface Put#(DDR3_LineReq) request;
    method Maybe#(DDR3_LineRes) get;
endinterface

typedef struct {
    DDR3_Addr addr;
    DDR3_Line data;
} DDR3_LineRes deriving (Bits, Eq, FShow);

// this module stores the latest ddr3 response, with address, to a register for reading by any listener. 
// response are guaranteed to be available for at most one clock cycle. You must be ready to receive as soon
// as the next clock cycle after making a request. requets are guaranteed to be processed in order
module mkDDR3ReaderWrapper(DDR3_6375User ddr3_user, DDR3ReaderWrapper ifc);
    FIFO#(DDR3_Addr) lineAddrFIFO <- mkSizedFIFO(1024);

    Reg#(Maybe#(DDR3_LineRes)) ddr3Results <- mkReg(tagged Invalid);

    rule storeResponses if (True);
        DDR3_Line data <- ddr3_user.response.get();
        DDR3_Addr line_addr = lineAddrFIFO.first();
        // $display("Storing dram line with address ", line_addr);
        DDR3_LineRes answer = ?;
        answer.addr = line_addr;
        answer.data = data;

        ddr3Results <= tagged Valid answer;
        lineAddrFIFO.deq();
    endrule
    
    interface Put request;
        method Action put(DDR3_LineReq req);
            if (req.write == True) begin
                $display("!!!ERROR: You attempted to write from the read-only interface!!!");
            end else begin
                // $display("Got request for dram line with address", req.line_addr);
                ddr3_user.request.put(req);
                lineAddrFIFO.enq(req.line_addr);
            end
        endmethod
    endinterface

    method Maybe#(DDR3_LineRes) get();
        return ddr3Results;
    endmethod
endmodule
