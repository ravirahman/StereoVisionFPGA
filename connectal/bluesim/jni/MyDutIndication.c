#include "GeneratedTypes.h"

int MyDutIndication_returnOutputDDR ( struct PortalInternal *p, const DRAM_Line resp )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutIndication_returnOutputDDR, 17);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutIndication_returnOutputDDR, "MyDutIndication_returnOutputDDR")) return 1;
    p->transport->write(p, &temp_working_addr, (resp.data7>>32));
    p->transport->write(p, &temp_working_addr, resp.data7);
    p->transport->write(p, &temp_working_addr, (resp.data6>>32));
    p->transport->write(p, &temp_working_addr, resp.data6);
    p->transport->write(p, &temp_working_addr, (resp.data5>>32));
    p->transport->write(p, &temp_working_addr, resp.data5);
    p->transport->write(p, &temp_working_addr, (resp.data4>>32));
    p->transport->write(p, &temp_working_addr, resp.data4);
    p->transport->write(p, &temp_working_addr, (resp.data3>>32));
    p->transport->write(p, &temp_working_addr, resp.data3);
    p->transport->write(p, &temp_working_addr, (resp.data2>>32));
    p->transport->write(p, &temp_working_addr, resp.data2);
    p->transport->write(p, &temp_working_addr, (resp.data1>>32));
    p->transport->write(p, &temp_working_addr, resp.data1);
    p->transport->write(p, &temp_working_addr, (resp.data0>>32));
    p->transport->write(p, &temp_working_addr, resp.data0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutIndication_returnOutputDDR << 16) | 17, -1);
    return 0;
};

int MyDutIndication_returnOutputSV ( struct PortalInternal *p, const Dist_List distances )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutIndication_returnOutputSV, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutIndication_returnOutputSV, "MyDutIndication_returnOutputSV")) return 1;
    p->transport->write(p, &temp_working_addr, distances.dist0|(((unsigned long)distances.dist1)<<16));
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutIndication_returnOutputSV << 16) | 2, -1);
    return 0;
};

MyDutIndicationCb MyDutIndicationProxyReq = {
    portal_disconnect,
    MyDutIndication_returnOutputDDR,
    MyDutIndication_returnOutputSV,
};
MyDutIndicationCb *pMyDutIndicationProxyReq = &MyDutIndicationProxyReq;

const uint32_t MyDutIndication_reqinfo = 0x20044;
const char * MyDutIndication_methodSignatures()
{
    return "{\"returnOutputDDR\": [\"long\"], \"returnOutputSV\": [\"long\"]}";
}

int MyDutIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MyDutIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MyDutIndication_returnOutputDDR: {
        p->transport->recv(p, temp_working_addr, 16, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data7 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data7 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data6 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data6 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data5 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data5 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data4 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data4 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data3 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data3 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data2 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data2 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data1 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data1 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data0 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputDDR.resp.data0 |= (uint64_t)(((tmp)&0xfffffffful));
        ((MyDutIndicationCb *)p->cb)->returnOutputDDR(p, tempdata.returnOutputDDR.resp);
      } break;
    case CHAN_NUM_MyDutIndication_returnOutputSV: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.returnOutputSV.distances.dist0 = (uint16_t)(((tmp)&0xfffful));
        tempdata.returnOutputSV.distances.dist1 = (uint16_t)(((tmp>>16)&0xfffful));
        ((MyDutIndicationCb *)p->cb)->returnOutputSV(p, tempdata.returnOutputSV.distances);
      } break;
    default:
        PORTAL_PRINTF("MyDutIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MyDutIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
