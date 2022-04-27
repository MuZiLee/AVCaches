//
//  TTReachabilityManager.m
//  TTPlayerCache
//
//  Created by sunzongtang on 2017/11/21.
//  Copyright © 2017年 szt. All rights reserved.
//

#import "TTReachabilityManager.h"
#import "TTReachability.h"

@implementation TTReachabilityManager
{
    TTReachability *_reachability;
}

static TTReachabilityManager *_instance = nil;
+ (instancetype)sharedReachabilityManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[TTReachabilityManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupReachability];
    }
    return self;
}

- (void)setupReachability {
    _reachability = [TTReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    
    __weak typeof(self) weakSelf = self;
    _reachability.reachabilityBlock = ^(TTReachability *reachability, SCNetworkConnectionFlags flags) {
        if (weakSelf.reachableStatusChanged) {
            weakSelf.reachableStatusChanged(reachability.isReachable);
        }
    };
}

@end
