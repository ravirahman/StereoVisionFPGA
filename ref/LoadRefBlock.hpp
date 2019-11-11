#pragma once

#include <inttypes.h>
#include <array>

#include <EasyBMP.h>

#include "Server.hpp"

template <long M>
class LoadRefBlock : public Server<point_t, block_t<M>> {
    public:
        LoadRefBlock(const BMP& image);
        void Put(const point_t in) override;
        block_t<M> GetResult() const override;
    private:
        block_t<M> _block;
        const BMP& _image;
        bool _putImagePoint;

};

template <long M>
LoadRefBlock<M>::LoadRefBlock(const BMP& image)
    : _image(image)
    , _putImagePoint(false) {
}

template <long M>
void LoadRefBlock<M>::Put(const point_t in) {
    for (long r = 0; r < M; r++) {
        for (long c = 0; c < M; c++) {
            long i = (long) (c + in.x) - (long) (M >> 1) - 1;
            long j = (long) (r + in.y) - (long) (M >> 1) - 1;
            const RGBApixel& pixel = _image.GetPixel(i, j);
            assert(r*M+c < (long) _block.max_size());
            _block[r * M + c] = { pixel.Red, pixel.Green, pixel.Blue };
        }
    }
    _putImagePoint = true;
}

template <long M>
block_t<M> LoadRefBlock<M>::GetResult() const {
    if (!_putImagePoint) {
        fprintf(stderr, "Cannot call LoadRefBlock::GetResult() before LoadRefBlock::Put() since _block is undefined\n");
        exit(1);
    }
    return _block;
}
