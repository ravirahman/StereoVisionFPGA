#pragma once

#include <bitset>
#include <fixed_point/fixed_point.hpp>
#include <EasyBMP.h>

#include "types.hpp"
#include "Server.hpp"
#include "ComputeScore.hpp"
#include "LoadCompBlock.hpp"
#include "LoadCompBlocksToCache.hpp"
#include "LoadRefBlock.hpp"
#include "UpdateScore.hpp"
#include "TransformCoordinates.hpp"
#include "TransformCoordinatesNoop.hpp"

template<long M, offset_t halfOffsetRange, long fpbf>
class StereoVisionSinglePoint: public Server<point_t, point_3d_t<fp32_t<2*fpbf>>> {
    public:
        StereoVisionSinglePoint(const BMP& ref_img, const BMP& comp_img, const ufp16_t<fpbf> cameraDistanace, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch);
        void Put(const point_t in) override;
        point_3d_t<fp32_t<2*fpbf>> GetResult() const override;
    private:
        LoadRefBlock<M> _loadRefBlock;
        LoadCompBlocksToCache<M, halfOffsetRange> _loadCompBlocksToCache;
        LoadCompBlock<M, halfOffsetRange> _loadCompBlock;
        ComputeScore<M> _computeScore;
        UpdateScore _updateScore;
        // TransformCoordinates<fpbf> _transformCoordinates;
        TransformCoordinatesNoop<fpbf> _transformCoordinates;
        
        point_3d_t<fp32_t<2*fpbf>> _result;
        bool _pointSet;
};

template<long M, offset_t halfOffsetRange, long fpbf>
StereoVisionSinglePoint<M, halfOffsetRange, fpbf>::StereoVisionSinglePoint(const BMP& ref_img, const BMP& comp_img, const ufp16_t<fpbf> cameraDistanace, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch)
    : _loadRefBlock(ref_img)
    , _loadCompBlocksToCache(comp_img)
    , _loadCompBlock(LoadCompBlock<M, halfOffsetRange>())
    , _computeScore(ComputeScore<M>())
    , _updateScore(UpdateScore())
    // , _transformCoordinates(TransformCoordinates<fpbf>(cameraDistanace, focalLength, pixelPitch))
    , _transformCoordinates(TransformCoordinatesNoop<fpbf>())
    , _pointSet(false) {
}

template<long M, offset_t halfOffsetRange, long fpbf>
void StereoVisionSinglePoint<M, halfOffsetRange,  fpbf>::Put(const point_t in) {
    _loadRefBlock.Put(in);
    _loadCompBlocksToCache.Put(in);
    for (offset_t i = -halfOffsetRange; i <= halfOffsetRange + 1 - M; i++) {
        _loadCompBlock.Put({_loadCompBlocksToCache.GetResult(), i});
        _computeScore.Put({_loadRefBlock.GetResult(), _loadCompBlock.GetResult()});
        _updateScore.Put({_computeScore.GetResult(), i});
    }
    _transformCoordinates.Put({in, _updateScore.GetResult()});
    _result = _transformCoordinates.GetResult();
    _pointSet = true;
}

template<long M, offset_t halfOffsetRange, long fpbf>
point_3d_t<fp32_t<2*fpbf>> StereoVisionSinglePoint<M, halfOffsetRange, fpbf>::GetResult() const {
    if (!_pointSet) {
        fprintf(stderr, "Cannot call GetScore() before PutPoint() in StereoVisionSinglePoint\n");
        exit(1);
    }
    
    return _result;
}
