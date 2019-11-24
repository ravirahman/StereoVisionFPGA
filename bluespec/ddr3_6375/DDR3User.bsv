import Connectable::*;
import GetPut::*;
import FIFO::*;
import Clocks::*;
import ClientServer::*;
import DDR3Common::*;
import DDR3Controller::*;
import Vector::*;

typedef Bit#(26)  DDR3_Addr;
typedef Bit#(512) DDR3_Line;
typedef SizeOf#(DDR3_Addr) DDR3_Addr_Size;
typedef SizeOf#(DDR3_Line) DDR3_Line_Size;

typedef struct {
    Bool write;
    DDR3_Addr line_addr;
    DDR3_Line data_in;
} DDR3_LineReq deriving (Bits, Eq, FShow);

typedef struct {
    DDR3_Addr line_addr;
    DDR3_Line data_out;
} DDR3_LineRes deriving (Bits, Eq, FShow);

typedef Server#(DDR3_LineReq, DDR3_LineRes) DDR3_6375User;

module mkDDR3WrapperSim#(DDR3_User_VC707_1GB ddr_usr) (DDR3_6375User);
    FIFO#(DDR3_Addr) lineAddrFIFO <- mkSizedFIFO(1024);

    interface Put request;
        method Action put(DDR3_LineReq req);
            ddr_usr.request({req.line_addr, 3'b0}, (req.write)?-1:0, req.data_in);
            if (req.write == False) begin
                lineAddrFIFO.enq(req.line_addr);
            end
        endmethod
    endinterface

    interface Get response;
        method ActionValue#(DDR3_LineRes) get();
            DDR3_Line data <- ddr_usr.read_data();
            DDR3_Addr line_addr = lineAddrFIFO.first();
            DDR3_LineRes answer = ?;
            answer.line_addr = line_addr;
            answer.data_out = data;
            lineAddrFIFO.deq();
            return answer;
        endmethod
    endinterface
endmodule

module mkDDR3WrapperSync#(DDR3_User_VC707_1GB ddr_usr) (DDR3_6375User);
    FIFO#(DDR3_Addr) lineAddrFIFO <- mkFIFO();

    // crossing request from the current clock to the controller user clock
    SyncFIFOIfc#(DDR3_LineReq) reqSync <- mkSyncFIFOFromCC(8, ddr_usr.clock);

    // crossing resp from the controller user clock to my clock
    SyncFIFOIfc#(DDR3_Line) respSync <- mkSyncFIFOToCC(8, ddr_usr.clock, ddr_usr.reset_n);

    rule proc_req;
        let req <- toGet(reqSync).get;
        ddr_usr.request({req.line_addr, 3'b0}, (req.write)?-1:0, req.data_in);
    endrule

    rule proc_resp;
        let resp <- ddr_usr.read_data;
        respSync.enq(resp);
    endrule
    
    interface Put request;
        method Action put(DDR3_LineReq req);
            reqSync.enq(req);
            if (req.write == False) begin
                lineAddrFIFO.enq(req.line_addr);
            end
        endmethod
    endinterface

    interface Get response;
        method ActionValue#(DDR3_LineRes) get();
            let data = respSync.first();
            respSync.deq();
            let addr = lineAddrFIFO.first();
            lineAddrFIFO.deq();
            DDR3_LineRes answer = ?;
            answer.line_addr = addr;
            answer.data_out = data;
            return answer;
        endmethod
    endinterface
endmodule
