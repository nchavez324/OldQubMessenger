//
//  MGSlideAnimatedTransitioning 
//
//  Created by Philip Vasilchenko on 27.11.13.
//

#import <UIKit/UIKit.h>


@interface MGSlideAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL reverse;

- (instancetype)initWithReverse:(BOOL)reverse;
+ (instancetype)transitioningWithReverse:(BOOL)reverse;

@end