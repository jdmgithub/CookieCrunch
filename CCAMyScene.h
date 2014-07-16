//
//  CCAMyScene.h
//  CookieCrunch
//

//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class CCALevel;
@class CCASwap;

@interface CCAMyScene : SKScene

@property (strong, nonatomic) CCALevel * level;
@property (copy, nonatomic) void (^swipeHandler)(CCASwap *swap);

-(void)addTiles;
-(void)addSpritesForCookies:(NSSet *)cookies;
-(void)animateSwap:(CCASwap *)swap completion:(dispatch_block_t)completion;



@end
