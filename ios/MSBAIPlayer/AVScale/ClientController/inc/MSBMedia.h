#ifndef __MSBMEDIA_H__
#define __MSBMEDIA_H__

namespace MSBMedia
{
	typedef int (*VideoCallBack) (uint8_t* data, int width, int height);

	class MSBMediaScale {
		public:
			virtual ~MSBMediaScale() {};
        
			virtual int video_init(VideoCallBack videocb)=0; 
			virtual int video_exit()=0;
	};
}

MSBMedia::MSBMediaScale* createMediaScale();
void releaseMediaScale();
#endif
