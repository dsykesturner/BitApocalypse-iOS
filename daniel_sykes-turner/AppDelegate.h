//
//  AppDelegate.h
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 8/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define app_delegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL playingFirstSong;

-(void)chooseRandomSong;

-(void)moveToGameScreen;
-(void)moveToHomeScreen;
-(void)moveToStoryScreen;

@end
