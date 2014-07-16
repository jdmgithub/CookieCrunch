//
//  CCAMyScene.h
//  CookieCrunch
//

//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class CCALevel;

@interface CCAMyScene : SKScene

@property (strong, nonatomic) CCALevel * level;

-(void)addSpritesForCookies:(NSSet *)cookies;


@end
