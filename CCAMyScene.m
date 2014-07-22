//
//  CCAMyScene.m
//  CookieCrunch
//
//  Created by Jeffery Moulds on 7/2/14.
//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import "CCAMyScene.h"
#import "CCACookie.h"
#import "CCALevel.h"
#import "CCASwap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface CCAMyScene ()

@property (strong, nonatomic) SKNode *gameLayer;
@property (strong, nonatomic) SKNode *cookiesLayer;
@property (strong, nonatomic) SKNode *tilesLayer;
@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@property (strong, nonatomic) SKSpriteNode *selectionSprite;
@property (strong, nonatomic) SKAction *swapSound;
@property (strong, nonatomic) SKAction *invalidSwapSound;
@property (strong, nonatomic) SKAction *matchSound;
@property (strong, nonatomic) SKAction *fallingCookieSound;
@property (strong, nonatomic) SKAction *addCookieSound;


@end



@implementation CCAMyScene

-(id)initWithSize:(CGSize)size {    
    if ((self = [super initWithSize:size]))
    {

        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        SKSpriteNode * background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    
        [self addChild:background];
        
        
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        CGPoint layerPosition = CGPointMake(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);
        
        self.tilesLayer = [SKNode node];
        self.tilesLayer.position = layerPosition;
        [self.gameLayer addChild:self.tilesLayer];
        
        
        self.cookiesLayer = [SKNode node];
        self.cookiesLayer.position = layerPosition;
        
        [self.gameLayer addChild:self.cookiesLayer];
        
        self.swipeFromColumn = self.swipeFromRow = NSNotFound;
        
        self.selectionSprite = [SKSpriteNode node];

        [self preloadResources];

    }
    return self;
}


- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}





- (void)addSpritesForCookies:(NSSet *)cookies {
    for (CCACookie *cookie in cookies) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
        sprite.position = [self pointForColumn:cookie.column row:cookie.row];
        [self.cookiesLayer addChild:sprite];
        cookie.sprite = sprite;
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    // 2
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        // 3
        CCACookie *cookie = [self.level cookieAtColumn:column row:row];
        if (cookie != nil) {
            
            [self showSelectionIndicatorForCookie:cookie];

            // 4
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
        }
    }
}


- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < NumColumns*TileWidth &&
        point.y >= 0 && point.y < NumRows*TileHeight) {
        
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    if (self.swipeFromColumn == NSNotFound) return;
    
    // 2
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        // 3
        NSInteger horzDelta = 0, vertDelta = 0;
        if (column < self.swipeFromColumn) {          // swipe left
            horzDelta = -1;
        } else if (column > self.swipeFromColumn) {   // swipe right
            horzDelta = 1;
        } else if (row < self.swipeFromRow) {         // swipe down
            vertDelta = -1;
        } else if (row > self.swipeFromRow) {         // swipe up
            vertDelta = 1;
        }
        
        // 4
        if (horzDelta != 0 || vertDelta != 0) {
            [self trySwapHorizontal:horzDelta vertical:vertDelta];
            
            [self hideSelectionIndicator];

            // 5
            self.swipeFromColumn = NSNotFound;
        }
    }
}


- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta
{
    // 1
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    // 2
    if (toColumn < 0 || toColumn >= NumColumns) return;
    if (toRow < 0 || toRow >= NumRows) return;
    
    // 3
    CCACookie *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
    if (toCookie == nil) return;
    
    // 4
    CCACookie *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    NSLog(@"*** swapping %@ with %@", fromCookie, toCookie);

    if (self.swipeHandler != nil) {
        CCASwap *swap = [[CCASwap alloc] init];
        swap.cookieA = fromCookie;
        swap.cookieB = toCookie;
        
        self.swipeHandler(swap);
    }
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
        [self hideSelectionIndicator];
    }
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


- (void)animateSwap:(CCASwap *)swap completion:(dispatch_block_t)completion {
    // Put the cookie you started with on top.
    swap.cookieA.sprite.zPosition = 100;
    swap.cookieB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.3;
    
    SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
    
    SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    [swap.cookieB.sprite runAction:moveB];
    
    [self runAction:self.swapSound];

}


- (void)showSelectionIndicatorForCookie:(CCACookie *)cookie {
    // If the selection indicator is still visible, then first remove it.
    if (self.selectionSprite.parent != nil) {
        [self.selectionSprite removeFromParent];
    }
    
    SKTexture *texture = [SKTexture textureWithImageNamed:[cookie highlightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];
    
    [cookie.sprite addChild:self.selectionSprite];
    self.selectionSprite.alpha = 1.0;
}


- (void)hideSelectionIndicator {
    [self.selectionSprite runAction:[SKAction sequence:@[
    [SKAction fadeOutWithDuration:0.3],
    [SKAction removeFromParent]]]];
}

- (void)animateInvalidSwap:(CCASwap *)swap completion:(dispatch_block_t)completion {
    swap.cookieA.sprite.zPosition = 100;
    swap.cookieB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.cookieB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];

    [self runAction:self.invalidSwapSound];

}

- (void)preloadResources {
    self.swapSound = [SKAction playSoundFileNamed:@"Chomp.wav" waitForCompletion:NO];
    self.invalidSwapSound = [SKAction playSoundFileNamed:@"Error.wav" waitForCompletion:NO];
    self.matchSound = [SKAction playSoundFileNamed:@"Ka-Ching.wav" waitForCompletion:NO];
    self.fallingCookieSound = [SKAction playSoundFileNamed:@"Scrape.wav" waitForCompletion:NO];
    self.addCookieSound = [SKAction playSoundFileNamed:@"Drip.wav" waitForCompletion:NO];
}


@end
