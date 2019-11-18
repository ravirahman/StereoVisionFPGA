#include "GeneratedTypes.h"

int MyDutRequest_readDRAM ( struct PortalInternal *p, const uint32_t line_addr )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutRequest_readDRAM, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutRequest_readDRAM, "MyDutRequest_readDRAM")) return 1;
    p->transport->write(p, &temp_working_addr, line_addr);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutRequest_readDRAM << 16) | 2, -1);
    return 0;
};

int MyDutRequest_loadDRAM ( struct PortalInternal *p, const uint32_t line_addr, const DRAM_Line line_data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutRequest_loadDRAM, 18);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutRequest_loadDRAM, "MyDutRequest_loadDRAM")) return 1;
    p->transport->write(p, &temp_working_addr, line_addr);
    p->transport->write(p, &temp_working_addr, (line_data.data7>>32));
    p->transport->write(p, &temp_working_addr, line_data.data7);
    p->transport->write(p, &temp_working_addr, (line_data.data6>>32));
    p->transport->write(p, &temp_working_addr, line_data.data6);
    p->transport->write(p, &temp_working_addr, (line_data.data5>>32));
    p->transport->write(p, &temp_working_addr, line_data.data5);
    p->transport->write(p, &temp_working_addr, (line_data.data4>>32));
    p->transport->write(p, &temp_working_addr, line_data.data4);
    p->transport->write(p, &temp_working_addr, (line_data.data3>>32));
    p->transport->write(p, &temp_working_addr, line_data.data3);
    p->transport->write(p, &temp_working_addr, (line_data.data2>>32));
    p->transport->write(p, &temp_working_addr, line_data.data2);
    p->transport->write(p, &temp_working_addr, (line_data.data1>>32));
    p->transport->write(p, &temp_working_addr, line_data.data1);
    p->transport->write(p, &temp_working_addr, (line_data.data0>>32));
    p->transport->write(p, &temp_working_addr, line_data.data0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutRequest_loadDRAM << 16) | 18, -1);
    return 0;
};

int MyDutRequest_requestPoints ( struct PortalInternal *p, const Point_Coords point )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutRequest_requestPoints, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutRequest_requestPoints, "MyDutRequest_requestPoints")) return 1;
    p->transport->write(p, &temp_working_addr, point.x0|(((unsigned long)point.y0)<<6)|(((unsigned long)point.x1)<<12)|(((unsigned long)point.y1)<<18));
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutRequest_requestPoints << 16) | 2, -1);
    return 0;
};

int MyDutRequest_reset_dut ( struct PortalInternal *p )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MyDutRequest_reset_dut, 1);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MyDutRequest_reset_dut, "MyDutRequest_reset_dut")) return 1;
    p->transport->write(p, &temp_working_addr, 0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MyDutRequest_reset_dut << 16) | 1, -1);
    return 0;
};

MyDutRequestCb MyDutRequestProxyReq = {
    portal_disconnect,
    MyDutRequest_readDRAM,
    MyDutRequest_loadDRAM,
    MyDutRequest_requestPoints,
    MyDutRequest_reset_dut,
};
MyDutRequestCb *pMyDutRequestProxyReq = &MyDutRequestProxyReq;

const uint32_t MyDutRequest_reqinfo = 0x40048;
const char * MyDutRequest_methodSignatures()
{
    return "{\"readDRAM\": [\"long\"], \"loadDRAM\": [\"long\", \"long\"], \"requestPoints\": [\"long\"], \"reset_dut\": []}";
}

int MyDutRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MyDutRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MyDutRequest_readDRAM: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.readDRAM.line_addr = (uint32_t)(((tmp)&0xfffffffful));
        ((MyDutRequestCb *)p->cb)->readDRAM(p, tempdata.readDRAM.line_addr);
      } break;
    case CHAN_NUM_MyDutRequest_loadDRAM: {
        p->transport->recv(p, temp_working_addr, 17, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_addr = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data7 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data7 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data6 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data6 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data5 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data5 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data4 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data4 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data3 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data3 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data2 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data2 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data1 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data1 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data0 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.loadDRAM.line_data.data0 |= (uint64_t)(((tmp)&0xfffffffful));
        ((MyDutRequestCb *)p->cb)->loadDRAM(p, tempdata.loadDRAM.line_addr, tempdata.loadDRAM.line_data);
      } break;
    case CHAN_NUM_MyDutRequest_requestPoints: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.requestPoints.point.x0 = (uint8_t)(((tmp)&0x3ful));
        tempdata.requestPoints.point.y0 = (uint8_t)(((tmp>>6)&0x3ful));
        tempdata.requestPoints.point.x1 = (uint8_t)(((tmp>>12)&0x3ful));
        tempdata.requestPoints.point.y1 = (uint8_t)(((tmp>>18)&0x3ful));
        ((MyDutRequestCb *)p->cb)->requestPoints(p, tempdata.requestPoints.point);
      } break;
    case CHAN_NUM_MyDutRequest_reset_dut: {
        p->transport->recv(p, temp_working_addr, 0, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        ((MyDutRequestCb *)p->cb)->reset_dut(p);
      } break;
    default:
        PORTAL_PRINTF("MyDutRequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MyDutRequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
