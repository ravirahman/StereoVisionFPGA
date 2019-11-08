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

template<size_t M, size_t numBlocks, size_t fpbf>
class StereoVisionSinglePoint: public Server<point_t, point_3d_t<fp32_t<2*fpbf>>> {
    public:
        StereoVisionSinglePoint(const BMP& ref_img, const BMP& comp_img, const ufp16_t<fpbf> cameraDistanace, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch);
        void Put(const point_t in) override;
        point_3d_t<fp32_t<2*fpbf>> GetResult() const override;
    private:
        LoadRefBlock<M> _loadRefBlock;
        LoadCompBlocksToCache<M, numBlocks> _loadCompBlocksToCache;
        LoadCompBlock<M, numBlocks> _loadCompBlock;
        ComputeScore<M> _computeScore;
        UpdateScore _updateScore;
        TransformCoordinates<fpbf> _transformCoordinates;
        
        point_3d_t<fp32_t<2*fpbf>> _result;
        bool _pointSet;
};

template<size_t M, size_t numBlocks, size_t fpbf>
StereoVisionSinglePoint<M, numBlocks, fpbf>::StereoVisionSinglePoint(const BMP& ref_img, const BMP& comp_img, const ufp16_t<fpbf> cameraDistanace, const ufp16_t<fpbf> focalLength, const ufp16_t<fpbf> pixelPitch)
    : _loadRefBlock(ref_img)
    , _loadCompBlocksToCache(comp_img)
    , _loadCompBlock(LoadCompBlock<M, numBlocks>())
    , _computeScore(ComputeScore<M>())
    , _updateScore(UpdateScore())
    , _transformCoordinates(TransformCoordinates<fpbf>(cameraDistanace, focalLength, pixelPitch))
    , _pointSet(false) {
}

template<size_t M, size_t numBlocks, size_t fpbf>
void StereoVisionSinglePoint<M, numBlocks,  fpbf>::Put(const point_t in) {
    _loadRefBlock.Put(in);
    _loadCompBlocksToCache.Put(in);
    for (size_t i = 0; i < numBlocks; i++) {
        _loadCompBlock.Put({_loadCompBlocksToCache.GetResult(), i});
        _computeScore.Put({_loadRefBlock.GetResult(), _loadCompBlock.GetResult()});
        _updateScore.Put({_computeScore.GetResult(), i});
    }
    _transformCoordinates.Put({in, _updateScore.GetResult()});
    _result = _transformCoordinates.GetResult();
    _pointSet = true;
}

template<size_t M, size_t numBlocks, size_t fpbf>
point_3d_t<fp32_t<2*fpbf>> StereoVisionSinglePoint<M, numBlocks, fpbf>::GetResult() const {
    if (!_pointSet) {
        fprintf(stderr, "Cannot call GetScore() before PutPoint() in StereoVisionSinglePoint\n");
        exit(1);
    }
    
    return _result;
}
