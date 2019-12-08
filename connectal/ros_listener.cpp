#include "ros_listener.hpp"

int main(int argc, char ** argv) {
  return init_ros(argc, argv);
}

void loadDramLine(const size_t address, uint32_t* data) {
  // printf("Mock loading DRAM address %ld\n", address);
}
void loadPoints(std::vector<uint32_t> xs, std::vector<uint32_t> ys) {
  const size_t n = xs.size();
  printf("Received request to load %ld points\n", n);
  for (size_t i = 0; i < n; i++) {
    printf("(%d,%d)\n", xs[i], ys[i]);
  }
}