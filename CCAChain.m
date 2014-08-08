//
//  CCAChain.m
//  CookieCrunch
//
//  Created by Jeffery Moulds on 8/8/14.
//  Copyright (c) 2014 Jeffery Moulds. All rights reserved.
//

#import "CCAChain.h"

@implementation CCAChain {
    NSMutableArray *_cookies;
}

- (void)addCookie:(CCACookie *)cookie {
    if (_cookies == nil) {
        _cookies = [NSMutableArray array];
    }
    [_cookies addObject:cookie];
}

- (NSArray *)cookies {
    return _cookies;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld cookies:%@", (long)self.chainType, self.cookies];
}


@end
