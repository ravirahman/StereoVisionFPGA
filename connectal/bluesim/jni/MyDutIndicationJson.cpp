#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MyDutIndicationJson_returnOutputDDR ( struct PortalInternal *p, const DRAM_Line resp )
{
    Json::Value request;
    request.append(Json::Value("returnOutputDDR"));
    Json::Value _respValue;
    _respValue["__type__"]="DRAM_Line";
    _respValue["data7"] = (Json::UInt64)resp.data7;
    _respValue["data6"] = (Json::UInt64)resp.data6;
    _respValue["data5"] = (Json::UInt64)resp.data5;
    _respValue["data4"] = (Json::UInt64)resp.data4;
    _respValue["data3"] = (Json::UInt64)resp.data3;
    _respValue["data2"] = (Json::UInt64)resp.data2;
    _respValue["data1"] = (Json::UInt64)resp.data1;
    _respValue["data0"] = (Json::UInt64)resp.data0;
    request.append(_respValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutIndication_returnOutputDDR);
    return 0;
};

int MyDutIndicationJson_returnOutputSV ( struct PortalInternal *p, const Dist_List distances )
{
    Json::Value request;
    request.append(Json::Value("returnOutputSV"));
    Json::Value _distancesValue;
    _distancesValue["__type__"]="Dist_List";
    _distancesValue["dist1"] = (Json::UInt64)distances.dist1;
    _distancesValue["dist0"] = (Json::UInt64)distances.dist0;
    request.append(_distancesValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutIndication_returnOutputSV);
    return 0;
};

MyDutIndicationCb MyDutIndicationJsonProxyReq = {
    portal_disconnect,
    MyDutIndicationJson_returnOutputDDR,
    MyDutIndicationJson_returnOutputSV,
};
MyDutIndicationCb *pMyDutIndicationJsonProxyReq = &MyDutIndicationJsonProxyReq;
const char * MyDutIndicationJson_methodSignatures()
{
    return "{\"returnOutputDDR\": [\"long\"], \"returnOutputSV\": [\"long\"]}";
}

int MyDutIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MyDutIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MyDutIndication_returnOutputDDR: {
        ((MyDutIndicationCb *)p->cb)->returnOutputDDR(p, tempdata.returnOutputDDR.resp);
      } break;
    case CHAN_NUM_MyDutIndication_returnOutputSV: {
        ((MyDutIndicationCb *)p->cb)->returnOutputSV(p, tempdata.returnOutputSV.distances);
      } break;
    default:
        PORTAL_PRINTF("MyDutIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MyDutIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
