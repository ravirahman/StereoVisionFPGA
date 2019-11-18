#include "GeneratedTypes.h"
#ifndef _MYDUTREQUEST_H_
#define _MYDUTREQUEST_H_
#include "portal.h"

class MyDutRequestProxy : public Portal {
    MyDutRequestCb *cb;
public:
    MyDutRequestProxy(int id, int tile = DEFAULT_TILE, MyDutRequestCb *cbarg = &MyDutRequestProxyReq, int bufsize = MyDutRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    MyDutRequestProxy(int id, PortalTransportFunctions *transport, void *param, MyDutRequestCb *cbarg = &MyDutRequestProxyReq, int bufsize = MyDutRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    MyDutRequestProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, MyDutRequest_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&MyDutRequestProxyReq) {};
    int readDRAM ( const uint32_t line_addr ) { return cb->readDRAM (&pint, line_addr); };
    int loadDRAM ( const uint32_t line_addr, const DRAM_Line line_data ) { return cb->loadDRAM (&pint, line_addr, line_data); };
    int requestPoints ( const Point_Coords point ) { return cb->requestPoints (&pint, point); };
    int reset_dut (  ) { return cb->reset_dut (&pint); };
};

extern MyDutRequestCb MyDutRequest_cbTable;
class MyDutRequestWrapper : public Portal {
public:
    MyDutRequestWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = MyDutRequest_handleMessage, int bufsize = MyDutRequest_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&MyDutRequest_cbTable, this, poller) {
    };
    MyDutRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = MyDutRequest_handleMessage, int bufsize = MyDutRequest_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&MyDutRequest_cbTable, transport, param, this, poller) {
    };
    MyDutRequestWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, MyDutRequest_reqinfo, MyDutRequest_handleMessage, (void *)&MyDutRequest_cbTable, this, poller) {
    };
    MyDutRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, MyDutRequest_reqinfo, MyDutRequest_handleMessage, (void *)&MyDutRequest_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("MyDutRequestWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void readDRAM ( const uint32_t line_addr ) = 0;
    virtual void loadDRAM ( const uint32_t line_addr, const DRAM_Line line_data ) = 0;
    virtual void requestPoints ( const Point_Coords point ) = 0;
    virtual void reset_dut (  ) = 0;
};
#endif // _MYDUTREQUEST_H_
