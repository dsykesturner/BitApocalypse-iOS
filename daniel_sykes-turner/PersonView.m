//
//  PersonView.m
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 11/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import "PersonView.h"

@interface PersonView ()

@property (strong, nonatomic) UIView * personBodyView;
@property (strong, nonatomic) UIView * personLeftArmView;
@property (strong, nonatomic) UIView * personRightArmView;
@property (strong, nonatomic) UIView * personLeftLegView;
@property (strong, nonatomic) UIView * personRightLegView;

@property (strong, nonatomic) UIView * personHeadView;
@property (strong, nonatomic) UIView * headMouthView;
@property (strong, nonatomic) UIView * headRightEyeView;
@property (strong, nonatomic) UIView * headLeftEyeView;

@property (nonatomic) float viewHeight;
@property (nonatomic) float viewWidth;
@property (nonatomic) float headHeight;
@property (nonatomic) float headWidth;

@end

@implementation PersonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // draw body parts here
        self.viewHeight = self.frame.size.height;
        self.viewWidth = self.frame.size.width;
        
        self.personHeadView = [[UIView alloc] initWithFrame:CGRectMake(self.viewWidth/4, 0, self.viewWidth/2, (self.viewHeight/15)*4)];
        self.personHeadView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.personHeadView];
        
        self.personBodyView = [[UIView alloc] initWithFrame:CGRectMake((self.viewWidth/16)*3, (self.viewHeight/15)*4, (self.viewWidth/8)*5, (self.viewHeight/15)*8)];
        self.personBodyView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:self.personBodyView];
        
        self.personLeftArmView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.viewHeight/15)*4, (self.viewWidth/16)*3, self.viewHeight/3)];
        self.personLeftArmView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.personLeftArmView];
        
        self.personRightArmView = [[UIView alloc] initWithFrame:CGRectMake(self.viewWidth-(self.viewWidth/16)*3, (self.viewHeight/15)*4, (self.viewWidth/16)*3, self.viewHeight/3)];
        self.personRightArmView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.personRightArmView];
        
        self.personLeftLegView = [[UIView alloc] initWithFrame:CGRectMake((self.viewWidth/16)*3, (self.viewHeight/5)*4, self.viewWidth/4, self.viewHeight/5)];
        self.personLeftLegView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.personLeftLegView];
        
        self.personRightLegView = [[UIView alloc] initWithFrame:CGRectMake((self.viewWidth/16)*9, (self.viewHeight/5)*4, self.viewWidth/4, self.viewHeight/5)];
        self.personRightLegView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.personRightLegView];
        
        
        self.headHeight = self.personHeadView.frame.size.height;
        self.headWidth = self.personHeadView.frame.size.width;
        
        self.headLeftEyeView = [[UIView alloc] initWithFrame:CGRectMake(self.headWidth/8, self.headHeight/8, self.headWidth/4, self.headHeight/4)];
        self.headLeftEyeView.backgroundColor = [UIColor whiteColor];
        [self.personHeadView addSubview:self.headLeftEyeView];
        
        self.headRightEyeView = [[UIView alloc] initWithFrame:CGRectMake((self.headWidth/8)*5, self.headHeight/8, self.headWidth/4, self.headHeight/4)];
        self.headRightEyeView.backgroundColor = [UIColor whiteColor];
        [self.personHeadView addSubview:self.headRightEyeView];
        
        self.headMouthView = [[UIView alloc] initWithFrame:CGRectMake(self.headWidth/4, self.headHeight/2, self.headWidth/2, self.headHeight/4)];//non-dropped state
        self.headMouthView.backgroundColor = [UIColor whiteColor];
        [self.personHeadView addSubview:self.headMouthView];
    }
    
    return self;
}


-(void)runToRocket:(UIImageView *)rocket
{
    float xCoord = rocket.center.x - self.viewWidth/2;
    self.frame = CGRectMake(xCoord, self.frame.origin.y, 0, 0);
}
-(void)throwArmsUp
{
    self.personLeftArmView.frame = CGRectMake(0, 0, (self.viewWidth/16)*3, self.viewHeight/3);
    self.personRightArmView.frame = CGRectMake(self.viewWidth-(self.viewWidth/16)*3, 0, (self.viewWidth/16)*3, self.viewHeight/3);
}


-(void)dropJaw
{
    self.headMouthView.frame = CGRectMake(self.headMouthView.frame.origin.x, self.headMouthView.frame.origin.y, self.headMouthView.frame.size.width, self.headHeight/2);
}
-(void)moveEyesRight
{
    self.headLeftEyeView.frame = CGRectMake((self.headWidth/8)*2, self.headHeight/8, self.headWidth/4, self.headHeight/4);
    self.headRightEyeView.frame = CGRectMake((self.headWidth/8)*6, self.headHeight/8, self.headWidth/4, self.headHeight/4);
}
-(void)moveEyesUp
{
    self.headLeftEyeView.frame = CGRectMake(self.headWidth/8, 0, self.headWidth/4, self.headHeight/4);
    self.headRightEyeView.frame = CGRectMake((self.headWidth/8)*5, 0, self.headWidth/4, self.headHeight/4);
}

-(void)hidePerson
{
    self.hidden = YES;
}

@end
