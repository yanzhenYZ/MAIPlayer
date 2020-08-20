#ifndef __MSBLOCAL_H__
#define __MSBLOCAL_H__

#ifdef __cplusplus
extern "C"
{
#endif
#include "libavformat/avformat.h"

#ifdef __cplusplus
};
#endif

#ifdef __cplusplus
extern "C"
{
#endif
int video_scale(AVCodecContext* avctx, AVFrame* frame);

int media_stop(int flag);
#ifdef __cplusplus
};
#endif

#endif
