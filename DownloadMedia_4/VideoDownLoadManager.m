

#import "VideoDownLoadManager.h"
#import "VideoModel.h"
#import "VideoDownLoadOperation.h"

//@interface VideoDownLoadOperation ()
//
//@end

@implementation VideoDownLoadManager
+(instancetype)sharedInstance
{
    static VideoDownLoadManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[VideoDownLoadManager alloc] init];
            manager.httpOperationDict = [NSMutableDictionary dictionary];
            manager.downVideoArray = [NSMutableArray array];
        }
    });
    return manager;
}

#pragma mark 开始下载
-(void)startAVideoWithVideoModel:(VideoModel *)downLoadVideo
{
    NSLog(@"........%@", CachesPath);
    if (!self.downLoadQueue) {
        self.downLoadQueue = [[NSOperationQueue alloc] init];
        self.downLoadQueue.maxConcurrentOperationCount = 3;
    }

    VideoDownLoadOperation *ope = [[VideoDownLoadOperation alloc] initWithDownLoadVideoModel:downLoadVideo];
    
    ope.updateBlock = ^(VideoModel *model){
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoDidUpdatedProgressWithVideoModel:)]) {
            [self.delegate videoDidUpdatedProgressWithVideoModel:model];
        }
    };

    [self.httpOperationDict setObject:ope forKey:downLoadVideo.flv];

    [self.downLoadQueue addOperation:ope];

    [self.downVideoArray addObject:downLoadVideo];
    [[NSNotificationCenter defaultCenter] postNotificationName:k_newVideoDidStartDown object:nil];
}

#pragma mark 暂停下载
-(void)downloadPausewithModel:(VideoModel *)pauseModel
{
    VideoDownLoadOperation *ope = [self.httpOperationDict objectForKey:pauseModel.flv];
    if (!ope.isFinished) {
        [ope downLoadPause];
    }
}

#pragma mark 断点继续下载
-(void)downloadResumeWithModel:(VideoModel *)resumeModel
{
    VideoDownLoadOperation *ope = [self.httpOperationDict objectForKey:resumeModel.flv];
    if (!ope.isFinished) {
        [ope downLoadResume];
    }
}

@end
