//
//  GameViewController.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 8/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "GameViewController.h"
#import "GameObjectView.h"

@interface GameViewController () <UIAlertViewDelegate>



@property (weak, nonatomic) IBOutlet UILabel *lblTimeBeforeCrash;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeHighscore;
@property (strong, nonatomic) IBOutlet UIView *endGameView;

@property (strong, nonatomic) NSTimer * trmUpdateObjects;
@property (strong, nonatomic) NSTimer * trmCountTimeBeforeCrash;
@property (strong, nonatomic) NSTimer * trmCreateMeteors;

@property (strong, nonatomic) GameObjectView * shipObject;
@property (strong, nonatomic) NSMutableArray * gameObjectArray;

@property (nonatomic) float updateFrequency;
@property (nonatomic) float speedFactor;
@property (nonatomic) float gravityConstant;

@property (nonatomic) int timeBeforeCrash;
@property (nonatomic) int timeHighscore;

@property (nonatomic) BOOL gameOver;

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
    
    
    self.timeHighscore = 12;
    self.lblTimeHighscore.text = @"Highscore: 12";
    
    self.gameObjectArray = [[NSMutableArray alloc] init];
    self.updateFrequency = 0.01;//changes the speed and the cpu usage of the game
    self.speedFactor = 1;       //changes the speed of the game
    self.gameOver = YES;
    
    self.trmUpdateObjects = [NSTimer scheduledTimerWithTimeInterval:self.updateFrequency target:self selector:@selector(updateObjects) userInfo:nil repeats:YES];
    
    [self startGame];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        self.shipObject.center = CGPointMake(touchPoint.x, self.shipObject.center.y);
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
        if (object.canMove == YES)
        {
            float newX = object.center.x+(self.speedFactor*object.currentSpeedX);
            float newY = object.center.y-(self.speedFactor*object.currentSpeedY);
            object.center = CGPointMake(newX, newY);
            
            if (self.gameOver == NO)
            {
                //check if two views are touching
                for (int i2 = 0; i2 < self.gameObjectArray.count; i2++)
                {
                    if (i2 != i)//shouldn't compare itself
                    {
                        GameObjectView *object2 = self.gameObjectArray[i2];
                        
                        if (CGRectIntersectsRect(object.frame, object2.frame) &&
                            !(
                              (object.currentSpeedX == 0 && object.currentSpeedY == 0) &&
                              (object2.currentSpeedX == 0 && object2.currentSpeedY == 0)
                              ))
                        {
                            [self bumpObject:object withObject:object2];
                            
                        }
                    }
                }
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
-(void)applyGravity
{
    float force = self.gravityConstant*self.updateFrequency;//*self.speedFactor;
    
    for (int i = 0; i < self.gameObjectArray.count; i++)
    {
        GameObjectView *object = self.gameObjectArray[i];
        if (object.canMove == YES || object.damage <= 0)
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
        
        //half the force and change the direction and add some friction
//        [self calculateMomentumChangesFromObject1:object1 andObject2:object2 withDirection:direction];
        
        //add friction
//        [self addFrictionToObject1:object1 andObject2:object2];
        
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
/*-(void)calculateMomentumChangesFromObject1:(GameObjectView *)object1 andObject2:(GameObjectView *)object2 withDirection:(NSString *)direction
{
    //half the force and change the direction
    if (object1.canMove == NO)
    {
        //only halve the force of the non immovable object
        if ([direction isEqualToString:@"left"] || [direction isEqualToString:@"right"]) object2.currentSpeedX /= -2;
        else object2.currentSpeedY /= -2;
    }
    else if (object2.canMove == NO)
    {
        //only halve the force of the non immovable object
        if ([direction isEqualToString:@"left"] || [direction isEqualToString:@"right"]) object1.currentSpeedX /= -2;
        else object1.currentSpeedY /= -2;
    }
    else
    {
        //calculate the current momentum of each object
        float momentum1X = object1.currentSpeedX * object1.mass;
        float momentum2X = object2.currentSpeedX * object2.mass;
        float momentum1Y = object1.currentSpeedY * object1.mass;
        float momentum2Y = object2.currentSpeedY * object2.mass;
        
        //take the average
        float momentum3X = (momentum1X + momentum2X) / 2;
        float momentum3Y = (momentum1Y + momentum2Y) / 2;
        if (momentum1X + momentum2X == 0) momentum3X = -momentum1X;
        if (momentum1Y + momentum2Y == 0) momentum3Y = -momentum1Y;
        
        int gravityForce = self.gravityConstant*self.updateFrequency;
        
        //give back the force
        //
        //if both are facing the same direction
        if ((object1.currentSpeedX > gravityForce && object2.currentSpeedX > gravityForce) || (object1.currentSpeedX < -gravityForce && object2.currentSpeedX < -gravityForce))
        {
            // object 1 is moving faster than object 2
            // so object 1 takes the old speed of object 2
            // and object 2 adds on the difference in speed between itself and object 1
            if (momentum1X > momentum2X)
            {
                object1.currentSpeedX = momentum1X - (momentum1X - momentum2X);
                object2.currentSpeedX = momentum2X + (momentum1X - momentum2X);
            }
            
            if (momentum2X > momentum1X)
            {
                object1.currentSpeedX = momentum1X + (momentum2X - momentum1X);
                object2.currentSpeedX = momentum2X - (momentum2X - momentum1X);
            }
        }
        //if head on - obj1 is moving slower than obj2, change direction of obj1
        else if (object1.currentSpeedX < object2.currentSpeedX)
        {
            object1.currentSpeedX = (momentum3X / object1.mass) * -1;
            object2.currentSpeedX = (momentum3X / object2.mass);
        }
        //if head on - obj2 is moving slower than obj1, change direction of obj2
        else if (object1.currentSpeedX > object2.currentSpeedX)
        {
            object1.currentSpeedX = (momentum3X / object1.mass);
            object2.currentSpeedX = (momentum3X / object2.mass) * -1;
        }
        //if head on - both are moving at the same speed, change directino of both
        else if ([direction isEqualToString:@"right"] || [direction isEqualToString:@"left"])
        {
            //if they're equal, and moving horizontal - swap directions of both
            object1.currentSpeedX = (momentum3X / object1.mass) * -1;
            object2.currentSpeedX = (momentum3X / object2.mass) * -1;
        }
        
        
        //see details above
        if ((object1.currentSpeedY > gravityForce && object2.currentSpeedY > gravityForce) || (object1.currentSpeedY < -gravityForce && object2.currentSpeedY < -gravityForce))
        {
            // object 1 is moving faster than object 2
            // so object 1 takes the old speed of object 2
            // and object 2 adds on the difference in speed between itself and object 1
            if (momentum1Y > momentum2Y)
            {
                object1.currentSpeedY = momentum1Y - (momentum1Y - momentum2Y);
                object2.currentSpeedY = momentum2Y + (momentum1Y - momentum2Y);
            }
            if (momentum2Y > momentum1Y)
            {
                object1.currentSpeedY = momentum1Y + (momentum2Y - momentum1Y);
                object2.currentSpeedY = momentum2Y - (momentum2Y - momentum1Y);
            }
        }
        else if (object1.currentSpeedY < object2.currentSpeedY)
        {
            object1.currentSpeedY = (momentum3Y / object1.mass) * -1;
            object2.currentSpeedY = (momentum3Y / object2.mass);
        }
        else if (object1.currentSpeedY > object2.currentSpeedY)
        {
            object1.currentSpeedY = (momentum3Y / object1.mass);
            object2.currentSpeedY = (momentum3Y / object2.mass) * -1;
        }
    }
}*/
-(void)calculateDamageChangesFromObject1:(GameObjectView *)object1 andObject2:(GameObjectView *)object2
{
    //give an object damage, only movable objects can damage unmovable objects (and the other way around)

    //damage taken depends on the combined speed from both directions
        float damageConstant = 0.1;
        if (object2.canMove == NO)
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
//        if (object1.canMove) object1.backgroundColor = [UIColor colorWithRed:0 green:percentDamage1 blue:0 alpha:1];
//        else object1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:percentDamage1 alpha:1];
//        
//        if (object2.canMove) object2.backgroundColor = [UIColor colorWithRed:0 green:percentDamage2 blue:0 alpha:1];
//        else object2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:percentDamage2 alpha:1];
//    }
}
/*-(void)addFrictionToObject1:(GameObjectView *)object1 andObject2:(GameObjectView *)object2
{
    //add some friction
    float friction = 0.8;
    if (object1.currentSpeedX != 0) object1.currentSpeedX *= friction;
    if (object1.currentSpeedX != 0) object1.currentSpeedX *= friction;
    if (object2.currentSpeedX != 0) object2.currentSpeedX *= friction;
    if (object2.currentSpeedX != 0) object2.currentSpeedX *= friction;
}*/


-(void)createRectange:(CGRect)rect andForceX:(float)forceX andForceY:(float)forceY withMovingOptions:(BOOL)canMove
{
    GameObjectView *newRect = [[GameObjectView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
    
    if (canMove)
    {
        newRect.backgroundColor = [UIColor greenColor];
        newRect.mass = newRect.frame.size.width * newRect.frame.size.height;
    }
    else
    {
        newRect.mass = newRect.frame.size.width * newRect.frame.size.height;
    }
    newRect.currentSpeedX = forceX;
    newRect.currentSpeedY = forceY;
    newRect.canMove = canMove;
    
    newRect.damage = newRect.mass;
    
    [self.view addSubview:newRect];//doing this return endGameView to its original position for some reason
    if (canMove) self.gameObjectArray[self.gameObjectArray.count] = newRect;
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
    if (size == 0) size = 10;
    else size = 30;
    
    int randX = arc4random() % (320 + size*2) - size*3;
    
    [self createRectange:CGRectMake(randX, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
    [self createRectange:CGRectMake(randX+size+20, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
    [self createRectange:CGRectMake(randX+size*2+40, -size, size, size) andForceX:0 andForceY:0 withMovingOptions:YES];
}


-(void)countTimeBeforeCrash
{
    self.gravityConstant += 0.3;
    
    self.shipObject.currentSpeedY += 0.05;
    float newY = self.shipObject.center.y-(self.speedFactor*self.shipObject.currentSpeedY);
    self.shipObject.center = CGPointMake(self.shipObject.center.x, newY);
    
    self.timeBeforeCrash ++;
    self.lblTimeBeforeCrash.text = [NSString stringWithFormat:@"Duration: %i\t%0.1f/%0.2f", self.timeBeforeCrash, self.gravityConstant, self.shipObject.currentSpeedY];
}
-(void)endGame
{
    self.gameOver = YES;
    self.endGameView.hidden = NO;
    
    [self.trmCountTimeBeforeCrash invalidate];
    [self.trmCreateMeteors invalidate];
    
    if (self.timeBeforeCrash > self.timeHighscore) self.timeHighscore = self.timeBeforeCrash;
    self.lblTimeHighscore.text = [NSString stringWithFormat:@"Highscore: %i", self.timeHighscore];
}
-(void)startGame
{
    //hide the game over view - xcode bug (returns view to orignial position when another view is added to self.view)
    self.endGameView.hidden = YES;
    
    //reset game variabes
    self.timeBeforeCrash = 0;
    self.gravityConstant = 5.5;
    
    
    
    
    //create the ship, launch pad
    [self createRectange:CGRectMake(160, self.view.frame.size.height, 10, 50) andForceX:0 andForceY:0 withMovingOptions:NO];
    self.shipObject = self.gameObjectArray[0];
    [self.shipObject setImageViewFromImage:[UIImage imageNamed:@"ship"]];
    
    UIView *launchPad = [[UIView alloc] initWithFrame:CGRectMake(85, self.view.frame.size.height+self.shipObject.frame.size.height, 150, 30)];
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
            self.trmCountTimeBeforeCrash = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimeBeforeCrash) userInfo:nil repeats:YES];
            self.trmCreateMeteors = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(createRandomMeteor) userInfo:nil repeats:YES];
            
        }];
    }];
    
    
    
}
-(IBAction)newGame:(id)sender
{
    [self startGame];
}

@end
