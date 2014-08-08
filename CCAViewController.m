//
//  CCAViewController.m
//  CookieCrunch
//
//  Created by Jeffery Moulds on 7/2/14.
//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import "CCAViewController.h"
#import "CCAMyScene.h"
#import "CCALevel.h"

@interface CCAViewController ()

@property (strong, nonatomic) CCALevel * level;
@property (strong, nonatomic) CCAMyScene * scene;

@end

@implementation CCAViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    
    // Create and configure the scene.
    self.scene = [CCAMyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Load the level.
    self.level = [[CCALevel alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;
    
    // Load the Tiles.
    [self.scene addTiles];
    
    
//    id block = ^(CCASwap *swap)
//    {
//        self.view.userInteractionEnabled = NO;
//        
//        [self.level performSwap:swap];
//        [self.scene animateSwap:swap completion:^{
//            self.view.userInteractionEnabled = YES;
//        }];
//    };

    
    id block = ^(CCASwap *swap) {
        self.view.userInteractionEnabled = NO;
        
        if ([self.level isPossibleSwap:swap]) {
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
//                self.view.userInteractionEnabled = YES;
                [self handleMatches];
            }];
        } else {
            //self.view.userInteractionEnabled = YES;
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    
    // Present the scene.
    [skView presentScene:self.scene];
    
    // Let's start the game!
    [self beginGame];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)beginGame {
    [self shuffle];
}

- (void)shuffle {
    NSSet *newCookies = [self.level shuffle];
    [self.scene addSpritesForCookies:newCookies];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



-(BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)handleMatches {
    NSSet *chains = [self.level removeMatches];
    
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }
    
    [self.scene animateMatchedCookies:chains completion:^{
        NSArray *columns = [self.level fillHoles];
        [self.scene animateFallingCookies:columns completion:^{
            NSArray *columns = [self.level topUpCookies];
            [self.scene animateNewCookies:columns completion:^{
//                self.view.userInteractionEnabled = YES;

            [self handleMatches];
            }];
        }];
    }];

}

- (void)beginNextTurn {
    [self.level detectPossibleSwaps];
    self.view.userInteractionEnabled = YES;
}

@end
