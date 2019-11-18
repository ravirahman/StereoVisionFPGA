
import ConnectalConfig::*;
import Vector::*;
import BuildVector::*;
import Portal::*;
import CnocPortal::*;
import Connectable::*;
import HostInterface::*;
import ConnectalMemTypes::*;
`include "ConnectalProjectConfig.bsv"
import IfcNames::*;
import `PinTypeInclude::*;
import MyDutIndication::*;
import MyDut::*;
import MyDutRequest::*;

typedef 1 NumberOfRequests;
typedef 1 NumberOfIndications;

`ifndef IMPORT_HOSTIF
(* synthesize *)
`endif
module mkCnocTop
`ifdef IMPORT_HOSTIF
       #(HostInterface host)
`else
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
       #(Clock derivedClockIn, Reset derivedResetIn)
`else
// otherwise no params
`endif
`endif
       (CnocTop#(NumberOfRequests,NumberOfIndications,PhysAddrWidth,DataBusWidth,`PinType,NumberOfMasters));
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
   HostInterface host = (interface HostInterface;
                           interface Clock derivedClock = derivedClockIn;
                           interface Reset derivedReset = derivedResetIn;
                         endinterface);
`endif
   MyDutIndicationOutput lMyDutIndicationOutput <- mkMyDutIndicationOutput;
   MyDutRequestInput lMyDutRequestInput <- mkMyDutRequestInput;

   let lMyDut <- mkMyDut(host, lMyDutIndicationOutput.ifc);

   mkConnection(lMyDutRequestInput.pipes, lMyDut.request);

   let lMyDutIndicationOutputNoc <- mkPortalMsgIndication(extend(pack(IfcNames_MyDutIndicationH2S)), lMyDutIndicationOutput.portalIfc.indications, lMyDutIndicationOutput.portalIfc.messageSize);
   let lMyDutRequestInputNoc <- mkPortalMsgRequest(extend(pack(IfcNames_MyDutRequestS2H)), lMyDutRequestInput.portalIfc.requests);
   Vector#(NumWriteClients,MemWriteClient#(DataBusWidth)) nullWriters = replicate(null_mem_write_client());
   Vector#(NumReadClients,MemReadClient#(DataBusWidth)) nullReaders = replicate(null_mem_read_client());

   interface requests = vec(lMyDutRequestInputNoc);
   interface indications = vec(lMyDutIndicationOutputNoc);
   interface readers = take(nullReaders);
   interface writers = take(nullWriters);
`ifdef TOP_SOURCES_PORTAL_CLOCK
   interface portalClockSource = None;
`endif

      interface pins = lMyDut.pins;
endmodule : mkCnocTop
export mkCnocTop;
export NumberOfRequests;
export NumberOfIndications;
export `PinTypeInclude::*;
