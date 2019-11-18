#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MyDutRequestJson_readDRAM ( struct PortalInternal *p, const uint32_t line_addr )
{
    Json::Value request;
    request.append(Json::Value("readDRAM"));
    request.append((Json::UInt64)line_addr);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutRequest_readDRAM);
    return 0;
};

int MyDutRequestJson_loadDRAM ( struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data )
{
    Json::Value request;
    request.append(Json::Value("loadDRAM"));
    request.append((Json::UInt64)line_addr);
    Json::Value _line_dataValue;
    _line_dataValue["__type__"]="DRAM_Line";
    _line_dataValue["data7"] = (Json::UInt64)line_data.data7;
    _line_dataValue["data6"] = (Json::UInt64)line_data.data6;
    _line_dataValue["data5"] = (Json::UInt64)line_data.data5;
    _line_dataValue["data4"] = (Json::UInt64)line_data.data4;
    _line_dataValue["data3"] = (Json::UInt64)line_data.data3;
    _line_dataValue["data2"] = (Json::UInt64)line_data.data2;
    _line_dataValue["data1"] = (Json::UInt64)line_data.data1;
    _line_dataValue["data0"] = (Json::UInt64)line_data.data0;
    request.append(_line_dataValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutRequest_loadDRAM);
    return 0;
};

int MyDutRequestJson_requestPoints ( struct PortalInternal *p, const Point_Coords point )
{
    Json::Value request;
    request.append(Json::Value("requestPoints"));
    Json::Value _pointValue;
    _pointValue["__type__"]="Point_Coords";
    _pointValue["y1"] = (Json::UInt64)point.y1;
    _pointValue["x1"] = (Json::UInt64)point.x1;
    _pointValue["y0"] = (Json::UInt64)point.y0;
    _pointValue["x0"] = (Json::UInt64)point.x0;
    request.append(_pointValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutRequest_requestPoints);
    return 0;
};

int MyDutRequestJson_reset_dut ( struct PortalInternal *p )
{
    Json::Value request;
    request.append(Json::Value("reset_dut"));
    

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MyDutRequest_reset_dut);
    return 0;
};

MyDutRequestCb MyDutRequestJsonProxyReq = {
    portal_disconnect,
    MyDutRequestJson_readDRAM,
    MyDutRequestJson_loadDRAM,
    MyDutRequestJson_requestPoints,
    MyDutRequestJson_reset_dut,
};
MyDutRequestCb *pMyDutRequestJsonProxyReq = &MyDutRequestJsonProxyReq;
const char * MyDutRequestJson_methodSignatures()
{
    return "{\"readDRAM\": [\"long\"], \"loadDRAM\": [\"long\", \"long\"], \"requestPoints\": [\"long\"], \"reset_dut\": []}";
}

int MyDutRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MyDutRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MyDutRequest_readDRAM: {
        ((MyDutRequestCb *)p->cb)->readDRAM(p, tempdata.readDRAM.line_addr);
      } break;
    case CHAN_NUM_MyDutRequest_loadDRAM: {
        ((MyDutRequestCb *)p->cb)->loadDRAM(p, tempdata.loadDRAM.line_addr, tempdata.loadDRAM.line_data);
      } break;
    case CHAN_NUM_MyDutRequest_requestPoints: {
        ((MyDutRequestCb *)p->cb)->requestPoints(p, tempdata.requestPoints.point);
      } break;
    case CHAN_NUM_MyDutRequest_reset_dut: {
        ((MyDutRequestCb *)p->cb)->reset_dut(p);
      } break;
    default:
        PORTAL_PRINTF("MyDutRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MyDutRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
