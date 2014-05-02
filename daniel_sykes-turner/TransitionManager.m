//
//  TransitionManager.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 2/05/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "TransitionManager.h"

@implementation TransitionManager

+(void)darkenScreenWithView:(UIView *)view forViewController:(UIViewController *)viewController completion:(void(^)(BOOL finished))next;

{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0;
        [viewController.view addSubview:view];
    }
    
    
    if (view.alpha >= 1)
    {
        next(true);
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            view.alpha += 0.1;
            [self darkenScreenWithView:view forViewController:viewController completion:^(BOOL finished){
                next(true);
            }];
        });
    }
}

+(void)lightenScreenWithView:(UIView *)view forViewController:(UIViewController *)viewController completion:(void(^)(BOOL finished))next;

{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 1;
        [viewController.view addSubview:view];
    }
    
    if (view.alpha <= 0)
    {
        next(true);
    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            view.alpha -= 0.1;
            [self lightenScreenWithView:view forViewController:viewController completion:^(BOOL finished) {
                next(true);
            }];
        });
    }
}

@end
