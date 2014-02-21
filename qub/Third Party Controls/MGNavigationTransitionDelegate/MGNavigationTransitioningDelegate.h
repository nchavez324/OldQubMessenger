//
//  MGNavigationTransitioningDelegate 
//
//  Created by Philip Vasilchenko on 27.11.13.
//

#import <UIKit/UIKit.h>


@interface MGNavigationTransitioningDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> pushTransitioning;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> popTransitioning;

@end