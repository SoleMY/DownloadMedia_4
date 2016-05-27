

#import "VideoModel.h"

@implementation VideoModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.ID = [NSString stringWithFormat:@"%@",value];
    }
}
@end
