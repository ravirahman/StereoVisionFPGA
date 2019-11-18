#include "GeneratedTypes.h"

#ifndef NO_CPP_PORTAL_CODE
extern const uint32_t ifcNamesNone = IfcNamesNone;
extern const uint32_t platformIfcNames_MemServerRequestS2H = PlatformIfcNames_MemServerRequestS2H;
extern const uint32_t platformIfcNames_MMURequestS2H = PlatformIfcNames_MMURequestS2H;
extern const uint32_t platformIfcNames_MemServerIndicationH2S = PlatformIfcNames_MemServerIndicationH2S;
extern const uint32_t platformIfcNames_MMUIndicationH2S = PlatformIfcNames_MMUIndicationH2S;
extern const uint32_t ifcNames_MyDutIndicationH2S = IfcNames_MyDutIndicationH2S;
extern const uint32_t ifcNames_MyDutRequestS2H = IfcNames_MyDutRequestS2H;

/************** Start of MemServerRequestWrapper CPP ***********/
#include "MemServerRequest.h"
int MemServerRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerRequestaddrTrans_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t offset ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->addrTrans ( sglId, offset);
    return 0;
};
int MemServerRequestsetTileState_cb (  struct PortalInternal *p, const TileControl tc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->setTileState ( tc);
    return 0;
};
int MemServerRequeststateDbg_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->stateDbg ( rc);
    return 0;
};
int MemServerRequestmemoryTraffic_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->memoryTraffic ( rc);
    return 0;
};
MemServerRequestCb MemServerRequest_cbTable = {
    MemServerRequestdisconnect_cb,
    MemServerRequestaddrTrans_cb,
    MemServerRequestsetTileState_cb,
    MemServerRequeststateDbg_cb,
    MemServerRequestmemoryTraffic_cb,
};

/************** Start of MMURequestWrapper CPP ***********/
#include "MMURequest.h"
int MMURequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMURequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMURequestsglist_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len ) {
    (static_cast<MMURequestWrapper *>(p->parent))->sglist ( sglId, sglIndex, addr, len);
    return 0;
};
int MMURequestregion_cb (  struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 ) {
    (static_cast<MMURequestWrapper *>(p->parent))->region ( sglId, barr12, index12, barr8, index8, barr4, index4, barr0, index0);
    return 0;
};
int MMURequestidRequest_cb (  struct PortalInternal *p, const SpecialTypeForSendingFd fd ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idRequest ( fd);
    return 0;
};
int MMURequestidReturn_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idReturn ( sglId);
    return 0;
};
int MMURequestsetInterface_cb (  struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->setInterface ( interfaceId, sglId);
    return 0;
};
MMURequestCb MMURequest_cbTable = {
    MMURequestdisconnect_cb,
    MMURequestsglist_cb,
    MMURequestregion_cb,
    MMURequestidRequest_cb,
    MMURequestidReturn_cb,
    MMURequestsetInterface_cb,
};

/************** Start of MemServerIndicationWrapper CPP ***********/
#include "MemServerIndication.h"
int MemServerIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerIndicationaddrResponse_cb (  struct PortalInternal *p, const uint64_t physAddr ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->addrResponse ( physAddr);
    return 0;
};
int MemServerIndicationreportStateDbg_cb (  struct PortalInternal *p, const DmaDbgRec rec ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportStateDbg ( rec);
    return 0;
};
int MemServerIndicationreportMemoryTraffic_cb (  struct PortalInternal *p, const uint64_t words ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportMemoryTraffic ( words);
    return 0;
};
int MemServerIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MemServerIndicationCb MemServerIndication_cbTable = {
    MemServerIndicationdisconnect_cb,
    MemServerIndicationaddrResponse_cb,
    MemServerIndicationreportStateDbg_cb,
    MemServerIndicationreportMemoryTraffic_cb,
    MemServerIndicationerror_cb,
};

/************** Start of MMUIndicationWrapper CPP ***********/
#include "MMUIndication.h"
int MMUIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMUIndicationidResponse_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->idResponse ( sglId);
    return 0;
};
int MMUIndicationconfigResp_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->configResp ( sglId);
    return 0;
};
int MMUIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MMUIndicationCb MMUIndication_cbTable = {
    MMUIndicationdisconnect_cb,
    MMUIndicationidResponse_cb,
    MMUIndicationconfigResp_cb,
    MMUIndicationerror_cb,
};

/************** Start of XsimMsgRequestWrapper CPP ***********/
#include "XsimMsgRequest.h"
int XsimMsgRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int XsimMsgRequestmsgSink_cb (  struct PortalInternal *p, const uint32_t portal, const uint32_t data ) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->msgSink ( portal, data);
    return 0;
};
int XsimMsgRequestmsgSinkFd_cb (  struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data ) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->msgSinkFd ( portal, data);
    return 0;
};
XsimMsgRequestCb XsimMsgRequest_cbTable = {
    XsimMsgRequestdisconnect_cb,
    XsimMsgRequestmsgSink_cb,
    XsimMsgRequestmsgSinkFd_cb,
};

/************** Start of XsimMsgIndicationWrapper CPP ***********/
#include "XsimMsgIndication.h"
int XsimMsgIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<XsimMsgIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int XsimMsgIndicationmsgSource_cb (  struct PortalInternal *p, const uint32_t portal, const uint32_t data ) {
    (static_cast<XsimMsgIndicationWrapper *>(p->parent))->msgSource ( portal, data);
    return 0;
};
XsimMsgIndicationCb XsimMsgIndication_cbTable = {
    XsimMsgIndicationdisconnect_cb,
    XsimMsgIndicationmsgSource_cb,
};

/************** Start of MyDutRequestWrapper CPP ***********/
#include "MyDutRequest.h"
int MyDutRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MyDutRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MyDutRequestreadDRAM_cb (  struct PortalInternal *p, const uint32_t line_addr ) {
    (static_cast<MyDutRequestWrapper *>(p->parent))->readDRAM ( line_addr);
    return 0;
};
int MyDutRequestloadDRAM_cb (  struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data ) {
    (static_cast<MyDutRequestWrapper *>(p->parent))->loadDRAM ( line_addr, line_data);
    return 0;
};
int MyDutRequestrequestPoints_cb (  struct PortalInternal *p, const Point_Coords point ) {
    (static_cast<MyDutRequestWrapper *>(p->parent))->requestPoints ( point);
    return 0;
};
int MyDutRequestreset_dut_cb (  struct PortalInternal *p ) {
    (static_cast<MyDutRequestWrapper *>(p->parent))->reset_dut ( );
    return 0;
};
MyDutRequestCb MyDutRequest_cbTable = {
    MyDutRequestdisconnect_cb,
    MyDutRequestreadDRAM_cb,
    MyDutRequestloadDRAM_cb,
    MyDutRequestrequestPoints_cb,
    MyDutRequestreset_dut_cb,
};

/************** Start of MyDutIndicationWrapper CPP ***********/
#include "MyDutIndication.h"
int MyDutIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MyDutIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MyDutIndicationreturnOutputDDR_cb (  struct PortalInternal *p, const DRAM_Line resp ) {
    (static_cast<MyDutIndicationWrapper *>(p->parent))->returnOutputDDR ( resp);
    return 0;
};
int MyDutIndicationreturnOutputSV_cb (  struct PortalInternal *p, const Dist_List distances ) {
    (static_cast<MyDutIndicationWrapper *>(p->parent))->returnOutputSV ( distances);
    return 0;
};
MyDutIndicationCb MyDutIndication_cbTable = {
    MyDutIndicationdisconnect_cb,
    MyDutIndicationreturnOutputDDR_cb,
    MyDutIndicationreturnOutputSV_cb,
};
#endif //NO_CPP_PORTAL_CODE
