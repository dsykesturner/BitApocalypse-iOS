//
//  GameObjectView.h
//  daniel_sykes-turner
//
//  Created by Daniel Sykes-Turner on 8/04/2014.
//  Copyright (c) 2014 UniverseApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameObjectView : UIView

@property (nonatomic) BOOL affectedByGravity; //for objects like building - may not need this

@property (nonatomic) float currentSpeedX; //the speed traveling horizontally
@property (nonatomic) float currentSpeedY; //the speed traveling vertically
@property (nonatomic) float mass; //width * height (px)

@property (nonatomic) int damage; //equal to the mass. object is destoryed when this reaches 0

@property (strong, nonatomic) UIImageView * imageView;

-(void)setImageViewFromImage:(UIImage *)image;

@end
