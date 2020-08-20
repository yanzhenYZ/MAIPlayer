#ifndef __MSBMEDIAMANAGER_H__
#define __MSBMEDIAMANAGER_H__

#ifdef __cplusplus
extern "C"
{
#endif
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"
#include "libavutil/imgutils.h"
#ifdef __cplusplus
};
#endif
#include "../inc/MSBMedia.h"

using namespace MSBMedia;
namespace YANZHEN {
	class MSBMediaManager : public MSBMediaScale {
		private:
			MSBMediaManager();
		public:
			static MSBMediaManager* getInstance();
			static void releaseInstance();
			virtual ~MSBMediaManager();

		public:
			virtual int video_init(VideoCallBack videocb);

		public:
			int video_scale(AVCodecContext* avctx, AVFrame* frame);
			int video_exit();

		private:
			int video_init(AVCodecContext* avctx, AVFrame* frame);

		private:
			static MSBMediaManager* m_ptMediaMgr;

			VideoCallBack m_CBVideo;
			uint8_t* m_pOutBuffer;
			SwsContext* m_ptImgConCtx;
			AVFrame* m_ptDstFrame;
			int m_nVideoInited;
	};
}
#endif
