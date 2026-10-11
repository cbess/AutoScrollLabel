//
//  ASLAppDelegate.m
//  AutoScrollLabelDemo
//
//  Created by Christopher Bess on 6/25/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import "ASLAppDelegate.h"

@implementation ASLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
