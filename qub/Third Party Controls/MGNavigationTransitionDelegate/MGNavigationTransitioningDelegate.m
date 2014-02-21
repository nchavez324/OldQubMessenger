//
//  MGNavigationTransitioningDelegate 
//
//  Created by Philip Vasilchenko on 27.11.13.
//

#import "MGNavigationTransitioningDelegate.h"
#import "MGSlideAnimatedTransitioning.h"
#import "TransitionAnimator.h"

@implementation MGNavigationTransitioningDelegate

- (id)init {
    self = [super init];
    if ( self ) {
        self.pushTransitioning = [MGSlideAnimatedTransitioning transitioningWithReverse:NO];
        self.popTransitioning = [MGSlideAnimatedTransitioning transitioningWithReverse:YES];
    }
    return self;
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController {

    return operation == UINavigationControllerOperationPush ? self.pushTransitioning : self.popTransitioning;
}

@end