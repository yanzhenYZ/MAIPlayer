#include <pthread.h>
#include "MSBLocal.h"
#include "MSBMediaManager.h"

static pthread_mutex_t videoMutex;
static int releaseFlag = 1;

void stop_media(int flag)
{
	releaseFlag = flag;
}

pthread_mutex_t* get_video_mutex()
{
	return &videoMutex;
}

int video_scale(AVCodecContext* avctx, AVFrame* frame)
{
	if (releaseFlag) return 0;
	pthread_mutex_lock(&videoMutex);
	if (releaseFlag){
		pthread_mutex_unlock(&videoMutex);
		return 0;
	}
	YANZHEN::MSBMediaManager* manager = YANZHEN::MSBMediaManager::getInstance();
	if (!manager) {
		pthread_mutex_unlock(&videoMutex);
		return -1;
	}
	int ret = manager->video_scale(avctx, frame);
	pthread_mutex_unlock(&videoMutex);

	return ret;
}
