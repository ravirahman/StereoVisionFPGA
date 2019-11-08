#pragma once

#include <inttypes.h>
#include <array>

#include <EasyBMP.h>
#include <fixed_point/fixed_point.hpp>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))


typedef size_t score_t;

typedef size_t offset_t;

typedef std::array<uint8_t, 3> pixel_t;

struct point_t {
    uint16_t x;
    uint16_t y;
};

template <size_t M>
using block_t = std::array<pixel_t,  M * M>;

template <size_t M, size_t numBlocks>
using blocks_cache_t = std::array<pixel_t, M * (M - 1 + numBlocks)>;

template <size_t M, size_t numBlocks>
struct blocks_cache_offset_t {
    const blocks_cache_t<M, numBlocks> blocks_cache;
    const offset_t offset;
};

template <size_t M>
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
