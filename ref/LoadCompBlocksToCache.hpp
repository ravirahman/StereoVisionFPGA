#pragma once

#include <string>
#include <array>
#include <unordered_map>
#include <assert.h>

#include <EasyBMP.h>

#include "Server.hpp"
#include "types.hpp"

template<size_t M, size_t numBlocks> 
class LoadCompBlocksToCache : public Server<point_t, blocks_cache_t<M, numBlocks>> {
    public:
        LoadCompBlocksToCache(const BMP& img);
        void Put(const point_t in) override;
        blocks_cache_t<M, numBlocks> GetResult() const override;
    private:
        const BMP& _image;
        bool _loadedBlocks;
        blocks_cache_t<M, numBlocks> _blocks;
};

template<size_t M, size_t numBlocks> 
LoadCompBlocksToCache<M, numBlocks>::LoadCompBlocksToCache(const BMP& img)
    : _image(img)
    , _loadedBlocks(false) {
}

template<size_t M, size_t numBlocks> 
void LoadCompBlocksToCache<M, numBlocks>::Put(const point_t in) {
    for (size_t r = 0; r < M; r++) {
        for (size_t c = 0; c < M + numBlocks - 1; c++) {
            const RGBApixel& pixel = _image.GetPixel(r + in.y, c + in.x);
            assert(r*M+c < _blocks.max_size());
            _blocks[r * M + c] = { pixel.Red, pixel.Green, pixel.Blue };
        }
    }
    _loadedBlocks = true;
}

template<size_t M, size_t numBlocks> 
blocks_cache_t<M, numBlocks> LoadCompBlocksToCache<M, numBlocks>::GetResult() const {
    if (!_loadedBlocks) {
        fprintf(stderr, "Cannot call GetBlocksFromCache() before PutPoint() since the _blocks is unset\n");
        exit(1);
    }
    return _blocks;
}
