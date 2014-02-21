//
//  TransitionAnimator.m
//  qub
//
//  Created by Nick on 1/9/14.
//  Copyright (c) 2014 RipStrike. All rights reserved.
//

#import "TransitionAnimator.h"
@implementation TransitionAnimator

+ (TransitionAnimator *)animatorWithPresenting:(BOOL)p {
    TransitionAnimator *t = [[TransitionAnimator alloc] init];
    t.presenting = p;
    return t;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (self.presenting) {
        //ANIMATE VC ENTERING FROM THE RIGHT SIDE OF THE SCREEN
        [transitionContext.containerView addSubview:fromVC.view];
        [transitionContext.containerView addSubview:toVC.view];
        toVC.view.frame = CGRectMake(2*toVC.view.frame.size.width, 0, toVC.view.frame.size.width, toVC.view.frame.size.height); //SET ORIGINAL POSITION toVC OFF TO THE RIGHT
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromVC.view.frame = CGRectMake((-1)*fromVC.view.frame.size.width, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height); //MOVE fromVC OFF TO THE LEFT
                             toVC.view.frame = CGRectMake(0, 0, toVC.view.frame.size.width, toVC.view.frame.size.height); //ANIMATE toVC IN TO OCCUPY THE SCREEN
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }else{
        [transitionContext.containerView addSubview:fromVC.view];
        [transitionContext.containerView addSubview:toVC.view];
        toVC.view.frame = CGRectMake(-1*toVC.view.frame.size.width, 0, toVC.view.frame.size.width, toVC.view.frame.size.height); //SET ORIGINAL POSITION toVC OFF TO THE LEFT
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromVC.view.frame = CGRectMake(2*fromVC.view.frame.size.width, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height); //MOVE fromVC OFF TO THE LEFT
                             toVC.view.frame = CGRectMake(0, 0, toVC.view.frame.size.width, toVC.view.frame.size.height); //ANIMATE toVC IN TO OCCUPY THE SCREEN
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];

    }
}
@end
