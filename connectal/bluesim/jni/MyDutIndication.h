#include "GeneratedTypes.h"
#ifndef _MYDUTINDICATION_H_
#define _MYDUTINDICATION_H_
#include "portal.h"

class MyDutIndicationProxy : public Portal {
    MyDutIndicationCb *cb;
public:
    MyDutIndicationProxy(int id, int tile = DEFAULT_TILE, MyDutIndicationCb *cbarg = &MyDutIndicationProxyReq, int bufsize = MyDutIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    MyDutIndicationProxy(int id, PortalTransportFunctions *transport, void *param, MyDutIndicationCb *cbarg = &MyDutIndicationProxyReq, int bufsize = MyDutIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    MyDutIndicationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, MyDutIndication_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&MyDutIndicationProxyReq) {};
    int returnOutputDDR ( const DRAM_Line resp ) { return cb->returnOutputDDR (&pint, resp); };
    int returnOutputSV ( const Dist_List distances ) { return cb->returnOutputSV (&pint, distances); };
};

extern MyDutIndicationCb MyDutIndication_cbTable;
class MyDutIndicationWrapper : public Portal {
public:
    MyDutIndicationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = MyDutIndication_handleMessage, int bufsize = MyDutIndication_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&MyDutIndication_cbTable, this, poller) {
    };
    MyDutIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = MyDutIndication_handleMessage, int bufsize = MyDutIndication_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&MyDutIndication_cbTable, transport, param, this, poller) {
    };
    MyDutIndicationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, MyDutIndication_reqinfo, MyDutIndication_handleMessage, (void *)&MyDutIndication_cbTable, this, poller) {
    };
    MyDutIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, MyDutIndication_reqinfo, MyDutIndication_handleMessage, (void *)&MyDutIndication_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("MyDutIndicationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void returnOutputDDR ( const DRAM_Line resp ) = 0;
    virtual void returnOutputSV ( const Dist_List distances ) = 0;
};
#endif // _MYDUTINDICATION_H_
