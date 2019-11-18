#ifndef __GENERATED_TYPES__
#define __GENERATED_TYPES__
#include "portal.h"
#ifdef __cplusplus
extern "C" {
#endif
typedef struct DRAM_Line {
    uint64_t data7 : 64;
    uint64_t data6 : 64;
    uint64_t data5 : 64;
    uint64_t data4 : 64;
    uint64_t data3 : 64;
    uint64_t data2 : 64;
    uint64_t data1 : 64;
    uint64_t data0 : 64;
} DRAM_Line;
typedef struct Point_Coords {
    uint8_t y1 : 6;
    uint8_t x1 : 6;
    uint8_t y0 : 6;
    uint8_t x0 : 6;
} Point_Coords;
typedef struct Dist_List {
    uint16_t dist1 : 16;
    uint16_t dist0 : 16;
} Dist_List;
typedef enum ChannelType { ChannelType_Read, ChannelType_Write,  } ChannelType;
typedef struct DmaDbgRec {
    uint32_t x : 32;
    uint32_t y : 32;
    uint32_t z : 32;
    uint32_t w : 32;
} DmaDbgRec;
typedef enum DmaErrorType { DmaErrorNone, DmaErrorSGLIdOutOfRange_r, DmaErrorSGLIdOutOfRange_w, DmaErrorMMUOutOfRange_r, DmaErrorMMUOutOfRange_w, DmaErrorOffsetOutOfRange, DmaErrorSGLIdInvalid, DmaErrorTileTagOutOfRange,  } DmaErrorType;
typedef uint32_t SpecialTypeForSendingFd;
typedef enum TileState { Idle, Stopped, Running,  } TileState;
typedef struct TileControl {
    uint8_t tile : 2;
    TileState state;
} TileControl;
typedef enum XsimIfcNames { XsimIfcNames_XsimMsgRequest, XsimIfcNames_XsimMsgIndication,  } XsimIfcNames;
typedef enum IfcNames { IfcNamesNone=0, PlatformIfcNames_MemServerRequestS2H=1, PlatformIfcNames_MMURequestS2H=2, PlatformIfcNames_MemServerIndicationH2S=3, PlatformIfcNames_MMUIndicationH2S=4, IfcNames_MyDutIndicationH2S=5, IfcNames_MyDutRequestS2H=6,  } IfcNames;


int MemServerRequest_addrTrans ( struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
int MemServerRequest_setTileState ( struct PortalInternal *p, const TileControl tc );
int MemServerRequest_stateDbg ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequest_memoryTraffic ( struct PortalInternal *p, const ChannelType rc );
enum { CHAN_NUM_MemServerRequest_addrTrans,CHAN_NUM_MemServerRequest_setTileState,CHAN_NUM_MemServerRequest_stateDbg,CHAN_NUM_MemServerRequest_memoryTraffic};
extern const uint32_t MemServerRequest_reqinfo;

typedef struct {
    uint32_t sglId;
    uint32_t offset;
} MemServerRequest_addrTransData;
typedef struct {
    TileControl tc;
} MemServerRequest_setTileStateData;
typedef struct {
    ChannelType rc;
} MemServerRequest_stateDbgData;
typedef struct {
    ChannelType rc;
} MemServerRequest_memoryTrafficData;
typedef union {
    MemServerRequest_addrTransData addrTrans;
    MemServerRequest_setTileStateData setTileState;
    MemServerRequest_stateDbgData stateDbg;
    MemServerRequest_memoryTrafficData memoryTraffic;
} MemServerRequestData;
int MemServerRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*addrTrans) (  struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
    int (*setTileState) (  struct PortalInternal *p, const TileControl tc );
    int (*stateDbg) (  struct PortalInternal *p, const ChannelType rc );
    int (*memoryTraffic) (  struct PortalInternal *p, const ChannelType rc );
} MemServerRequestCb;
extern MemServerRequestCb MemServerRequestProxyReq;

int MemServerRequestJson_addrTrans ( struct PortalInternal *p, const uint32_t sglId, const uint32_t offset );
int MemServerRequestJson_setTileState ( struct PortalInternal *p, const TileControl tc );
int MemServerRequestJson_stateDbg ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequestJson_memoryTraffic ( struct PortalInternal *p, const ChannelType rc );
int MemServerRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemServerRequestCb MemServerRequestJsonProxyReq;

int MMURequest_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
int MMURequest_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
int MMURequest_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd );
int MMURequest_idReturn ( struct PortalInternal *p, const uint32_t sglId );
int MMURequest_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
enum { CHAN_NUM_MMURequest_sglist,CHAN_NUM_MMURequest_region,CHAN_NUM_MMURequest_idRequest,CHAN_NUM_MMURequest_idReturn,CHAN_NUM_MMURequest_setInterface};
extern const uint32_t MMURequest_reqinfo;

typedef struct {
    uint32_t sglId;
    uint32_t sglIndex;
    uint64_t addr;
    uint32_t len;
} MMURequest_sglistData;
typedef struct {
    uint32_t sglId;
    uint64_t barr12;
    uint32_t index12;
    uint64_t barr8;
    uint32_t index8;
    uint64_t barr4;
    uint32_t index4;
    uint64_t barr0;
    uint32_t index0;
} MMURequest_regionData;
typedef struct {
    SpecialTypeForSendingFd fd;
} MMURequest_idRequestData;
typedef struct {
    uint32_t sglId;
} MMURequest_idReturnData;
typedef struct {
    uint32_t interfaceId;
    uint32_t sglId;
} MMURequest_setInterfaceData;
typedef union {
    MMURequest_sglistData sglist;
    MMURequest_regionData region;
    MMURequest_idRequestData idRequest;
    MMURequest_idReturnData idReturn;
    MMURequest_setInterfaceData setInterface;
} MMURequestData;
int MMURequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*sglist) (  struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
    int (*region) (  struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
    int (*idRequest) (  struct PortalInternal *p, const SpecialTypeForSendingFd fd );
    int (*idReturn) (  struct PortalInternal *p, const uint32_t sglId );
    int (*setInterface) (  struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
} MMURequestCb;
extern MMURequestCb MMURequestProxyReq;

int MMURequestJson_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len );
int MMURequestJson_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 );
int MMURequestJson_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd );
int MMURequestJson_idReturn ( struct PortalInternal *p, const uint32_t sglId );
int MMURequestJson_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId );
int MMURequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MMURequestCb MMURequestJsonProxyReq;

int MemServerIndication_addrResponse ( struct PortalInternal *p, const uint64_t physAddr );
int MemServerIndication_reportStateDbg ( struct PortalInternal *p, const DmaDbgRec rec );
int MemServerIndication_reportMemoryTraffic ( struct PortalInternal *p, const uint64_t words );
int MemServerIndication_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
enum { CHAN_NUM_MemServerIndication_addrResponse,CHAN_NUM_MemServerIndication_reportStateDbg,CHAN_NUM_MemServerIndication_reportMemoryTraffic,CHAN_NUM_MemServerIndication_error};
extern const uint32_t MemServerIndication_reqinfo;

typedef struct {
    uint64_t physAddr;
} MemServerIndication_addrResponseData;
typedef struct {
    DmaDbgRec rec;
} MemServerIndication_reportStateDbgData;
typedef struct {
    uint64_t words;
} MemServerIndication_reportMemoryTrafficData;
typedef struct {
    uint32_t code;
    uint32_t sglId;
    uint64_t offset;
    uint64_t extra;
} MemServerIndication_errorData;
typedef union {
    MemServerIndication_addrResponseData addrResponse;
    MemServerIndication_reportStateDbgData reportStateDbg;
    MemServerIndication_reportMemoryTrafficData reportMemoryTraffic;
    MemServerIndication_errorData error;
} MemServerIndicationData;
int MemServerIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*addrResponse) (  struct PortalInternal *p, const uint64_t physAddr );
    int (*reportStateDbg) (  struct PortalInternal *p, const DmaDbgRec rec );
    int (*reportMemoryTraffic) (  struct PortalInternal *p, const uint64_t words );
    int (*error) (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
} MemServerIndicationCb;
extern MemServerIndicationCb MemServerIndicationProxyReq;

int MemServerIndicationJson_addrResponse ( struct PortalInternal *p, const uint64_t physAddr );
int MemServerIndicationJson_reportStateDbg ( struct PortalInternal *p, const DmaDbgRec rec );
int MemServerIndicationJson_reportMemoryTraffic ( struct PortalInternal *p, const uint64_t words );
int MemServerIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
int MemServerIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MemServerIndicationCb MemServerIndicationJsonProxyReq;

int MMUIndication_idResponse ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndication_configResp ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndication_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
enum { CHAN_NUM_MMUIndication_idResponse,CHAN_NUM_MMUIndication_configResp,CHAN_NUM_MMUIndication_error};
extern const uint32_t MMUIndication_reqinfo;

typedef struct {
    uint32_t sglId;
} MMUIndication_idResponseData;
typedef struct {
    uint32_t sglId;
} MMUIndication_configRespData;
typedef struct {
    uint32_t code;
    uint32_t sglId;
    uint64_t offset;
    uint64_t extra;
} MMUIndication_errorData;
typedef union {
    MMUIndication_idResponseData idResponse;
    MMUIndication_configRespData configResp;
    MMUIndication_errorData error;
} MMUIndicationData;
int MMUIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*idResponse) (  struct PortalInternal *p, const uint32_t sglId );
    int (*configResp) (  struct PortalInternal *p, const uint32_t sglId );
    int (*error) (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
} MMUIndicationCb;
extern MMUIndicationCb MMUIndicationProxyReq;

int MMUIndicationJson_idResponse ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndicationJson_configResp ( struct PortalInternal *p, const uint32_t sglId );
int MMUIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra );
int MMUIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MMUIndicationCb MMUIndicationJsonProxyReq;

int XsimMsgRequest_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgRequest_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
enum { CHAN_NUM_XsimMsgRequest_msgSink,CHAN_NUM_XsimMsgRequest_msgSinkFd};
extern const uint32_t XsimMsgRequest_reqinfo;

typedef struct {
    uint32_t portal;
    uint32_t data;
} XsimMsgRequest_msgSinkData;
typedef struct {
    uint32_t portal;
    SpecialTypeForSendingFd data;
} XsimMsgRequest_msgSinkFdData;
typedef union {
    XsimMsgRequest_msgSinkData msgSink;
    XsimMsgRequest_msgSinkFdData msgSinkFd;
} XsimMsgRequestData;
int XsimMsgRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*msgSink) (  struct PortalInternal *p, const uint32_t portal, const uint32_t data );
    int (*msgSinkFd) (  struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
} XsimMsgRequestCb;
extern XsimMsgRequestCb XsimMsgRequestProxyReq;

int XsimMsgRequestJson_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgRequestJson_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data );
int XsimMsgRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern XsimMsgRequestCb XsimMsgRequestJsonProxyReq;

int XsimMsgIndication_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
enum { CHAN_NUM_XsimMsgIndication_msgSource};
extern const uint32_t XsimMsgIndication_reqinfo;

typedef struct {
    uint32_t portal;
    uint32_t data;
} XsimMsgIndication_msgSourceData;
typedef union {
    XsimMsgIndication_msgSourceData msgSource;
} XsimMsgIndicationData;
int XsimMsgIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*msgSource) (  struct PortalInternal *p, const uint32_t portal, const uint32_t data );
} XsimMsgIndicationCb;
extern XsimMsgIndicationCb XsimMsgIndicationProxyReq;

int XsimMsgIndicationJson_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data );
int XsimMsgIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern XsimMsgIndicationCb XsimMsgIndicationJsonProxyReq;

int MyDutRequest_readDRAM ( struct PortalInternal *p, const uint32_t line_addr );
int MyDutRequest_loadDRAM ( struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data );
int MyDutRequest_requestPoints ( struct PortalInternal *p, const Point_Coords point );
int MyDutRequest_reset_dut ( struct PortalInternal *p );
enum { CHAN_NUM_MyDutRequest_readDRAM,CHAN_NUM_MyDutRequest_loadDRAM,CHAN_NUM_MyDutRequest_requestPoints,CHAN_NUM_MyDutRequest_reset_dut};
extern const uint32_t MyDutRequest_reqinfo;

typedef struct {
    uint32_t line_addr;
} MyDutRequest_readDRAMData;
typedef struct {
    uint32_t line_addr;
    DRAM_Line line_data;
} MyDutRequest_loadDRAMData;
typedef struct {
    Point_Coords point;
} MyDutRequest_requestPointsData;
typedef struct {
        int padding;

} MyDutRequest_reset_dutData;
typedef union {
    MyDutRequest_readDRAMData readDRAM;
    MyDutRequest_loadDRAMData loadDRAM;
    MyDutRequest_requestPointsData requestPoints;
    MyDutRequest_reset_dutData reset_dut;
} MyDutRequestData;
int MyDutRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*readDRAM) (  struct PortalInternal *p, const uint32_t line_addr );
    int (*loadDRAM) (  struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data );
    int (*requestPoints) (  struct PortalInternal *p, const Point_Coords point );
    int (*reset_dut) (  struct PortalInternal *p );
} MyDutRequestCb;
extern MyDutRequestCb MyDutRequestProxyReq;

int MyDutRequestJson_readDRAM ( struct PortalInternal *p, const uint32_t line_addr );
int MyDutRequestJson_loadDRAM ( struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data );
int MyDutRequestJson_requestPoints ( struct PortalInternal *p, const Point_Coords point );
int MyDutRequestJson_reset_dut ( struct PortalInternal *p );
int MyDutRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MyDutRequestCb MyDutRequestJsonProxyReq;

int MyDutIndication_returnOutputDDR ( struct PortalInternal *p, const DRAM_Line resp );
int MyDutIndication_returnOutputSV ( struct PortalInternal *p, const Dist_List distances );
enum { CHAN_NUM_MyDutIndication_returnOutputDDR,CHAN_NUM_MyDutIndication_returnOutputSV};
extern const uint32_t MyDutIndication_reqinfo;

typedef struct {
    DRAM_Line resp;
} MyDutIndication_returnOutputDDRData;
typedef struct {
    Dist_List distances;
} MyDutIndication_returnOutputSVData;
typedef union {
    MyDutIndication_returnOutputDDRData returnOutputDDR;
    MyDutIndication_returnOutputSVData returnOutputSV;
} MyDutIndicationData;
int MyDutIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
typedef struct {
    PORTAL_DISCONNECT disconnect;
    int (*returnOutputDDR) (  struct PortalInternal *p, const DRAM_Line resp );
    int (*returnOutputSV) (  struct PortalInternal *p, const Dist_List distances );
} MyDutIndicationCb;
extern MyDutIndicationCb MyDutIndicationProxyReq;

int MyDutIndicationJson_returnOutputDDR ( struct PortalInternal *p, const DRAM_Line resp );
int MyDutIndicationJson_returnOutputSV ( struct PortalInternal *p, const Dist_List distances );
int MyDutIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd);
extern MyDutIndicationCb MyDutIndicationJsonProxyReq;
#ifdef __cplusplus
}
#endif
#endif //__GENERATED_TYPES__
