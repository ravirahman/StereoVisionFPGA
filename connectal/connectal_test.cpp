#include <stdio.h>
#include <vector>

#include "EasyBMP.h"
//#include <fixed_point/fixed_point.hpp>

//#include "types.hpp"
//#include "StereoVisionSinglePoint.hpp"
#include <stdint.h>
#include <sys/stat.h>
#include <pthread.h>

#include "MyDutRequest.h"
#include "MyDutIndication.h"
#include <bitset>

static MyDutRequestProxy *device = 0;

size_t putcount = 0;
size_t gotcount = 0;
const size_t NUM_PIXELS_PER_DRAM_LINE = 16;
const size_t COMP_BLOCK_DRAM_OFFSET = 16384;
const size_t IMAGEWIDTH = 816;

const uint16_t N = 3; // Number of single points in parallel

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
    virtual void returnOutputSV(const bsvvector_Luint32_t_L1 xs, const bsvvector_Luint32_t_L1 ys, const bsvvector_Luint32_t_L1 zs) {
        //printf("Response: [Line Data (512bit): 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx, 0x%08lx]\n"
        //        , data.data7, data.data6, data.data5, data.data4, data.data3, data.data2, data.data1, data.data0);
         
        uint16_t integer_x1 = (uint16_t) (xs[0]>>16);
	uint16_t fractional_x1 = (uint16_t) xs[0];
        
	uint16_t integer_y1 = (uint16_t) (ys[0]>>16);
	uint16_t fractional_y1 = (uint16_t) ys[0];
        
	uint16_t integer_z1 = (uint16_t) (zs[0]>>16);
	uint16_t fractional_z1 = (uint16_t) zs[0];
	
         
        //uint16_t integer_x2 = (uint16_t) (xs[1]>>16);
	//uint16_t fractional_x2 = (uint16_t) xs[1];
        
	//uint16_t integer_y2 = (uint16_t) (ys[1]>>16);
	//uint16_t fractional_y2 = (uint16_t) ys[1];
        
	//uint16_t integer_z2 = (uint16_t) (zs[1]>>16);
	//uint16_t fractional_z2 = (uint16_t) zs[1];
	
        printf("(X,Y,Z) distance of point 1 is (%d.%d, %d.%d, %d.%d) \n", integer_x1, fractional_x1, integer_y1, fractional_y1, integer_z1, fractional_z1);
        //printf("(X,Y,Z) distance of point 2 is (%d.%d, %d.%d, %d.%d) \n", integer_x2, fractional_x2, integer_y2, fractional_y2, integer_z2, fractional_z2);
	//printf("Z received in connectal is:");
	//std::cout << std::bitset<32>(zs[0]);
	//printf("Distances Received\n");

	//printf("Received distances 0: %d\n", );
        //printf("Received distance 1: %d\n", data.realys);
        pthread_mutex_lock(&lock);
        num_req_dist--;
        pthread_mutex_unlock(&lock);
    }
    // Required
    MyDutIndication(unsigned int id) : MyDutIndicationWrapper(id) {}
};



void load_single_image(BMP img, uint32_t address_offset){
    uint32_t address = address_offset;
    size_t num_rows = img.TellHeight();
    size_t num_cols = img.TellWidth();
    if (num_cols > IMAGEWIDTH) {
        fprintf(stderr, "num_cols > IMAGEWIDTH, %ld > %ld", num_rows, IMAGEWIDTH);
        exit(1);
    }
    if ((num_rows * num_cols) / NUM_PIXELS_PER_DRAM_LINE > COMP_BLOCK_DRAM_OFFSET) {
        fprintf(stderr, "address offset of %ld is not sufficiently large", COMP_BLOCK_DRAM_OFFSET);
        exit(1);
    }
    bsvvector_Luint32_t_L16 data;
    printf("The image is %ldx%ld pixels\n", num_rows, num_cols); 
    printf("Start of load image is at address %d\n", address);
    for (size_t r = 0; r < num_rows; r++) {
        for (size_t c = 0; c < IMAGEWIDTH; c++) {
            if (c < num_cols) {
                const RGBApixel& pixel = img.GetPixel(c, r);
                uint32_t pixel_bits = ((uint32_t) pixel.Red)<<24 | ((uint32_t) pixel.Green) <<16 | ((uint32_t) pixel.Blue) <<8 | 0x0000;
		//printf("The bits for the specific pixel are %d, %d, %d \n", pixel.Red, pixel.Green, pixel.Blue);
                //printf("The line being loaded is: ");
		//std::cout << std::bitset<32>(pixel_bits);
                data[c % NUM_PIXELS_PER_DRAM_LINE] = pixel_bits;
            }
            else {
                data[c % NUM_PIXELS_PER_DRAM_LINE] = 0; // otherwise, 0 pad
            }

            if ((c+1) % NUM_PIXELS_PER_DRAM_LINE == 0) {
                // Once we have the whole DRAM line, load it
                device->loadDRAM(address, data);
                address = address + 1;
                //printf("Image loaded in address %d \n", address-1);		     
            }
        }
    }

    printf("End of load image is at address %d\n", address);

}


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




void request_points(){

    // Here, we will request points on the image. For now, we are making this points up.
    //static const uint16_t arr_x[] = {117, 122, 198, 202, 213, 352, 361, 355, 542, 549, 543, 666, 0}; 
    //static const uint16_t arr_y[] = {204, 158, 178, 144, 176, 140, 141, 122, 142, 135, 118, 153, 10};
    static const uint16_t arr_y[] = {10};
    static const uint16_t arr_x[] = {0};
    for (uint32_t i = 0; i < 1; i++) {
        pthread_mutex_lock(&lock);
        num_req_dist++;
        pthread_mutex_unlock(&lock);
        bsvvector_Luint16_t_L1 xs;
        bsvvector_Luint16_t_L1 ys;
        //xs[0] = arr_x[2*i];
        //xs[1] = arr_x[2*i+1];
        //ys[0] = arr_y[2*i];
        //ys[1] = arr_y[2*i+1]; 
        xs[0] = arr_x[i];
	ys[0] = arr_y[i];
        printf("Sent distance request for points (x0,y0) = (%d, %d) and (x1,y1) = (%d, %d) \n", xs[0], ys[0], 0, 0);
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
    while (num_req_dist != 0) {
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
