#include <stdio.h>
#include <vector>
#include <arpa/inet.h>
#include "EasyBMP.h"
#include <time.h>

#include <stdint.h>
#include <sys/stat.h>
#include <pthread.h>

#include "MyDutRequest.h"
#include "MyDutIndication.h"
#include <bitset>

static MyDutRequestProxy *device = 0;

size_t putcount = 0;
size_t gotcount = 0;

#include "constants.hpp"
#include "ros_listener.hpp"

typedef bsvvector_Luint32_t_L5 return_data_type_t;
typedef bsvvector_Luint16_t_L5 send_data_type_t;

// You need a lock when variables are shared by multiple threads:
// (1) the thread that sends request to HW and (2) another thread that processes indications from HW
pthread_mutex_t lock;
volatile size_t num_req_dist = 0;

// The seperate thread in charge of indications invokes these call-back functions
class MyDutIndication : public MyDutIndicationWrapper
{
public:
    // You have to define all the functions (indication methods) defined in MyDutIndication

    // In principle we don't need this.
    //virtual void returnOutputDDR(DRAM_Line data) {
    //    printf("Response: [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n"
    //            , data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);

    //    pthread_mutex_lock(&lock);
    //    num_req_sent--;
    //    pthread_mutex_unlock(&lock);
    //}
    virtual void returnOutputSV(const return_data_type_t xs, const return_data_type_t ys, const return_data_type_t zs, uint32_t counts) {
        //printf("Response: [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n"
        //        , data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);
        double end_time = get_current_time();
        printf("Received data back at %f\n", end_time);

        for (size_t i = 0; i < N; i++) {
            uint16_t integer_x1 = (uint16_t) (xs[i]>>16);
            uint16_t fractional_x1 = (uint16_t) xs[i];
            double x = (double) integer_x1 + ((double) fractional_x1) / ((double) UINT16_MAX);

            uint16_t integer_y1 = (uint16_t) (ys[i]>>16);
            uint16_t fractional_y1 = (uint16_t) ys[i];
            double y = (double) integer_y1 + ((double) fractional_y1) / ((double) UINT16_MAX);

                
            uint16_t integer_z1 = (uint16_t) (zs[i]>>16);
            uint16_t fractional_z1 = (uint16_t) zs[i];
            double z = (double) integer_z1 + ((double) fractional_z1) / ((double) UINT16_MAX);
            printf("(X,Y,Z) distance of point %ld is (%f, %f, %f) \n", i, x, y, z);
        }
        
        printf("The elapsed number of cycles is %d \n", counts);

        pthread_mutex_lock(&lock);
        num_req_dist--;
        if (num_req_dist == 0) {
            printf("FPGA LATENCY: %f\n", end_time - start_time);
            printf("TOTAL LATENCY: %f\n", end_time - image_time);
            start_time = -1;
            image_time = -1;
        }
        pthread_mutex_unlock(&lock);
    }
    // Required
    MyDutIndication(unsigned int id) : MyDutIndicationWrapper(id) {}
};


void loadDramLine(const size_t address, uint32_t* data) {
  while (num_req_dist > 0) {
      // sleep for 1ms
    //   printf("spinning!!!\n");
      ros::Duration(0.001).sleep();
  }
  // we finished processing the previous points; now load the image
  device->loadDRAM(address, data);
}


void loadPoints(std::vector<uint32_t> x_arr, std::vector<uint32_t> y_arr) {
    const size_t num_points = x_arr.size();
//  printf("Received request to load %ld points\n", n);
    for (size_t i = 0; i < num_points; i += N) {
        pthread_mutex_lock(&lock);
        num_req_dist++;
        pthread_mutex_unlock(&lock);
        send_data_type_t xs;
        send_data_type_t ys;
        for (size_t j = 0; j < N; j++) {
            if (i + j < num_points) {
                xs[j] = x_arr[i+j] - NPIXELS/2;
                ys[j] = y_arr[i+j] - NPIXELS/2;
            }
            else {
                xs[j] = IMAGEWIDTH - 10;
                ys[j] = IMAGEWIDTH - 10;
            }
        }
        printf("Sent distance request for points (x0,y0) = (%d, %d) and (x1,y1) = (%d, %d) \n", xs[0], ys[0], xs[1], ys[1]);
        device->requestPoints(xs, ys);
    }
}

int main (int argc, char **argv)
{
    // Service Indication messages from HW - Register the call-back functions to a indication thread
    MyDutIndication myIndication (IfcNames_MyDutIndicationH2S);

    // Open a channel to FPGA to issue requests
    device = new MyDutRequestProxy(IfcNames_MyDutRequestS2H);

    // Invoke reset_dut method of HW request ifc (Soft-reset)
    device->reset_dut();

    pthread_mutex_init(&lock, NULL);
	
    init_ros(argc, argv);

    // cleanup
    free(device);
}
