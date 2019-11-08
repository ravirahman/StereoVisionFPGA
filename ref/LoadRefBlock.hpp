#pragma once

#include <inttypes.h>
#include <array>

#include <EasyBMP.h>

#include "Server.hpp"

template <size_t M>
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

template <size_t M>
LoadRefBlock<M>::LoadRefBlock(const BMP& image)
    : _image(image)
    , _putImagePoint(false) {
}

template <size_t M>
void LoadRefBlock<M>::Put(const point_t in) {
    for (size_t r = 0; r < M; r++) {
        for (size_t c = 0; c < M; c++) {
            const RGBApixel& pixel = _image.GetPixel(r + in.y, c + in.x);
            assert(r*M+c < _block.max_size());
            _block[r * M + c] = { pixel.Red, pixel.Green, pixel.Blue };
        }
    }
    _putImagePoint = true;
}

template <size_t M>
block_t<M> LoadRefBlock<M>::GetResult() const {
    if (!_putImagePoint) {
        fprintf(stderr, "Cannot call LoadRefBlock::GetResult() before LoadRefBlock::Put() since _block is undefined\n");
        exit(1);
    }
    return _block;
}
