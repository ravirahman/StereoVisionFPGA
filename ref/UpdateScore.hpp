#pragma once

#include <inttypes.h>
#include <array>

#include <EasyBMP.h>

#include "types.hpp"
#include "Server.hpp"

class UpdateScore : public Server<score_offset_t, offset_t> {
    public:
        UpdateScore();
        void Put(const score_offset_t in) override;
        offset_t GetResult() const override;
    private:
        score_offset_t _bestScore;
        bool _hasScore;

};

UpdateScore::UpdateScore()
    : _hasScore(false) {
}

void UpdateScore::Put(const score_offset_t in) {
    if (!_hasScore || in.score < _bestScore.score) {
        _bestScore = in;
    }
    _hasScore = true;
}

offset_t UpdateScore::GetResult() const {
    if (!_hasScore) {
        fprintf(stderr, "Cannot call UpdateScore::GetResult if there is no score to be retrieved\n");
        exit(1);
    }
    return _bestScore.offset;
}
