//
//  TransitionManager.h
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 2/05/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionManager : NSObject

+(void)darkenScreenWithView:(UIView *)view forViewController:(UIViewController *)viewController completion:(void(^)(BOOL finished))next;
+(void)lightenScreenWithView:(UIView *)view forViewController:(UIViewController *)viewController completion:(void(^)(BOOL finished))next;

@end
