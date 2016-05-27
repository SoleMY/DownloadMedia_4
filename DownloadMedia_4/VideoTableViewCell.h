
#import <UIKit/UIKit.h>
@class VideoModel;
@interface VideoTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;

@property (strong, nonatomic) IBOutlet UILabel *titleLable;

@property (strong, nonatomic) IBOutlet UILabel *authorLable;

@property (strong, nonatomic) IBOutlet UILabel *messageLable;

-(void)setCellDataWithModel:(VideoModel *)model;
@end
