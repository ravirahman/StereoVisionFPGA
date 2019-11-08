#include <inttypes.h>
#include <array>

#include "types.hpp"
#include "Server.hpp"

template <size_t M>
class ComputeScore: public Server<ref_comp_t<M>, score_t> {
    public:
        ComputeScore();
        void Put(const ref_comp_t<M> in) override;
        score_t GetResult() const override;
    private:
        std::array<pixel_t, M * M> _block;
        score_t _score;
        bool _hasScore;

};

template <size_t M>
ComputeScore<M>::ComputeScore()
    : _hasScore(false) {

}

template <size_t M>
void ComputeScore<M>::Put(const ref_comp_t<M> in) {
    // todo. copy and paste matlab code
    _score = 0;
    for (size_t i = 0; i < in.ref.size(); ++i) {
        for (size_t j = 0; j < in.ref[i].size(); ++j) {
            _score += MAX(in.ref[i][j], in.comp[i][j]) - MIN(in.ref[i][j], in.comp[i][j]);
        }
    }
    _hasScore = true;
}

template <size_t M>
score_t ComputeScore<M>::GetResult() const {
    if (!_hasScore) {
        fprintf(stderr, "Cannot call ComputeScore::GtScore if there is no score to be retrieved\n");
        exit(1);
    }
    return _score;
}
