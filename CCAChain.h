//
//  CCAChain.h
//  CookieCrunch
//
//  Created by Jeffery Moulds on 8/8/14.
//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import <Foundation/Foundation.h>



@class CCACookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface CCAChain : NSObject

@property (strong, nonatomic, readonly) NSArray *cookies;

@property (assign, nonatomic) ChainType chainType;

- (void)addCookie:(CCACookie *)cookie;

@end

