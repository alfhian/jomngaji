#include <string>
#include <vector>
#include <cstring>

#include "whisper.h"

static whisper_context *ctx = nullptr;

extern "C" {

// -------------------------------------------------------------
// INIT
// -------------------------------------------------------------
bool whisper_init_ff(const char *model_path) {
    if (ctx != nullptr) {
        whisper_free(ctx);
        ctx = nullptr;
    }

    struct whisper_context_params cparams = whisper_context_default_params();

    ctx = whisper_init_from_file_with_params(model_path, cparams);

    if (!ctx) {
        return false;
    }
    return true;
}


// -------------------------------------------------------------
// TRANSCRIBE
// -------------------------------------------------------------
int whisper_transcribe_ff(
    const float *samples,
    int n_samples,
    const char *lang,
    char *out_text,
    int max_len
) {
    if (!ctx) return -1;

    struct whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);

    wparams.language         = lang;
    wparams.no_timestamps    = true;
    wparams.no_context       = true;
    wparams.single_segment   = false;   // better accuracy
    wparams.print_special    = false;
    wparams.print_progress   = false;
    wparams.print_realtime   = false;
    wparams.max_tokens       = 32;      // IMPORTANT
    wparams.translate        = false;

    int ret = whisper_full(ctx, wparams, samples, n_samples);
    if (ret != 0) {
        return -2;
    }

    std::string result;

    int n = whisper_full_n_segments(ctx);
    for (int i = 0; i < n; i++) {
        result += whisper_full_get_segment_text(ctx, i);
        result += " ";
    }

    if ((int)result.size() >= max_len) {
        result = result.substr(0, max_len - 1);
    }

    std::memcpy(out_text, result.c_str(), result.size());
    out_text[result.size()] = '\0';

    return (int)result.size();
}


// -------------------------------------------------------------
// FREE
// -------------------------------------------------------------
void whisper_free_ff() {
    if (ctx) {
        whisper_free(ctx);
        ctx = nullptr;
    }
}

}
