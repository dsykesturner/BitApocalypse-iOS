//
//  StoryIntoViewController.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 11/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "AppDelegate.h"
#import "TransitionManager.h"

#import "StoryIntoViewController.h"
#import "PersonView.h"


@interface StoryIntoViewController ()

@property (strong, nonatomic) PersonView * personView;
@property (strong, nonatomic) UIImageView * rocketView;
@property (strong, nonatomic) UIImageView * rocketFlame;

@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) NSTimer *trmCreateMeteors;

@end

@implementation StoryIntoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    BOOL firstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRun"];
    if (firstRun)
    {
        [TransitionManager lightenScreenWithView:nil forViewController:self completion:^(BOOL finished) {
            
            [self runStory];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"firstRun"];
        }];
        
    }
    else
    {
        [app_delegate moveToHomeScreen];
    }
    
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)runStory
{
    //create our background (holds clouds, meteors, etc)
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width+100, self.view.frame.size.height)];
    [self.view addSubview:self.backgroundView];
    
    //create the rocket
    self.rocketView = [[UIImageView alloc] initWithFrame:CGRectMake(320, 168, 80, 400)];
    [self.rocketView setImage:[UIImage imageNamed:@"ship"]];
    [self.view addSubview:self.rocketView];
    
    //add the rocket flame, but don't show it yet
    self.rocketFlame = [[UIImageView alloc] init];
    self.rocketFlame.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"flameMoveUp1"], [UIImage imageNamed:@"flameMoveUp2"], nil];
    self.rocketFlame.animationDuration = 0.03 * self.rocketFlame.animationImages.count;//(0.03 per image)
    self.rocketFlame.animationRepeatCount = -1;
    [self.view addSubview:self.rocketFlame];
    
    //create the person
    //for a square face, use 40x75 ratio
    self.personView = [[PersonView alloc] initWithFrame:CGRectMake(120, 493, 40, 75)];
    [self.view addSubview:self.personView];
    
    
    
    self.trmCreateMeteors = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(createMeteor) userInfo:nil repeats:YES];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.personView selector:@selector(moveEyesUp)    userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self.personView selector:@selector(dropJaw)       userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:3.5 target:self.personView selector:@selector(moveEyesRight) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:2 delay:4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.personView.center = CGPointMake(self.personView.center.x-100, self.personView.center.y);
        self.rocketView.center = CGPointMake(self.rocketView.center.x-100, self.rocketView.center.y);
        self.backgroundView.center = CGPointMake(self.backgroundView.center.x-100, self.backgroundView.center.y);
        
    } completion:^(BOOL finished) {
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.personView selector:@selector(moveEyesUp)       userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.4 target:self.personView selector:@selector(moveEyesRight)    userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.6 target:self.personView selector:@selector(moveEyesUp)       userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.8 target:self.personView selector:@selector(moveEyesRight)    userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self.personView selector:@selector(moveEyesUp)       userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:2.4 target:self.personView selector:@selector(moveEyesRight)    userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self.personView selector:@selector(throwArmsUp)      userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [self.personView runToRocket:self.rocketView];
            
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self.personView selector:@selector(hidePerson) userInfo:nil repeats:NO];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                float flameWidth = (self.rocketView.frame.size.width/2)*3;
                float flameHeight = self.rocketView.frame.size.height/5;
                self.rocketFlame.frame = CGRectMake(self.rocketView.frame.origin.x - flameWidth/6, self.rocketView.frame.origin.y + self.rocketView.frame.size.height - flameHeight/2, flameWidth, flameHeight);
                [self.rocketFlame startAnimating];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [TransitionManager darkenScreenWithView:nil forViewController:self completion:^(BOOL finished) {
                        
                        [self.trmCreateMeteors invalidate];
                        [app_delegate moveToGameScreen];
                    }];
                });
            });
        }];
    }];
}

-(void)createMeteor
{
    int rand = arc4random() % 440 - 10;
    int size = 20;
    
    UIImageView *meteor = [[UIImageView alloc] initWithFrame:CGRectMake(rand, -20, size, size)];
    [meteor setImage:[UIImage imageNamed:[NSString stringWithFormat:@"meteor%ia", (arc4random()) % 5 + 1]]];
    [self.backgroundView addSubview:meteor];
    
    
    [UIView animateWithDuration:30 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        meteor.center = CGPointMake(meteor.center.x, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        //also completed when screen is no longer in use
        [meteor removeFromSuperview];
    }];
}


//-(void)createMeteorWithXCoord:(int)xcoord andYCoord:(int)ycoord
//{
//    int size = 20;
//    
//    UIImageView *meteor = [[UIImageView alloc] initWithFrame:CGRectMake(xcoord, ycoord, size, size)];
//    [meteor setImage:[UIImage imageNamed:[NSString stringWithFormat:@"meteor%ia", (arc4random()) % 5 + 1]]];
//    [self.backgroundView addSubview:meteor];
//    
//    
//    [UIView animateWithDuration:30 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        
//        meteor.center = CGPointMake(meteor.center.x, self.view.frame.size.height);
//        
//    } completion:^(BOOL finished) {
//        
//        //also completed when screen is no longer in use
//        [meteor removeFromSuperview];
//    }];
//    
//}



@end
