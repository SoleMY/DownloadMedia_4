

#import "VideoDownLoadOperation.h"
#import "VideoModel.h"
@interface VideoDownLoadOperation ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>
{
    BOOL _isDownLoading;// 用于判断一个任务是否正在下载
}
@property(nonatomic, strong)VideoModel *downLoadVideoModel;
@property(nonatomic, strong)NSURLSession *currentSession;// 定义 session
@property(nonatomic, strong)NSData *partialData;// 用于可恢复的下载任务的数据
@property(nonatomic, strong)NSURLSessionDownloadTask *task;// 可恢复的下载任务
@end

@implementation VideoDownLoadOperation
-(instancetype)initWithDownLoadVideoModel:(VideoModel *)videoModel
{
    self = [super init];
    if (self) {
        self.downLoadVideoModel = videoModel;
    }
    return self;
}

//重写main方法，里面是要执行的任务具体内容
-(void)main
{
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.currentSession = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:nil];
    self.currentSession.sessionDescription = self.downLoadVideoModel.flv;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downLoadVideoModel.flv]];
    self.task = [self.currentSession downloadTaskWithRequest:request];
    [self.task resume]; // 任务开始
    _isDownLoading = YES;
    
    //子线程默认runloop关闭
    while (_isDownLoading) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    }
    self.partialData = nil;
}
// 暂停
-(void)downLoadPause
{
    NSLog(@"暂停");
    [self.task suspend];
}
// 恢复
-(void)downLoadResume
{
    NSLog(@"恢复下载");

    [self.task resume];

}

#pragma mark delegate(task)
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //下载成功后，文件是保存在一个临时目录的，需要开发者自己考到放置该文件的目录

    NSLog(@"path = %@", location.path);
    // 将临时文件剪切或者复制到 caches 文件夹
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *appendPath = [NSString stringWithFormat:@"/%@.mp4",self.downLoadVideoModel.title];
    NSString *file = [CachesPath stringByAppendingString:appendPath];

    [manager moveItemAtPath:location.path toPath:file error:nil];
    
    _isDownLoading = NO;

    // 下载完成发送通知
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:k_videoDidDownedFinishedSuccess object:self.downLoadVideoModel];
        self.downLoadVideoModel.isDownFinished = YES;
    });

    //下载完成,将task置为空
    self.task = nil;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"正在：（速度）%lldKB/s, 已经写入：%lldKB, 文件总大小%lldKB", bytesWritten / 1024, totalBytesWritten / 1024, totalBytesExpectedToWrite / 1024);

    self.downLoadVideoModel.progressValue = totalBytesWritten / (double)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.updateBlock) {
            self.updateBlock(self.downLoadVideoModel);
        }
    });
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%.0f", fileOffset /(CGFloat) expectedTotalBytes);
}


@end
