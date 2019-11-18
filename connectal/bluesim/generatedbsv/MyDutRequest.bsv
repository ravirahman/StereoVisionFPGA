package MyDutRequest;

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
    Bit#(32) line_addr;
} ReadDRAM_Message deriving (Bits);

typedef struct {
    Bit#(32) line_addr;
    DRAM_Line line_data;
} LoadDRAM_Message deriving (Bits);

typedef struct {
    Point_Coords point;
} RequestPoints_Message deriving (Bits);

typedef struct {
    Bit#(32) padding;
} Reset_dut_Message deriving (Bits);

// exposed wrapper portal interface
interface MyDutRequestInputPipes;
    interface PipeOut#(ReadDRAM_Message) readDRAM_PipeOut;
    interface PipeOut#(LoadDRAM_Message) loadDRAM_PipeOut;
    interface PipeOut#(RequestPoints_Message) requestPoints_PipeOut;
    interface PipeOut#(Reset_dut_Message) reset_dut_PipeOut;

endinterface
typedef PipePortal#(4, 0, SlaveDataBusWidth) MyDutRequestPortalInput;
interface MyDutRequestInput;
    interface MyDutRequestPortalInput portalIfc;
    interface MyDutRequestInputPipes pipes;
endinterface
interface MyDutRequestWrapperPortal;
    interface MyDutRequestPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface MyDutRequestWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(MyDutRequestInputPipes,MyDutRequest);
   module mkConnection#(MyDutRequestInputPipes pipes, MyDutRequest ifc)(Empty);

    rule handle_readDRAM_request;
        let request <- toGet(pipes.readDRAM_PipeOut).get();
        ifc.readDRAM(request.line_addr);
    endrule

    rule handle_loadDRAM_request;
        let request <- toGet(pipes.loadDRAM_PipeOut).get();
        ifc.loadDRAM(request.line_addr, request.line_data);
    endrule

    rule handle_requestPoints_request;
        let request <- toGet(pipes.requestPoints_PipeOut).get();
        ifc.requestPoints(request.point);
    endrule

    rule handle_reset_dut_request;
        let request <- toGet(pipes.reset_dut_PipeOut).get();
        ifc.reset_dut();
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkMyDutRequestInput(MyDutRequestInput);
    Vector#(4, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,ReadDRAM_Message) readDRAM_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = readDRAM_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,LoadDRAM_Message) loadDRAM_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = loadDRAM_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,RequestPoints_Message) requestPoints_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[2] = requestPoints_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,Reset_dut_Message) reset_dut_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[3] = reset_dut_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(ReadDRAM_Message)));
            1: return fromInteger(valueOf(SizeOf#(LoadDRAM_Message)));
            2: return fromInteger(valueOf(SizeOf#(RequestPoints_Message)));
            3: return fromInteger(valueOf(SizeOf#(Reset_dut_Message)));
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
    interface MyDutRequestInputPipes pipes;
        interface readDRAM_PipeOut = readDRAM_requestAdapter.out;
        interface loadDRAM_PipeOut = loadDRAM_requestAdapter.out;
        interface requestPoints_PipeOut = requestPoints_requestAdapter.out;
        interface reset_dut_PipeOut = reset_dut_requestAdapter.out;
    endinterface
endmodule

module mkMyDutRequestWrapperPortal#(MyDutRequest ifc)(MyDutRequestWrapperPortal);
    let dut <- mkMyDutRequestInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface MyDutRequestWrapperMemPortalPipes;
    interface MyDutRequestInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkMyDutRequestWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(MyDutRequestWrapperMemPortalPipes);

  let dut <- mkMyDutRequestInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface MyDutRequestInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkMyDutRequestWrapper#(idType id, MyDutRequest ifc)(MyDutRequestWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkMyDutRequestWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 4, SlaveDataBusWidth) MyDutRequestPortalOutput;
interface MyDutRequestOutput;
    interface MyDutRequestPortalOutput portalIfc;
    interface MyDut::MyDutRequest ifc;
endinterface
interface MyDutRequestProxy;
    interface StdPortal portalIfc;
    interface MyDut::MyDutRequest ifc;
endinterface

interface MyDutRequestOutputPipeMethods;
    interface PipeIn#(ReadDRAM_Message) readDRAM;
    interface PipeIn#(LoadDRAM_Message) loadDRAM;
    interface PipeIn#(RequestPoints_Message) requestPoints;
    interface PipeIn#(Reset_dut_Message) reset_dut;

endinterface

interface MyDutRequestOutputPipes;
    interface MyDutRequestOutputPipeMethods methods;
    interface MyDutRequestPortalOutput portalIfc;
endinterface

function Bit#(16) getMyDutRequestMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(ReadDRAM_Message)));
            1: return fromInteger(valueOf(SizeOf#(LoadDRAM_Message)));
            2: return fromInteger(valueOf(SizeOf#(RequestPoints_Message)));
            3: return fromInteger(valueOf(SizeOf#(Reset_dut_Message)));
    endcase
endfunction

(* synthesize *)
module mkMyDutRequestOutputPipes(MyDutRequestOutputPipes);
    Vector#(4, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,ReadDRAM_Message) readDRAM_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = readDRAM_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,LoadDRAM_Message) loadDRAM_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = loadDRAM_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,RequestPoints_Message) requestPoints_responseAdapter <- mkAdapterToBus();
    indicationPipes[2] = requestPoints_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,Reset_dut_Message) reset_dut_responseAdapter <- mkAdapterToBus();
    indicationPipes[3] = reset_dut_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface MyDutRequestOutputPipeMethods methods;
    interface readDRAM = readDRAM_responseAdapter.in;
    interface loadDRAM = loadDRAM_responseAdapter.in;
    interface requestPoints = requestPoints_responseAdapter.in;
    interface reset_dut = reset_dut_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getMyDutRequestMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkMyDutRequestOutput(MyDutRequestOutput);
    let indicationPipes <- mkMyDutRequestOutputPipes;
    interface MyDut::MyDutRequest ifc;

    method Action readDRAM(Bit#(32) line_addr);
        indicationPipes.methods.readDRAM.enq(ReadDRAM_Message {line_addr: line_addr});
        //$display("indicationMethod 'readDRAM' invoked");
    endmethod
    method Action loadDRAM(Bit#(32) line_addr, DRAM_Line line_data);
        indicationPipes.methods.loadDRAM.enq(LoadDRAM_Message {line_addr: line_addr, line_data: line_data});
        //$display("indicationMethod 'loadDRAM' invoked");
    endmethod
    method Action requestPoints(Point_Coords point);
        indicationPipes.methods.requestPoints.enq(RequestPoints_Message {point: point});
        //$display("indicationMethod 'requestPoints' invoked");
    endmethod
    method Action reset_dut();
        indicationPipes.methods.reset_dut.enq(Reset_dut_Message {padding: 0});
        //$display("indicationMethod 'reset_dut' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(MyDutRequestOutput);
   function Bit#(16) portalMessageSize(MyDutRequestOutput p, Bit#(16) methodNumber);
      return getMyDutRequestMessageSize(methodNumber);
   endfunction
endinstance


interface MyDutRequestInverse;
    method ActionValue#(ReadDRAM_Message) readDRAM;
    method ActionValue#(LoadDRAM_Message) loadDRAM;
    method ActionValue#(RequestPoints_Message) requestPoints;
    method ActionValue#(Reset_dut_Message) reset_dut;

endinterface

interface MyDutRequestInverter;
    interface MyDut::MyDutRequest ifc;
    interface MyDutRequestInverse inverseIfc;
endinterface

instance Connectable#(MyDutRequestInverse, MyDutRequestOutputPipeMethods);
   module mkConnection#(MyDutRequestInverse in, MyDutRequestOutputPipeMethods out)(Empty);
    mkConnection(in.readDRAM, out.readDRAM);
    mkConnection(in.loadDRAM, out.loadDRAM);
    mkConnection(in.requestPoints, out.requestPoints);
    mkConnection(in.reset_dut, out.reset_dut);

   endmodule
endinstance

(* synthesize *)
module mkMyDutRequestInverter(MyDutRequestInverter);
    FIFOF#(ReadDRAM_Message) fifo_readDRAM <- mkFIFOF();
    FIFOF#(LoadDRAM_Message) fifo_loadDRAM <- mkFIFOF();
    FIFOF#(RequestPoints_Message) fifo_requestPoints <- mkFIFOF();
    FIFOF#(Reset_dut_Message) fifo_reset_dut <- mkFIFOF();

    interface MyDut::MyDutRequest ifc;

    method Action readDRAM(Bit#(32) line_addr);
        fifo_readDRAM.enq(ReadDRAM_Message {line_addr: line_addr});
    endmethod
    method Action loadDRAM(Bit#(32) line_addr, DRAM_Line line_data);
        fifo_loadDRAM.enq(LoadDRAM_Message {line_addr: line_addr, line_data: line_data});
    endmethod
    method Action requestPoints(Point_Coords point);
        fifo_requestPoints.enq(RequestPoints_Message {point: point});
    endmethod
    method Action reset_dut();
        fifo_reset_dut.enq(Reset_dut_Message {padding: 0});
    endmethod
    endinterface
    interface MyDutRequestInverse inverseIfc;

    method ActionValue#(ReadDRAM_Message) readDRAM;
        fifo_readDRAM.deq;
        return fifo_readDRAM.first;
    endmethod
    method ActionValue#(LoadDRAM_Message) loadDRAM;
        fifo_loadDRAM.deq;
        return fifo_loadDRAM.first;
    endmethod
    method ActionValue#(RequestPoints_Message) requestPoints;
        fifo_requestPoints.deq;
        return fifo_requestPoints.first;
    endmethod
    method ActionValue#(Reset_dut_Message) reset_dut;
        fifo_reset_dut.deq;
        return fifo_reset_dut.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkMyDutRequestInverterV(MyDutRequestInverter);
    PutInverter#(ReadDRAM_Message) inv_readDRAM <- mkPutInverter();
    PutInverter#(LoadDRAM_Message) inv_loadDRAM <- mkPutInverter();
    PutInverter#(RequestPoints_Message) inv_requestPoints <- mkPutInverter();
    PutInverter#(Reset_dut_Message) inv_reset_dut <- mkPutInverter();

    interface MyDut::MyDutRequest ifc;

    method Action readDRAM(Bit#(32) line_addr);
        inv_readDRAM.mod.put(ReadDRAM_Message {line_addr: line_addr});
    endmethod
    method Action loadDRAM(Bit#(32) line_addr, DRAM_Line line_data);
        inv_loadDRAM.mod.put(LoadDRAM_Message {line_addr: line_addr, line_data: line_data});
    endmethod
    method Action requestPoints(Point_Coords point);
        inv_requestPoints.mod.put(RequestPoints_Message {point: point});
    endmethod
    method Action reset_dut();
        inv_reset_dut.mod.put(Reset_dut_Message {padding: 0});
    endmethod
    endinterface
    interface MyDutRequestInverse inverseIfc;

    method ActionValue#(ReadDRAM_Message) readDRAM;
        let v <- inv_readDRAM.inverse.get;
        return v;
    endmethod
    method ActionValue#(LoadDRAM_Message) loadDRAM;
        let v <- inv_loadDRAM.inverse.get;
        return v;
    endmethod
    method ActionValue#(RequestPoints_Message) requestPoints;
        let v <- inv_requestPoints.inverse.get;
        return v;
    endmethod
    method ActionValue#(Reset_dut_Message) reset_dut;
        let v <- inv_reset_dut.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkMyDutRequestProxySynth#(Bit#(SlaveDataBusWidth) id)(MyDutRequestProxy);
  let dut <- mkMyDutRequestOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface MyDut::MyDutRequest ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkMyDutRequestProxy#(idType id)(MyDutRequestProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkMyDutRequestProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: MyDutRequest
