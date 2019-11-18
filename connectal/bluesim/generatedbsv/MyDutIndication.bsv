package MyDutIndication;

import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Clocks::*;
import FloatingPoint::*;
import Adapter::*;
import Leds::*;
import Vector::*;
import SpecialFIFOs::*;
import ConnectalConfig::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import ConnectalMemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import MyDut::*;
import DDR3Controller::*;
import FIFO::*;
import Vector::*;
import DefaultValue::*;
import ClientServer::*;
import GetPut::*;
import Clocks::*;
import FShow::*;
import FixedPoint::*;
import Types::*;
import StereoVisionMultiplePoints::*;
import Top_Pins::*;
import HostInterface::*;
import DDR3Common::*;
import DDR3Sim::*;
import DDR3User::*;




typedef struct {
    DRAM_Line resp;
} ReturnOutputDDR_Message deriving (Bits);

typedef struct {
    Dist_List distances;
} ReturnOutputSV_Message deriving (Bits);

// exposed wrapper portal interface
interface MyDutIndicationInputPipes;
    interface PipeOut#(ReturnOutputDDR_Message) returnOutputDDR_PipeOut;
    interface PipeOut#(ReturnOutputSV_Message) returnOutputSV_PipeOut;

endinterface
typedef PipePortal#(2, 0, SlaveDataBusWidth) MyDutIndicationPortalInput;
interface MyDutIndicationInput;
    interface MyDutIndicationPortalInput portalIfc;
    interface MyDutIndicationInputPipes pipes;
endinterface
interface MyDutIndicationWrapperPortal;
    interface MyDutIndicationPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface MyDutIndicationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(MyDutIndicationInputPipes,MyDutIndication);
   module mkConnection#(MyDutIndicationInputPipes pipes, MyDutIndication ifc)(Empty);

    rule handle_returnOutputDDR_request;
        let request <- toGet(pipes.returnOutputDDR_PipeOut).get();
        ifc.returnOutputDDR(request.resp);
    endrule

    rule handle_returnOutputSV_request;
        let request <- toGet(pipes.returnOutputSV_PipeOut).get();
        ifc.returnOutputSV(request.distances);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkMyDutIndicationInput(MyDutIndicationInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,ReturnOutputDDR_Message) returnOutputDDR_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = returnOutputDDR_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,ReturnOutputSV_Message) returnOutputSV_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = returnOutputSV_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(ReturnOutputDDR_Message)));
            1: return fromInteger(valueOf(SizeOf#(ReturnOutputSV_Message)));
            endcase
        endmethod
        endinterface
        interface Vector requests = requestPipeIn;
        interface Vector indications = nil;
        interface PortalInterrupt intr;
           method Bool status();
              return False;
           endmethod
           method Bit#(dataWidth) channel();
              return -1;
           endmethod
        endinterface
    endinterface
    interface MyDutIndicationInputPipes pipes;
        interface returnOutputDDR_PipeOut = returnOutputDDR_requestAdapter.out;
        interface returnOutputSV_PipeOut = returnOutputSV_requestAdapter.out;
    endinterface
endmodule

module mkMyDutIndicationWrapperPortal#(MyDutIndication ifc)(MyDutIndicationWrapperPortal);
    let dut <- mkMyDutIndicationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface MyDutIndicationWrapperMemPortalPipes;
    interface MyDutIndicationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkMyDutIndicationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(MyDutIndicationWrapperMemPortalPipes);

  let dut <- mkMyDutIndicationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface MyDutIndicationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkMyDutIndicationWrapper#(idType id, MyDutIndication ifc)(MyDutIndicationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkMyDutIndicationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 2, SlaveDataBusWidth) MyDutIndicationPortalOutput;
interface MyDutIndicationOutput;
    interface MyDutIndicationPortalOutput portalIfc;
    interface MyDut::MyDutIndication ifc;
endinterface
interface MyDutIndicationProxy;
    interface StdPortal portalIfc;
    interface MyDut::MyDutIndication ifc;
endinterface

interface MyDutIndicationOutputPipeMethods;
    interface PipeIn#(ReturnOutputDDR_Message) returnOutputDDR;
    interface PipeIn#(ReturnOutputSV_Message) returnOutputSV;

endinterface

interface MyDutIndicationOutputPipes;
    interface MyDutIndicationOutputPipeMethods methods;
    interface MyDutIndicationPortalOutput portalIfc;
endinterface

function Bit#(16) getMyDutIndicationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(ReturnOutputDDR_Message)));
            1: return fromInteger(valueOf(SizeOf#(ReturnOutputSV_Message)));
    endcase
endfunction

(* synthesize *)
module mkMyDutIndicationOutputPipes(MyDutIndicationOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,ReturnOutputDDR_Message) returnOutputDDR_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = returnOutputDDR_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,ReturnOutputSV_Message) returnOutputSV_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = returnOutputSV_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface MyDutIndicationOutputPipeMethods methods;
    interface returnOutputDDR = returnOutputDDR_responseAdapter.in;
    interface returnOutputSV = returnOutputSV_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getMyDutIndicationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkMyDutIndicationOutput(MyDutIndicationOutput);
    let indicationPipes <- mkMyDutIndicationOutputPipes;
    interface MyDut::MyDutIndication ifc;

    method Action returnOutputDDR(DRAM_Line resp);
        indicationPipes.methods.returnOutputDDR.enq(ReturnOutputDDR_Message {resp: resp});
        //$display("indicationMethod 'returnOutputDDR' invoked");
    endmethod
    method Action returnOutputSV(Dist_List distances);
        indicationPipes.methods.returnOutputSV.enq(ReturnOutputSV_Message {distances: distances});
        //$display("indicationMethod 'returnOutputSV' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(MyDutIndicationOutput);
   function Bit#(16) portalMessageSize(MyDutIndicationOutput p, Bit#(16) methodNumber);
      return getMyDutIndicationMessageSize(methodNumber);
   endfunction
endinstance


interface MyDutIndicationInverse;
    method ActionValue#(ReturnOutputDDR_Message) returnOutputDDR;
    method ActionValue#(ReturnOutputSV_Message) returnOutputSV;

endinterface

interface MyDutIndicationInverter;
    interface MyDut::MyDutIndication ifc;
    interface MyDutIndicationInverse inverseIfc;
endinterface

instance Connectable#(MyDutIndicationInverse, MyDutIndicationOutputPipeMethods);
   module mkConnection#(MyDutIndicationInverse in, MyDutIndicationOutputPipeMethods out)(Empty);
    mkConnection(in.returnOutputDDR, out.returnOutputDDR);
    mkConnection(in.returnOutputSV, out.returnOutputSV);

   endmodule
endinstance

(* synthesize *)
module mkMyDutIndicationInverter(MyDutIndicationInverter);
    FIFOF#(ReturnOutputDDR_Message) fifo_returnOutputDDR <- mkFIFOF();
    FIFOF#(ReturnOutputSV_Message) fifo_returnOutputSV <- mkFIFOF();

    interface MyDut::MyDutIndication ifc;

    method Action returnOutputDDR(DRAM_Line resp);
        fifo_returnOutputDDR.enq(ReturnOutputDDR_Message {resp: resp});
    endmethod
    method Action returnOutputSV(Dist_List distances);
        fifo_returnOutputSV.enq(ReturnOutputSV_Message {distances: distances});
    endmethod
    endinterface
    interface MyDutIndicationInverse inverseIfc;

    method ActionValue#(ReturnOutputDDR_Message) returnOutputDDR;
        fifo_returnOutputDDR.deq;
        return fifo_returnOutputDDR.first;
    endmethod
    method ActionValue#(ReturnOutputSV_Message) returnOutputSV;
        fifo_returnOutputSV.deq;
        return fifo_returnOutputSV.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkMyDutIndicationInverterV(MyDutIndicationInverter);
    PutInverter#(ReturnOutputDDR_Message) inv_returnOutputDDR <- mkPutInverter();
    PutInverter#(ReturnOutputSV_Message) inv_returnOutputSV <- mkPutInverter();

    interface MyDut::MyDutIndication ifc;

    method Action returnOutputDDR(DRAM_Line resp);
        inv_returnOutputDDR.mod.put(ReturnOutputDDR_Message {resp: resp});
    endmethod
    method Action returnOutputSV(Dist_List distances);
        inv_returnOutputSV.mod.put(ReturnOutputSV_Message {distances: distances});
    endmethod
    endinterface
    interface MyDutIndicationInverse inverseIfc;

    method ActionValue#(ReturnOutputDDR_Message) returnOutputDDR;
        let v <- inv_returnOutputDDR.inverse.get;
        return v;
    endmethod
    method ActionValue#(ReturnOutputSV_Message) returnOutputSV;
        let v <- inv_returnOutputSV.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkMyDutIndicationProxySynth#(Bit#(SlaveDataBusWidth) id)(MyDutIndicationProxy);
  let dut <- mkMyDutIndicationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface MyDut::MyDutIndication ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkMyDutIndicationProxy#(idType id)(MyDutIndicationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkMyDutIndicationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: MyDutIndication
