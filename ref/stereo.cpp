#include <vector>

#include <EasyBMP.h>
#include <fixed_point/fixed_point.hpp>

#include "types.hpp"
#include "StereoVisionSinglePoint.hpp"


namespace {
    void run_test_1() {
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

        const long fpbf = 6;
        const long M = 9;
        const offset_t halfOffsetRange = 25;

        typedef ufp16_t<fpbf> fp;

        fp cameraDistance(0.01);
        fp focalLength(0.1);
        fp pixelPitch(1);

        std::vector<point_t> pointsOfInterest = {
            // {190, 25}
            {119, 206},
            {140, 205},
            {124, 160},
            {200, 180},
            {544, 148}
        };

        StereoVisionSinglePoint<M, halfOffsetRange, fpbf> stereoVisionSinglePoint(left_img, right_img, cameraDistance, focalLength, pixelPitch);
        for (const point_t& poi : pointsOfInterest) {
            stereoVisionSinglePoint.Put(poi);
            const point_3d_t<fp32_t<2*fpbf>> result = stereoVisionSinglePoint.GetResult();
            printf("(%d, %d) -> (%f, %f, %f)\n", poi.x, poi.y, (double) result.x, (double) result.y, (double) result.z);
        }
        

    }
}

int main(/*int argc, char** argv*/) {
    run_test_1();
}

