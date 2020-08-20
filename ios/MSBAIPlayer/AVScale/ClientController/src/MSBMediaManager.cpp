#include "MSBMediaManager.h"

namespace YANZHEN
{ 
	MSBMediaManager* MSBMediaManager::m_ptMediaMgr = NULL;
	MSBMediaManager* MSBMediaManager::getInstance()
	{ 
		if (!m_ptMediaMgr) m_ptMediaMgr = new MSBMediaManager();
		return m_ptMediaMgr; 
	} 

	void MSBMediaManager::releaseInstance()
	{
		if (m_ptMediaMgr) {
			delete m_ptMediaMgr;
			m_ptMediaMgr = NULL;
		}
	}

	MSBMediaManager::MSBMediaManager()
		:m_pOutBuffer(NULL),
		m_ptImgConCtx(NULL),
		m_ptDstFrame(NULL),
		m_nVideoInited(0),
		m_CBVideo(NULL)
 	{
        
    }

	MSBMediaManager::~MSBMediaManager()
	{
	}

	int MSBMediaManager::video_init(VideoCallBack videocb)
	{
		m_CBVideo = videocb;
		return 0;
	}

	int MSBMediaManager::video_init(AVCodecContext* avctx, AVFrame* frame)
	{
		if (m_nVideoInited) return 0;
		m_ptDstFrame = av_frame_alloc();
		m_pOutBuffer = (uint8_t *)av_malloc (
				av_image_get_buffer_size(AV_PIX_FMT_YUV420P,
				avctx->width, avctx->height,1));if (!m_pOutBuffer) return -1;

		av_image_fill_arrays(m_ptDstFrame->data, 
				m_ptDstFrame->linesize, m_pOutBuffer,
				AV_PIX_FMT_YUV420P, avctx->width,
				avctx->height, 1);

		m_ptImgConCtx = sws_getContext(frame->linesize[0],
				frame->height, avctx->pix_fmt,
				avctx->width, avctx->height,
				AV_PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);
		if (!m_ptImgConCtx) return -2;

		m_nVideoInited = 1;	
		return 0;	
	}

	int MSBMediaManager::video_scale(AVCodecContext* avctx, AVFrame* frame)
	{
		AVFrame* frame_tmp = NULL;
		if (avctx->pix_fmt != AV_PIX_FMT_YUV420P) {
			video_init(avctx, frame);
			sws_scale(m_ptImgConCtx,
					(const uint8_t* const*)frame->data,
					frame->linesize, 0, avctx->height,
					m_ptDstFrame->data, m_ptDstFrame->linesize);
			frame_tmp = m_ptDstFrame;

		} else 
		{
			frame_tmp = frame;
		}

		int width = avctx->width;
		int height = avctx->height;
		int linesize[4];
		linesize[0] = frame_tmp->linesize[0];
		linesize[1] = frame_tmp->linesize[1];
		linesize[2] = frame_tmp->linesize[2];
		linesize[3] = frame_tmp->linesize[3];

		uint8_t* yuvdata = (uint8_t*) malloc(width*height*3/2);

		uint8_t* p = yuvdata;
		uint8_t** data = frame_tmp->data;
		int size = 0;
		for (int i = 0; i < height; i++) {
			memcpy(p + size, data[0] + linesize[0] * i, width);
			size += width;
		}
		p = p + size;
		size = 0;
		for (int i = 0; i < height / 2; i++) {
			memcpy(p + size, data[1] + linesize[1] * i, width / 2);
			size += width / 2;
		}
		p = p + size;
		size = 0;
		for (int i = 0; i < height / 2; i++) {
			memcpy(p + size, data[2] + linesize[2] * i, width / 2);
			size += width / 2;
		}	
		if (m_CBVideo) m_CBVideo(yuvdata, width, height);

		free(yuvdata);
		return 0;
	}

	int MSBMediaManager::video_exit()
	{
		if (!m_nVideoInited) return 0;
		if (m_ptImgConCtx) {
			sws_freeContext(m_ptImgConCtx);
			m_ptImgConCtx = NULL;
		}
		if (m_ptDstFrame) {
			av_frame_free(&m_ptDstFrame);
			m_ptDstFrame = NULL;
		}
		if (m_pOutBuffer) {
			av_free(m_pOutBuffer);
			m_pOutBuffer = NULL;
		}
		m_nVideoInited = 0;
		return 0;
	}
}
