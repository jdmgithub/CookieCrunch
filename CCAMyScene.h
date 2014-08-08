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
-(void)animateInvalidSwap:(CCASwap *)swap completion:(dispatch_block_t)completion;
-(void)animateMatchedCookies:(NSSet *)chains completion:(dispatch_block_t)completion;
-(void)animateFallingCookies:(NSArray *)columns completion:(dispatch_block_t)completion;
-(void)animateNewCookies:(NSArray *)columns completion:(dispatch_block_t)completion;



@end
