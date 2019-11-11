#pragma once

#include <inttypes.h>
#include <array>

#include <fixed_point/fixed_point.hpp>

#include "types.hpp"
#include "Server.hpp"

template <long fpbf>
class TransformCoordinatesNoop : public Server<point_offset_t, point_3d_t<fp32_t<fpbf*2>>> {
    public:
        TransformCoordinatesNoop();
        void Put(const point_offset_t in) override;
        point_3d_t<fp32_t<fpbf*2>> GetResult() const override;
    private:
        point_3d_t<fp32_t<fpbf*2>> _result;
        bool _hasResult;
    
};

template <long fpbf>
TransformCoordinatesNoop<fpbf>::TransformCoordinatesNoop()
    : _hasResult(false) {
}

template <long fpbf>
void TransformCoordinatesNoop<fpbf>::Put(const point_offset_t in) {
    const fp32_t<fpbf*2> x = fp32_t<fpbf*2>(in.offset + in.ref.x);
    const fp32_t<fpbf*2> y = fp32_t<fpbf*2>(in.ref.y);
    const fp32_t<fpbf*2> z = fp32_t<fpbf*2>(0);
    
    _result = {x, y, z};
    _hasResult = true;
}

template <long fpbf>
point_3d_t<fp32_t<fpbf*2>> TransformCoordinatesNoop<fpbf>::GetResult() const {
    if (!_hasResult) {
        fprintf(stderr, "Cannot call TransformCoordinates::GetResult if there is no result to be retrieved\n");
        exit(1);
    }
    return _result;
}
