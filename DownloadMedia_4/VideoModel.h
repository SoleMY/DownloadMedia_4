

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject
@property (nonatomic,copy)NSString *title;//标题
@property (nonatomic,copy)NSString *big;//图片网址
@property (nonatomic,copy)NSString *nickname;//上传者
@property (nonatomic,copy)NSString *flv;//视频地址
@property (nonatomic,copy)NSString *totalTime;//视频时长
@property (nonatomic,copy)NSString *adwords;//简介
@property (nonatomic,copy)NSString *ID;
// 下载时候需要用的进度
@property(nonatomic, assign)CGFloat progressValue;

// 视频是否下载完成
@property(nonatomic, assign)BOOL isDownFinished;

@end
