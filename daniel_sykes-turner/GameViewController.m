//
//  GameViewController.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 8/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "GameViewController.h"
#import "GameObjectView.h"
#import "AppDelegate.h"
#import "TransitionManager.h"

#import <CoreMotion/CoreMotion.h>
#import <GameKit/GameKit.h>

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblMeteorScore;
@property (weak, nonatomic) IBOutlet UILabel *lblMeteorHighscore;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeScore;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeHighscore;
@property (weak, nonatomic) IBOutlet UIView *endGameView;
@property (strong, nonatomic) UIImageView *imgShipFlame;

@property (strong, nonatomic) NSTimer * trmUpdateObjects;
@property (strong, nonatomic) NSTimer * trmCountTimeScore;
@property (strong, nonatomic) NSTimer * trmCreateMeteors;
@property (strong, nonatomic) NSTimer * trmAnimateShipFlame;

@property (strong, nonatomic) GameObjectView * shipObject;
@property (strong, nonatomic) NSMutableArray * gameObjectArray;

@property (strong, nonatomic) NSString * shipsDirectionOfMovement;

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (nonatomic) float updateFrequency;
@property (nonatomic) float speedFactor;
@property (nonatomic) float gravityConstant;

@property (nonatomic) int timeScore;
@property (nonatomic) int timeHighscore;
@property (nonatomic) int meteorScore;
@property (nonatomic) int meteorHighscore;

@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL shipAnimationStep;

@end

@implementation GameViewController

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
    
    
    //start the accelerometer
    //self.motionManager = [[CMMotionManager alloc] init]; //turned off for now
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        
        //lest the ship object update properly
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.gameOver == NO)
            {
                //detect direction of movement
                if (data.acceleration.x >= 0.04) self.shipsDirectionOfMovement = @"right";
                else if (data.acceleration.x <= -0.04) self.shipsDirectionOfMovement = @"left";
                else self.shipsDirectionOfMovement = @"up";
                
                self.shipObject.center = CGPointMake(self.shipObject.center.x+data.acceleration.x*15, self.shipObject.center.y);
                
                if (self.shipObject.center.x < 0)
                    self.shipObject.center = CGPointMake(0, self.shipObject.center.y);
                else if (self.shipObject.center.x > self.view.frame.size.width)
                    self.shipObject.center = CGPointMake(320, self.shipObject.center.y);
            }
        });
    }];
    
    self.gameObjectArray = [[NSMutableArray alloc] init];
    self.updateFrequency = 0.01;//changes the speed and the cpu usage of the game
    self.speedFactor = 1;       //changes the speed of the game
    self.gameOver = YES;
    self.endGameView.hidden = YES;
    
    self.trmUpdateObjects = [NSTimer scheduledTimerWithTimeInterval:self.updateFrequency target:self selector:@selector(updateObjects) userInfo:nil repeats:YES];
    
    self.meteorHighscore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"meteorHighscore"];
    self.timeHighscore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"timeHighscore"];
    self.lblTimeHighscore.text = [NSString stringWithFormat:@"DURATION: %i", self.timeHighscore];
    self.lblMeteorHighscore.text = [NSString stringWithFormat:@"HIGHSCORE: %i", self.meteorHighscore];
    
    [TransitionManager lightenScreenWithView:nil forViewController:self completion:^(BOOL finished) {
        [self startGame];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)reportGameCentreScore
{
    GKScore *reportScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"meteorHighscores"];
    reportScore.value = self.meteorHighscore;
    
    [GKScore reportScores:[NSArray arrayWithObjects:reportScore, nil] withCompletionHandler:nil];
}
-(void)endGame
{
    self.gameOver = YES;
    self.endGameView.hidden = NO;
    
    //turn off ships rockets
    self.imgShipFlame.image = nil;
    
    //stop timers
    [self.trmCountTimeScore invalidate];
    [self.trmCreateMeteors invalidate];
    [self.trmAnimateShipFlame invalidate];
    
    //update highscore
    if (self.meteorScore > self.meteorHighscore)
    {
        self.meteorHighscore = self.meteorScore;
        self.timeHighscore = self.timeScore;
        
        self.lblTimeHighscore.text = [NSString stringWithFormat:@"DURATION: %i", self.timeHighscore];
        self.lblMeteorHighscore.text = [NSString stringWithFormat:@"HIGHSCORE: %i", self.meteorHighscore];
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.meteorHighscore forKey:@"meteorHighscore"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.timeHighscore forKey:@"timeHighscore"];
        
        //send new high scores only
        [self reportGameCentreScore];
    }
}
-(void)startGame
{
    //hide the gameover view
    self.endGameView.hidden = YES;
    
    //reset game variabes
    self.gravityConstant = 5.5;
    self.timeScore = 0;
    self.meteorScore = 0;
    self.lblTimeScore.text = [NSString stringWithFormat:@"%0.1f/%0.2fDURATION: %i", self.gravityConstant, self.shipObject.currentSpeedY, self.timeScore];
    self.lblMeteorScore.text = [NSString stringWithFormat:@"SCORE: %i", self.meteorScore];
    
    
    //create the ship, launch pad
    [self createRectange:CGRectMake(155,
                                    self.view.frame.size.height,
                                    10,
                                    50) andForceX:0 andForceY:0 withMovingOptions:NO];
    self.shipObject = self.gameObjectArray[0];
    [self.shipObject setImageViewFromImage:[UIImage imageNamed:@"ship"]];
    
    if (self.imgShipFlame == nil) self.imgShipFlame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    self.imgShipFlame.center = CGPointMake(self.shipObject.frame.size.width/2, self.shipObject.frame.size.height);
    [self.shipObject addSubview:self.imgShipFlame];
    
    UIView *launchPad = [[UIView alloc] initWithFrame:CGRectMake(85,
                                                                 self.view.frame.size.height+self.shipObject.frame.size.height,
                                                                 150,
                                                                 30)];
    launchPad.backgroundColor = [UIColor grayColor];
    [self.view addSubview:launchPad];
    
    
    
    
    //animations - load up ship and launch pad - fire ship up, launch pad falls off screen - meteors start, launch pad released
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.shipObject.frame = CGRectMake(self.shipObject.frame.origin.x,
                                           self.shipObject.frame.origin.y-launchPad.frame.size.height-self.shipObject.frame.size.height,
                                           self.shipObject.frame.size.width,
                                           self.shipObject.frame.size.height);
        
        launchPad.frame = CGRectMake(launchPad.frame.origin.x,
                                     launchPad.frame.origin.y-launchPad.frame.size.height-self.shipObject.frame.size.height,
                                     launchPad.frame.size.width,
                                     launchPad.frame.size.height);
        
        self.trmAnimateShipFlame = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(animateShipFlame) userInfo:nil repeats:YES];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.gameOver = NO;
            
            self.shipObject.frame = CGRectMake(self.shipObject.frame.origin.x,
                                               self.shipObject.frame.origin.y-200,
                                               self.shipObject.frame.size.width,
                                               self.shipObject.frame.size.height);
            
            launchPad.frame = CGRectMake(launchPad.frame.origin.x,
                                         launchPad.frame.origin.y+launchPad.frame.size.height,
                                         launchPad.frame.size.width,
                                         launchPad.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            //remove launch pad
            [launchPad removeFromSuperview];
            
            //start timers
            self.trmCountTimeScore = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimeScore) userInfo:nil repeats:YES];
            self.trmCreateMeteors = [NSTimer scheduledTimerWithTimeInterval:0.40 target:self selector:@selector(createRandomMeteor) userInfo:nil repeats:YES];
        }];
    }];
    
}
-(IBAction)newGame:(id)sender
{
    [self startGame];
}
-(IBAction)exitGame:(id)sender
{
    [TransitionManager darkenScreenWithView:nil forViewController:self completion:^(BOOL finished) {
        [app_delegate moveToHomeScreen];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameOver == NO)
    {
        UITouch * myTouch = [touches anyObject];
        CGPoint touchPoint = [myTouch locationInView:self.view];
        
        self.shipObject.center = CGPointMake(touchPoint.x, self.shipObject.center.y);
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameOver == NO)
    {
        UITouch * myTouch = [touches anyObject];
        CGPoint touchPoint = [myTouch locationInView:self.view];
        
        //detect direction of movement
        float difference = touchPoint.x - self.shipObject.center.x;
        if (difference >= 1.5) self.shipsDirectionOfMovement = @"right";
        else if (difference <= -1.5) self.shipsDirectionOfMovement = @"left";
        else self.shipsDirectionOfMovement = @"up";
        
        self.shipObject.center = CGPointMake(touchPoint.x, self.shipObject.center.y);
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.shipsDirectionOfMovement = @"up";
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.shipsDirectionOfMovement = @"up";
}
-(void)animateShipFlame
{
    if (self.shipsDirectionOfMovement.length == 0) self.shipsDirectionOfMovement = @"up";
    
    
    if (self.shipAnimationStep == 0)
    {
        self.shipAnimationStep = 1;
        
        if ([self.shipsDirectionOfMovement isEqualToString:@"up"])
            [self.imgShipFlame setImage:[UIImage imageNamed:@"flameMoveUp1"]];
        else if ([self.shipsDirectionOfMovement isEqualToString:@"left"])
            [self.imgShipFlame setImage:[UIImage imageNamed:@"flameMoveLeft"]];
        else if ([self.shipsDirectionOfMovement isEqualToString:@"right"])
            [self.imgShipFlame setImage:[UIImage imageNamed:@"flameMoveRight"]];
    }
    else
    {
        self.shipAnimationStep = 0;
        
        [self.imgShipFlame setImage:[UIImage imageNamed:@"flameMoveUp2"]];
    }
}


-(void)updateObjects
{
    [self applyGravity];
    
    for (int i = 0; i < self.gameObjectArray.count; i++)
    {
        GameObjectView *object = self.gameObjectArray[i];
        
        //only move the object if it's movable,
        //only check for colisions if its not
        if (object.affectedByGravity == YES)
        {
            float newX = object.center.x+(self.speedFactor*object.currentSpeedX);
            float newY = object.center.y-(self.speedFactor*object.currentSpeedY);
            object.center = CGPointMake(newX, newY);
            
            if (self.gameOver == NO)
            {
                //check if two views are touching
                if (CGRectIntersectsRect(object.frame, self.shipObject.frame) &&
                    !(
                      (object.currentSpeedX == 0 && object.currentSpeedY == 0) &&
                      (self.shipObject.currentSpeedX == 0 && self.shipObject.currentSpeedY == 0)
                      ))
                {
                    [self bumpObject:object withObject:self.shipObject];
                }
            }
            
            
            //delete object if its out of bounds
            if (!CGRectIntersectsRect(object.frame, self.view.frame))
            {
                //[object removeFromSuperview];
                [self.gameObjectArray removeObjectAtIndex:i];
                object = nil;
            }
        }
    }
}
-(void)applyGravity
{
    float force = self.gravityConstant*self.updateFrequency;//*self.speedFactor;
    
    for (int i = 0; i < self.gameObjectArray.count; i++)
    {
        GameObjectView *object = self.gameObjectArray[i];
        if (object.affectedByGravity == YES || object.damage <= 0)
        {
            
            object.currentSpeedY -= force;
            
            if (object == self.shipObject)
            {
                object.alpha = 1;
                
                float newY = object.center.y-(self.speedFactor*object.currentSpeedY);
                object.center = CGPointMake(object.center.x, newY);
            }
        }
    }
}


-(void)bumpObject:(GameObjectView *)object1 withObject:(GameObjectView *)object2
{
    //only make colisions with the ship
    if (object2 == self.shipObject)
    {
        //make sure the two objects are no longer overlapping, and determin the direction of impact
        [self calculateDirectionFromObject1:object1 andObject2:object2];
        
        //add damage
        [self calculateDamageChangesFromObject1:object1 andObject2:object2];
    }
}
-(void)calculateDirectionFromObject1:(GameObjectView *)object1 andObject2:(GameObjectView *)object2
{
    NSString *direction;
    
    float obj1Width = object1.frame.size.width;
    float obj2Width = object2.frame.size.width;
    
    float rightDifference = (object1.center.x+obj1Width/2) - (object2.center.x-obj2Width/2);
    float leftDifference = (object2.center.x+obj2Width/2) - (object1.center.x-obj1Width/2);
    
    //no up or down colisions (gives the impression of objects just sliding off/around after the colission)
    if (rightDifference < leftDifference)
    {
        direction = @"right";
        object1.center = CGPointMake(object2.center.x-(obj1Width/2+obj2Width/2), object1.center.y);
    }
    if (leftDifference < rightDifference || leftDifference == rightDifference)
    {
        direction = @"left";
        object1.center = CGPointMake(object2.center.x+(obj1Width/2+obj2Width/2), object1.center.y);
    }
}
-(void)calculateDamageChangesFromObject1:(GameObjectView *)object1 andObject2:(GameObjectView *)object2
{
    //give an object damage, only movable objects can damage unmovable objects (and the other way around)

    //damage taken depends on the combined speed from both directions
        float damageConstant = 0.1;
        if (object2.affectedByGravity == NO)
        {
            int damage = object1.mass * (object1.currentSpeedX + object1.currentSpeedY) * damageConstant;
            if (object1.currentSpeedX + object1.currentSpeedY > 0.1)        object2.damage -= damage;
            else if (object1.currentSpeedX + object1.currentSpeedY < -0.1)  object2.damage += damage;

            damage = object2.mass * (object2.currentSpeedX + object2.currentSpeedY) * damageConstant;
            if (object2.currentSpeedX + object2.currentSpeedY > 0.1)        object1.damage -= damage;
            else if (object2.currentSpeedX + object2.currentSpeedY < -0.1)  object1.damage += damage;
        }
    
        
        
        //remove the destroyed object - unless its the ship, because it is replaced when the next game starts
        if (object1.damage <= 0 && object1 != self.shipObject)
        {
            [object1 removeFromSuperview];
            [self.gameObjectArray removeObject:object1];
            object1 = nil;
        }
        if (object2.damage <= 0 && object2 != self.shipObject)
        {
            [object2 removeFromSuperview];
            [self.gameObjectArray removeObject:object2];
            object2 = nil;
        }
        
        
        float percentDamage1 = object1.damage/object1.mass;
        float percentDamage2 = object2.damage/object2.mass;

        object1.alpha = percentDamage1;
        object2.alpha = percentDamage2;
    
    if (self.shipObject.damage <= 0)
    {
        [self endGame];
    }
}


-(void)createRectange:(CGRect)rect andForceX:(float)forceX andForceY:(float)forceY withMovingOptions:(BOOL)affectedByGravity
{
    GameObjectView *newRect = [[GameObjectView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    
    if (affectedByGravity)//if a meteor
    {
        NSString *type;
        int randImage = arc4random() % 5 + 1;
        
        if ((arc4random() % 3) == 0) type = @"b";
        else type = @"a";
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"meteor%i%@", randImage, type]];
        [newRect setImageViewFromImage:image];
        
        newRect.backgroundColor = [UIColor clearColor];
        newRect.mass = newRect.frame.size.width * newRect.frame.size.height;
    }
    else//if a landing pad
    {
        newRect.mass = newRect.frame.size.width * newRect.frame.size.height;
    }
    newRect.currentSpeedX = forceX;
    newRect.currentSpeedY = forceY;
    newRect.affectedByGravity = affectedByGravity;
    
    newRect.damage = newRect.mass;
    
    [self.view addSubview:newRect];//doing this return endGameView to its original position for some reason
    if (affectedByGravity) self.gameObjectArray[self.gameObjectArray.count] = newRect;
    else
    {
        if ([self.gameObjectArray containsObject:self.shipObject])
        {
            [self.shipObject removeFromSuperview];
        }
            
        [self.gameObjectArray setObject:newRect atIndexedSubscript:0];
    }
}
-(void)createRandomMeteor
{
    int size = arc4random() % 3;
    if (size == 0)
    {
        size = 10;
        self.meteorScore += 1;
    }
    else
    {
        size = 30;
        self.meteorScore += 3;
    }
    
    int randX = arc4random() % (320 + size*2) - size*3;
    
    [self createRectange:CGRectMake(randX, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
    [self createRectange:CGRectMake(randX+size+20, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
    [self createRectange:CGRectMake(randX+size*2+40, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
    
    self.lblMeteorScore.text = [NSString stringWithFormat:@"SCORE: %i", self.meteorScore];
}
-(void)countTimeScore
{
    self.gravityConstant += 0.4;
    
    self.shipObject.currentSpeedY += 0.05;
    float newY = self.shipObject.center.y-(self.speedFactor*self.shipObject.currentSpeedY);
    self.shipObject.center = CGPointMake(self.shipObject.center.x, newY);
    
    self.timeScore ++;
    self.lblTimeScore.text = [NSString stringWithFormat:@"%0.1f/%0.2fDURATION: %i", self.gravityConstant, self.shipObject.currentSpeedY, self.timeScore];
}

@end
