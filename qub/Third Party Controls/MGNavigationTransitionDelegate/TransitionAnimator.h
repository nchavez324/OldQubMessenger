//
//  TransitionAnimator.h
//  qub
//
//  Created by Nick on 1/9/14.
//  Copyright (c) 2014 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

+ (TransitionAnimator *)animatorWithPresenting:(BOOL)p;

@end