#include <inttypes.h>
#include <array>
#include <assert.h>

#include "types.hpp"
#include "Server.hpp"

template <long M>
class ComputeScore: public Server<ref_comp_t<M>, score_t> {
    public:
        ComputeScore();
        void Put(const ref_comp_t<M> in) override;
        score_t GetResult() const override;
    private:
        score_t _score;
        bool _hasScore;

};

template <long M>
ComputeScore<M>::ComputeScore()
    : _hasScore(false) {

}

template <long M>
void ComputeScore<M>::Put(const ref_comp_t<M> in) {
    _score = 0;
    for (size_t i = 0; i < in.ref.size(); ++i) {
        for (size_t j = 0; j < in.ref[i].size(); ++j) {  // pixel dimensions
            _score += MAX(in.ref[i][j], in.comp[i][j]) - MIN(in.ref[i][j], in.comp[i][j]);
        }
    }
    _hasScore = true;
}

template <long M>
score_t ComputeScore<M>::GetResult() const {
    if (!_hasScore) {
        fprintf(stderr, "Cannot call ComputeScore::GtScore if there is no score to be retrieved\n");
        exit(1);
    }
    return _score;
}
