

#import <Foundation/Foundation.h>
@class VideoModel;
typedef void(^VIDEODidUpateBlcok)(VideoModel *);

@interface VideoDownLoadOperation : NSOperation
-(instancetype)initWithDownLoadVideoModel:(VideoModel *)videoModel;

@property(nonatomic, copy)VIDEODidUpateBlcok updateBlock;
// 暂停
-(void)downLoadPause;
// 恢复
-(void)downLoadResume;
@end
