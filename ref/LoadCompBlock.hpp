#include <inttypes.h>
#include <array>

#include "Server.hpp"
#include "types.hpp"

template <size_t M, size_t numBlocks>
class LoadCompBlock : public Server<blocks_cache_offset_t<M, numBlocks>, block_t<M>> {
    public:
        LoadCompBlock();
        void Put(const blocks_cache_offset_t<M, numBlocks> in) override;
        block_t<M> GetResult() const override;
    private:
        block_t<M> _block;
        bool _putOffset;

};

template <size_t M, size_t numBlocks>
LoadCompBlock<M, numBlocks>::LoadCompBlock()
    : _putOffset(false) {
}

template <size_t M, size_t numBlocks>
void LoadCompBlock<M, numBlocks>::Put(const blocks_cache_offset_t<M, numBlocks> in) {
    for (size_t r = 0; r < M; r++) {
        for (size_t c = 0; c < M; c++) {
            _block[r * M + c] = in.blocks_cache[r * (numBlocks + M - 1) + c + in.offset];
        }
    }
    _putOffset = true;
}

template <size_t M, size_t numBlocks>
block_t<M> LoadCompBlock<M, numBlocks>::GetResult() const {
    if (!_putOffset) {
        fprintf(stderr, "LoadCompBlock::Put() must be called before LoadCompBlock::GetResult()\n");
        exit(1);
    }
    return _block;
}
