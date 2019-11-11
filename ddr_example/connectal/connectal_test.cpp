#include <stdio.h>
#include <stdint.h>
#include <sys/stat.h>
#include <pthread.h>

#include "MyDutRequest.h"
#include "MyDutIndication.h"

static MyDutRequestProxy *device = 0;

size_t putcount = 0;
size_t gotcount = 0;

// You need a lock when variables are shared by multiple threads:
// (1) the thread that sends request to HW and (2) another thread that processes indications from HW
pthread_mutex_t lock;
size_t num_req_sent = 0;

// The seperate thread in charge of indications invokes these call-back functions
class MyDutIndication : public MyDutIndicationWrapper
{
public:
    // You have to define all the functions (indication methods) defined in MyDutIndication
    virtual void returnOutput(DRAM_Line data) {
        printf("Response: [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n"
                , data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);

        pthread_mutex_lock(&lock);
        num_req_sent--;
        pthread_mutex_unlock(&lock);
    }

    // Required
    MyDutIndication(unsigned int id) : MyDutIndicationWrapper(id) {}
};

void run_test_bench(){
    pthread_mutex_init(&lock, NULL);

    for (uint32_t i = 0; i < 10; i++) {
        DRAM_Line data = { 0, 0, 0, 0, 0, 0, 0, i }; // each item is uint64_t 
        printf("Sent write request [Line Addr: %d] [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n",
                i,
                data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);
        device->loadDRAM(i, data);
    }

    for (uint32_t i = 0; i < 10; i++) {
        pthread_mutex_lock(&lock);
        num_req_sent++;
        pthread_mutex_unlock(&lock);

        printf("Sent read request [Line Addr: %d]\n", i);
        device->readDRAM(i);
    }

    struct timespec one_ms = {0, 1000000};
    pthread_mutex_lock(&lock);
    while (num_req_sent != 0) {
        pthread_mutex_unlock(&lock);
        nanosleep(&one_ms , NULL);
        pthread_mutex_lock(&lock);
    }
    pthread_mutex_unlock(&lock);

    pthread_mutex_destroy(&lock);
    printf("run_test_bench finished!\n");
}

int main (int argc, const char **argv)
{
    // Service Indication messages from HW - Register the call-back functions to a indication thread
    MyDutIndication myIndication (IfcNames_MyDutIndicationH2S);

    // Open a channel to FPGA to issue requests
    device = new MyDutRequestProxy(IfcNames_MyDutRequestS2H);

    // Invoke reset_dut method of HW request ifc (Soft-reset)
    device->reset_dut();

    // Run the testbench: send in.cpm
    run_test_bench();
}
