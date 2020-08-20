#include <pthread.h>
#include "MSBMediaManager.h"

extern void stop_media(int flag);
extern pthread_mutex_t* get_video_mutex();

using namespace YANZHEN;
MSBMedia::MSBMediaScale* createMediaScale()
{
	stop_media(0);
	MSBMedia::MSBMediaScale* media = MSBMediaManager::getInstance();
	return media;
}

void releaseMediaScale()
{
	stop_media(1);
	MSBMedia::MSBMediaScale* media = MSBMediaManager::getInstance();
	if (media) {
		pthread_mutex_t* video_mutex = get_video_mutex();
		pthread_mutex_lock(video_mutex);
		media->video_exit();	
		pthread_mutex_unlock(video_mutex);
	}
	YANZHEN::MSBMediaManager::releaseInstance();
}
