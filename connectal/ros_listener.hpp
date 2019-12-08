#include <inttypes.h>

#include <ros/ros.h>
#include <std_msgs/String.h>
#include <message_filters/subscriber.h>
#include <message_filters/time_synchronizer.h>
#include <geometry_msgs/Point.h>
#include <sensor_msgs/Image.h>
#include "tensorrt_ros/BoundingBox.h"
#include "tensorrt_ros/BoundingBoxes.h"
#include "constants.hpp"

void loadDramLine(const size_t address, uint32_t* data);
void loadPoints(std::vector<uint32_t> xs, std::vector<uint32_t> ys);

static inline void loadImage(const sensor_msgs::ImageConstPtr& img, const size_t addressOffset) {
  size_t address = addressOffset;
  uint32_t data[16];

  for (uint32_t r = 0; r < img->height; r++) {
    for (size_t c = 0; c < IMAGEWIDTH; c++) {
      if (c < img->width) {
        uint8_t blue  = img->data[r * img->height * 3 + c];
        uint8_t green = img->data[r * img->height + 3 + c + 1];
        uint8_t red   = img->data[r * img->height + 3 + c + 2];
        uint32_t pixel_bits = ((uint32_t) red)<<24 | ((uint32_t) green) <<16 | ((uint32_t) blue) <<8 | 0x0000;
        data[c % NUM_PIXELS_PER_DRAM_LINE] = pixel_bits;
      }
      else {
        data[c % NUM_PIXELS_PER_DRAM_LINE] = 0; // otherwise, 0 pad
      }
      if ((c+1) % NUM_PIXELS_PER_DRAM_LINE == 0) {
        // Once we have the whole DRAM line, load it
        // printf("loading address %ld onto dram\n", address);
        loadDramLine(address, data);
        address = address + 1;
        //printf("Image loaded in address %d \n", address-1);		     
      }
      
    }
  }
}

volatile double image_time = -1;
volatile double start_time = -1;


static inline double ros_to_double(ros::Time start_time) {
  const double start_time_dbl = (double) start_time.sec + (((double) start_time.nsec) * 1.0e-9);
  return start_time_dbl;
}

static inline double get_current_time() {
  const ros::Time start_time = ros::Time::now();
  const double start_time_dbl = (double) start_time.sec + (((double) start_time.nsec) * 1.0e-9);
  return start_time_dbl;
}

static inline void imageReceived(const sensor_msgs::ImageConstPtr& left_img, const sensor_msgs::ImageConstPtr& right_img, const tensorrt_ros::BoundingBoxesConstPtr& boundingBoxes) {
  while (image_time != -1) {
    ros::Duration(0.001).sleep();
  }
  image_time = ros_to_double(left_img->header.stamp);
  start_time = get_current_time();
  printf("Starting DRAM loadat time %f\n", start_time);

  printf("Image timestamp: %f\n", image_time);
  loadImage(left_img, 0);
  printf("Finished leftimage DRAM load at %f\n", get_current_time());
  loadImage(right_img, COMP_BLOCK_DRAM_OFFSET);
  printf("Finishing DRAM load at %f\n",  get_current_time());

  // now do the points
  // const size_t n = ;
  std::vector<uint32_t> xs;
  std::vector<uint32_t> ys;

  for (size_t i = 0; i < boundingBoxes->bounding_boxes.size(); i++) {
    const tensorrt_ros::BoundingBox boundingBox = boundingBoxes->bounding_boxes[i];
    const size_t num_keypoints = boundingBox.keypoints.size();
    for (size_t j = 0; j < num_keypoints; j++) {
      const geometry_msgs::Point keypoint = boundingBox.keypoints[j];
      xs.push_back(keypoint.x);
      ys.push_back(keypoint.y);
    }
  }

  loadPoints(xs, ys);
  printf("Finishing loading points at %f\n",  get_current_time());
}

static int init_ros(int argc, char **argv) {
    ros::init(argc, argv, "fpga_stereo_vision");
    ros::NodeHandle nh;

    message_filters::Subscriber<sensor_msgs::Image> lh_sub(nh, "/nerian/left_image", 100);
    message_filters::Subscriber<sensor_msgs::Image> rh_sub(nh, "/nerian/right_image", 100);
    message_filters::Subscriber<tensorrt_ros::BoundingBoxes> poi_sub(nh, "/tensorrt/bounding_boxes1", 100);
    message_filters::TimeSynchronizer<sensor_msgs::Image, sensor_msgs::Image, tensorrt_ros::BoundingBoxes> sync(lh_sub, rh_sub, poi_sub, 100);
    sync.registerCallback(boost::bind(&imageReceived, _1, _2, _3));
    ros::spin();

    return 0;
}
