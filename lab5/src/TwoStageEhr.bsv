import Types::*;
import ProcTypes::*;
import MemTypes::*;
import Reg6375::*;
import RFile::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import FIFO::*;
import MemUtil::*;
import MemorySystem::*;
import ClientServer::*;
import Ehr::*;
import GetPut::*;


typedef struct {
   Word pc;
   Word ppc;
   Bool epoch;
   } F2E deriving(Bits, Eq);

typedef enum {Execute, LoadWait } State deriving (Bits, Eq);

(* synthesize *)
module mkProc(Proc);
////////////////////////////////////////////////////////////////////////////////
/// Processor module instantiation
////////////////////////////////////////////////////////////////////////////////
   Ehr#(2, Word)  pc <- mkEhr(0);
   Reg#(Bool)  epoch <- mkReg(False);
   RFile      rf <- mkRFile;
   CsrFile  csrf <- mkCsrFile;
   
   FIFO#(F2E) f2e <- mkFIFO;

   Reg#(Bool)  loadWaitReg <- mkReg(False);
   Reg#(RIndx) dstLoad <- mkReg(0);
   
   Reg#(State) state <- mkReg(Execute);
    

////////////////////////////////////////////////////////////////////////////////
/// Section: Memory Subsystem
////////////////////////////////////////////////////////////////////////////////

   // Instantiate Wide Memory from DDR3 Client
   FIFO#(DDR3_Req) ddrReqQ <- mkFIFO;
   FIFO#(DDR3_Resp) ddrRespQ <- mkFIFO;
   let wideMem <- mkWideMemFromDDR3(ddrReqQ,ddrRespQ);
   
   // Initiatiate memory system( 1KB iCache + 1KB dCache)
   let memory <- mkMemorySystem(csrf.started, wideMem);
   let iMem = memory.iCache;
   let dMem = memory.dCache;
   
   Bool memReady = memory.init.done();
   
   // some garbage may get into ddr3RespFifo during soft reset
   // this rule drains all such garbage
   rule drainMemResponses( !csrf.started );
      ddrRespQ.deq;
   endrule
////////////////////////////////////////////////////////////////////////////////
/// End of Section: Memory Subsystem
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
/// Begin of Section: Processor
////////////////////////////////////////////////////////////////////////////////
   rule doFetch(csrf.started);
      iMem.req(MemReq{op: Ld, addr: pc[1], data: ?});
      let ppc = pc[1] + 4;
      pc[1] <= ppc;
      f2e.enq(F2E {pc: pc[1], ppc: ppc, epoch: epoch});    
   endrule

   rule doExecute(state==Execute);
      let inst <- iMem.resp();
      let x = f2e.first;          
      let pcE = x.pc; let ppc = x.ppc; let epochE = x.epoch; 
      f2e.deq;
       
      DecodedInst dInst = decode(inst);
       
      if (epochE == epoch) begin  // right-path instruction
         if(dInst.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pcE);
            $finish;
         end
      
         // read general purpose register values 
         Word rVal1 = rf.rd1(fromMaybe(?, dInst.src1));
         Word rVal2 = rf.rd2(fromMaybe(?, dInst.src2));

         // read CSR values (for CSRR inst)
         Word csrVal = csrf.rd(fromMaybe(?, dInst.csr));

         // execute
         ExecInst eInst = exec(dInst, rVal1, rVal2, pcE, csrVal);  
         
         // misprediction 
         let misprediction = eInst.nextPC != ppc;
         if ( misprediction ) begin
            pc[0] <= eInst.nextPC;
            epoch <= !epoch;
         end

         if(eInst.iType == Ld) begin
            dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
            dstLoad <= fromMaybe(?, eInst.dst);
            state <= LoadWait;
         end
         else if(eInst.iType == St) begin
            dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
         end
         else begin
            if(isValid(eInst.dst)) begin
               rf.wr(fromMaybe(?, eInst.dst), eInst.data);
            end
         end
         
         // this needed to be called on every instruction even
         // for non-Csrw itype for counting correct number of instructions

         csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
       end
    endrule
   
   
   rule doLoadWait(state == LoadWait);
      let data <- dMem.resp();
      rf.wr(dstLoad, data);
      state <= Execute;
   endrule
////////////////////////////////////////////////////////////////////////////////
/// End of Section: Processor
////////////////////////////////////////////////////////////////////////////////

   
   method ActionValue#(CpuToHostData) cpuToHost;
      let ret <- csrf.cpuToHost;
      return ret;
   endmethod

   method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
      csrf.start(0); // only 1 core, id = 0
	  $display("Start at pc 200\n");
	  $fflush(stdout);
      pc[1] <= startpc;
   endmethod
   
   interface memInit = memory.init;
   
   interface DDR3_Client ddr3client;
   interface request = toGet(ddrReqQ);
      interface response = toPut(ddrRespQ);
   endinterface
   
endmodule

