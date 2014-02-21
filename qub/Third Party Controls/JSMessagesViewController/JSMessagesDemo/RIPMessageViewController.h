#import "JSMessagesViewController.h"

@interface RIPMessageViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (assign, nonatomic) NSInteger contactID;

- (void)loadAvatarImagesForUserID:(NSInteger)userID;
- (void)reloadMessageRows:(NSInteger)userID;

@end
