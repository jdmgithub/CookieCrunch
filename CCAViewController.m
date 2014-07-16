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

@end
