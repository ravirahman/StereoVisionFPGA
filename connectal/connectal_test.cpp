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
int NUM_PIXELS_PER_DRAM_LINE = 16;


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
    load_single_image(left_img, 0);
    load_single_image(right_img, COMP_BLOCK_DRAM_OFFSET);
   
    pthread_mutex_init(&lock, NULL);

}


void load_single_image(BMP img, uint32_t address_offset){
    
    uint32_t address = address_offset;
  
    int num_rows = img.TellHeight();
    int num_cols = img.TellWidth();
    int cols_padded = num_cols%16; 
    int counter = 0;
    uint512_t data = 0;

    for (long r = 0; r < num_rows; r++) {
        for (long c = 0; c < num_cols; c++) {

                const RGBApixel& pixel = img.GetPixel(c, r);
                uint32_t pixel_bits = pixel.Red<<24 | pixel.Green<<16 | pixel.Blue<<8 | 0x0000;
                data = data | pixel_bits<<counter*32;
		counter = counter + 1;

	        if (counter == NUM_PIXELS_PER_DRAM_LINE) {
        		// Once we have the whole DRAM line, load it
        		device->loadDRAM(address, data);
        		address = address + 1;
                        counter = 0;
			data = 0;
                      
	        }
        }
	
        // If the number of columns is not a multiple of 16, we need to pad and load the last DRAM line
        if (cols_padded != 0) {
        	device->loadDRAM(ref_address, data);
        	address = address + 1;
                counter = 0;
		data = 0;
	}

    }

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
