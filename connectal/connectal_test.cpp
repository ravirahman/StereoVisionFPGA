#include <stdio.h>
#include <vector>

#include <EasyBMP.h>
//#include <fixed_point/fixed_point.hpp>

//#include "types.hpp"
//#include "StereoVisionSinglePoint.hpp"
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
size_t num_req_dist = 0;

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


    virtual void returnOutputSV( bsvvector_Luint32_t_L2 real_xs, bsvvector_Luint32_t_L2 real_ys, bsvvector_Luint32_t_L2 real_zs ) {
        //printf("Response: [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n"
        //        , data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);
        printf("Distances Received");
	//printf("Received distances 0: %d\n", );
        //printf("Received distance 1: %d\n", data.realys);
        pthread_mutex_lock(&lock);
        num_req_dist--;
        pthread_mutex_unlock(&lock);
    }
    // Required
    MyDutIndication(unsigned int id) : MyDutIndicationWrapper(id) {}
};

void load_images(){
    
    // First of all, get the two images
    BMP left_img;
    bool result = left_img.ReadFromFile("../sample_images/0_left.bmp");
    if (!result) {
         fprintf(stderr, "Failed to read left image from filepath\n");
         exit(1);
    }
    BMP right_img;
    result = right_img.ReadFromFile("../sample_images/0_right.bmp");
    if (!result) {
        fprintf(stderr, "Failed to read right image from filepath\n");
        exit(1);
    }    

    // Now load the reference image into the DRAM
    
    uint32_t ref_address = 0;

    for (long r = 0; r < IMAGE_HEIGHT; r++) {
        for (long c = 0; c < IMAGE_WIDTH; c++) {
            
            const RGBApixel& pixel = left_image.GetPixel(c, r);
            uint32_t pixel_bits = pixel.Red<<32 | pixel.Green<<16 | pixel.Blue<<8 | 0x0000;
            //assert(r*M+c < (long) _blocks.max_size());
            //pixel.Red, pixel.Green, pixel.Blue };
        }

        // Once we have the whole DRAM line, load it
        device->loadDRAM(ref_address, data);
        ref_address = ref_address + 1;
    }


    // Now load the compare image into the DRAM
    
    uint32_t comp_address = COMP_BLOCK_DRAM_OFFSET;

    for (long r = 0; r < IMAGE_HEIGHT; r++) {
        for (long c = 0; c < IMAGE_WIDTH; c++) {
            
            const RGBApixel& pixel = right_image.GetPixel(c, r);
            uint32_t pixel_bits = pixel.Red<<32 | pixel.Green<<16 | pixel.Blue<<8 | 0x0000;
            //assert(r*M+c < (long) _blocks.max_size());
            //pixel.Red, pixel.Green, pixel.Blue };
        }

        // Once we have the whole DRAM line, load it
        device->loadDRAM(comp_address, data);
        comp_address = comp_address + 1;
    }
	
    pthread_mutex_init(&lock, NULL);

}





void request_points(){

    // Here, we will request points on the image. For now, we are making this points up.

    for (uint32_t i = 0; i < 10; i++) {
        pthread_mutex_lock(&lock);
        num_req_dist++;
        pthread_mutex_unlock(&lock);
        bsvvector_Luint6_t_L2 xs;
        bsvvector_Luint6_t_L2 ys;
        xs[0] = 150;
        xs[1] = 10;
        ys[0] = 20;
        ys[1] = 45; 
        printf("Sent distance request");
        device->requestPoints(xs, ys);
    }

}




void run_test_bench(){

    // The very first thing is loading the images into the FPGA memory
    load_images();

    // Once the images are loaded, we just need to request the points
    request_points();   

    // Wait until we retrieve all the points we requested 
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
