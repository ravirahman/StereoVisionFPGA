#include <inttypes.h>
#include <array>

#include "Server.hpp"
#include "types.hpp"

template <long M, offset_t halfOffsetRange>
class LoadCompBlock : public Server<blocks_cache_offset_t<M, halfOffsetRange>, block_t<M>> {
    public:
        LoadCompBlock();
        void Put(const blocks_cache_offset_t<M, halfOffsetRange> in) override;
        block_t<M> GetResult() const override;
    private:
        block_t<M> _block;
        bool _putOffset;

};

template <long M, offset_t halfOffsetRange>
LoadCompBlock<M, halfOffsetRange>::LoadCompBlock()
    : _putOffset(false) {
}

template <long M, offset_t halfOffsetRange>
void LoadCompBlock<M, halfOffsetRange>::Put(const blocks_cache_offset_t<M, halfOffsetRange> in) {
    for (long r = 0; r < (long) M; r++) {
        for (long c = 0; c < (long) M; c++) {
            long effective_c = c + (in.offset + halfOffsetRange);
            long row_len = 1 + 2 * halfOffsetRange;
            assert(effective_c < row_len);
            assert(effective_c >= 0);
            size_t i = r * M + c;
            assert(i < _block.size());
            _block[i] = in.blocks_cache[r * (row_len) + c + (in.offset + halfOffsetRange)];
        }
    }
    _putOffset = true;
}

template <long M, offset_t halfOffsetRange>
block_t<M> LoadCompBlock<M, halfOffsetRange>::GetResult() const {
    if (!_putOffset) {
        fprintf(stderr, "LoadCompBlock::Put() must be called before LoadCompBlock::GetResult()\n");
        exit(1);
    }
    return _block;
}
