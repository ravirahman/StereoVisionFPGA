import CacheTypes::*;
import DirectMappedCache::*;

import MemInit::*;
import MemTypes::*;
import Memory::*;
import MemUtil::*;
import Vector::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import BuildVector::*;


interface MemIfc;
    method Action req(MemReq r);
    method ActionValue#(MemResp) resp;
endinterface


interface MemorySystem;
   interface MemIfc iCache;
   interface MemIfc dCache;
   interface MemInitIfc init;
endinterface

module mkMemorySystem#(Bool started, WideMem mem)(MemorySystem);
   Cache#(4) icache <- mkDirectMappedCache;
   Cache#(4) dcache <- mkDirectMappedCache;
   
   Vector#(2, Cache#(4)) caches = vec(icache,dcache);
   
   Vector#(2, Array#(Reg#(Bit#(64)))) totalCnts <- replicateM(mkCReg(2,0));
   Vector#(2, Reg#(Bit#(64))) missCnts <- replicateM(mkReg(0));
   
   let memInit <- mkMemInitWideMem(mem);
   
   Vector#(2, WideMem) splitMem <- mkSplitWideMem(memInit.done && started, mem);
   
   for (Integer i = 0; i < 2; i = i + 1 ) begin
      rule connReq;
         let req <- caches[i].lineReq;
         splitMem[i].req(lineReqToWideMemReq(req));
         
         if (req.op == Ld) begin
            missCnts[i] <= missCnts[i] + 1;
         end
      endrule
      
      rule connResp;
         let resp <- splitMem[i].resp;
         caches[i].lineResp(resp);
      endrule
   end
   
   
   interface MemIfc iCache;
      method Action req(MemReq r);
         caches[0].req(r);
         totalCnts[0][0] <= totalCnts[0][0] + 1;
      endmethod
   
      method ActionValue#(Word) resp = caches[0].resp;
   endinterface   
   
   interface MemIfc dCache;
      method Action req(MemReq r);
         caches[1].req(r);
         totalCnts[1][0] <= totalCnts[1][0] + 1;
      endmethod
    
      method ActionValue#(Word) resp = caches[1].resp;
   endinterface
   
   interface init = memInit;

endmodule
