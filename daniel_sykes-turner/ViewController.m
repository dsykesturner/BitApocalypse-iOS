//
//  ViewController.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 8/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TransitionManager.h"

#import <GameKit/GameKit.h>

@interface ViewController () <GKGameCenterControllerDelegate>

@property (nonatomic) BOOL gameCenterEnabled;
@property (nonatomic, strong) NSString * leaderboardIdentifier;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //auto login to game center
    [self authenticatePlayer];
    
    [TransitionManager lightenScreenWithView:nil forViewController:self completion:^(BOOL finished) {}];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)startGame:(id)sender
{
    [TransitionManager darkenScreenWithView:nil forViewController:self completion:^(BOOL finished) {
        [app_delegate moveToGameScreen];
    }];
}



//game center delegate
-(void)authenticatePlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated)
            {
                self.gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier. do i need this though?
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil)
                        NSLog(@"%@", [error localizedDescription]);
                    else
                        self.leaderboardIdentifier = leaderboardIdentifier;
                }];
            }
            else
            {
                self.gameCenterEnabled = NO;
            }
        }
    };
}

-(IBAction)openGameCentre:(id)sender
{
    GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.gameCenterDelegate = self;
    [self presentViewController:gameCenterController animated:YES completion:nil];
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*) gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
