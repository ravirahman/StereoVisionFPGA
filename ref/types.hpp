#pragma once

#include <inttypes.h>
#include <array>

#include <EasyBMP.h>
#include <fixed_point/fixed_point.hpp>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))


typedef long score_t;

typedef long offset_t; // long since offset can be negative

typedef std::array<uint8_t, 3> pixel_t;

struct point_t {
    int16_t x;
    int16_t y;
};

template <long M>
using block_t = std::array<pixel_t,  M * M>;

template <long M, long halfOffsetRange>
using blocks_cache_t = std::array<pixel_t, M * (1 + 2* halfOffsetRange)>;

template <long M, long halfOffsetRange>
struct blocks_cache_offset_t {
    const blocks_cache_t<M, halfOffsetRange> blocks_cache;
    const offset_t offset;
};

template <long M>
struct ref_comp_t {
    const block_t<M> ref;
    const block_t<M> comp;
};

struct score_offset_t {
    score_t score;
    offset_t offset;
};

struct image_pair_t {
    BMP ref_img;
    BMP comp_img;
};

template <class fp>
struct point_3d_t {
    fp x;
    fp y;
    fp z;
};

struct point_offset_t {
    point_t ref;
    offset_t offset;
};
