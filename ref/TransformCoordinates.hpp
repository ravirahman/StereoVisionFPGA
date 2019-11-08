#pragma once

#include <inttypes.h>
#include <array>

#include <fixed_point/fixed_point.hpp>

#include "types.hpp"
#include "Server.hpp"

template <size_t fpbf>
class TransformCoordinates : public Server<point_offset_t, point_3d_t<fp32_t<fpbf*2>>> {
    public:
        TransformCoordinates(const ufp16_t<fpbf> cameraDistance, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch);
        void Put(const point_offset_t in) override;
        point_3d_t<fp32_t<fpbf*2>> GetResult() const override;
    private:
        const ufp16_t<fpbf> _cameraDistance;
        const ufp16_t<fpbf> _focalLength;
        const ufp16_t<fpbf> _pixelPitch;
        point_3d_t<fp32_t<fpbf*2>> _result;
        bool _hasResult;
    
};

template <size_t fpbf>
TransformCoordinates<fpbf>::TransformCoordinates(const ufp16_t<fpbf> cameraDistance, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch)
    : _cameraDistance(cameraDistance)
    , _focalLength(focalLength)
    , _pixelPitch(pixelPitch)
    , _hasResult(false) {
}

template <class T>
struct show_type;

template <size_t fpbf>
void TransformCoordinates<fpbf>::Put(const point_offset_t in) {
    // const ufp16_t<0> x_fp(in.ref.x);
    // const ufp16_t<0> y_fp(in.ref.y);
    // const ufp16_t<0> offset_fp(in.offset);
    const fp32_t<fpbf> denom = (_pixelPitch * in.offset);
    const fp32_t<fpbf> denom_recrip = fp32_t<fpbf * 2>(1.0) / denom;
    // bit shifting to preserve precision
    const fp32_t<fpbf*2> x = (_cameraDistance * in.ref.x) * denom_recrip;
    const fp32_t<fpbf*2> y = (_cameraDistance * in.ref.y) * denom_recrip;
    const fp32_t<fpbf*2> z = (_cameraDistance * _focalLength) * denom_recrip / fp32_t<fpbf>(1.0);
    
    _result = {x, y, z};
    _hasResult = true;
}

template <size_t fpbf>
point_3d_t<fp32_t<fpbf*2>> TransformCoordinates<fpbf>::GetResult() const {
    if (!_hasResult) {
        fprintf(stderr, "Cannot call TransformCoordinates::GetResult if there is no result to be retrieved\n");
        exit(1);
    }
    return _result;
}
