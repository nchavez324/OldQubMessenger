//
//  MGSlideAnimatedTransitioning
//
//  Created by Philip Vasilchenko on 27.11.13.
//  Copyright (c) 2013 Megogo.net. All rights reserved.
//

#import "MGSlideAnimatedTransitioning.h"


@implementation MGSlideAnimatedTransitioning

static const NSTimeInterval kMGSlideAnimatedTransitioningDuration = 0.35f;

#pragma mark - Initialization

- (instancetype)initWithReverse:(BOOL)reverse {
    self = [super init];
    if ( self ) {
        self.reverse = reverse;
    }
    return self;
}


+ (instancetype)transitioningWithReverse:(BOOL)reverse {
    return [[self alloc] initWithReverse:reverse];
}


#pragma mark - Transitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSString *fromKey = UITransitionContextFromViewControllerKey;
    NSString *toKey = UITransitionContextToViewControllerKey;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:fromKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:toKey];
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView = fromViewController.view;
    UIView *toView = toViewController.view;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGFloat viewWidth = CGRectGetWidth(containerView.frame);
    __block CGRect fromViewFrame = fromView.frame;
    __block CGRect toViewFrame = toView.frame;

    toViewFrame.origin.x = self.reverse ? -viewWidth : viewWidth;
    toView.frame = toViewFrame;
    [containerView addSubview:toView];

    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toViewFrame.origin.x = CGRectGetMinX(containerView.frame);
                         fromViewFrame.origin.x = self.reverse ? viewWidth : -viewWidth;
                         toView.frame = toViewFrame;
                         fromView.frame = fromViewFrame;
                     }
                     completion:^(BOOL finished) {
                         if ( self.reverse ) { [fromView removeFromSuperview]; }
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kMGSlideAnimatedTransitioningDuration;
}

@end