#pragma once

#include <string>
#include <array>
#include <unordered_map>
#include <assert.h>

#include <EasyBMP.h>

#include "Server.hpp"
#include "types.hpp"

template<long M, offset_t halfOffsetRange> 
class LoadCompBlocksToCache : public Server<point_t, blocks_cache_t<M, halfOffsetRange>> {
    public:
        LoadCompBlocksToCache(const BMP& img);
        void Put(const point_t in) override;
        blocks_cache_t<M, halfOffsetRange> GetResult() const override;
    private:
        const BMP& _image;
        bool _loadedBlocks;
        blocks_cache_t<M, halfOffsetRange> _blocks;
};

template<long M, offset_t halfOffsetRange> 
LoadCompBlocksToCache<M, halfOffsetRange>::LoadCompBlocksToCache(const BMP& img)
    : _image(img)
    , _loadedBlocks(false) {
}

template<long M, offset_t halfOffsetRange> 
void LoadCompBlocksToCache<M, halfOffsetRange>::Put(const point_t in) {

    for (long r = 0; r < M; r++) {
        for (offset_t c = 0; c < 2 * halfOffsetRange + 1; c++) {
            long i = c + in.x - halfOffsetRange - (long) (M >> 1) - 1;
            long j = (long) (r + in.y) - (long) (M >> 1) - 1;
            const RGBApixel& pixel = _image.GetPixel(i, j);
            assert(r*M+c < (long) _blocks.max_size());
            int blocks_i = r*(2 * halfOffsetRange + 1) +c;
            _blocks[blocks_i] = { pixel.Red, pixel.Green, pixel.Blue };
        }
    }
    _loadedBlocks = true;
}

template<long M, offset_t halfOffsetRange> 
blocks_cache_t<M, halfOffsetRange> LoadCompBlocksToCache<M, halfOffsetRange>::GetResult() const {
    if (!_loadedBlocks) {
        fprintf(stderr, "Cannot call GetBlocksFromCache() before PutPoint() since the _blocks is unset\n");
        exit(1);
    }
    return _blocks;
}
