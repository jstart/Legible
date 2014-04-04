//
//  LEGAppDelegate.m
//  Legible
//
//  Created by Christopher Truman on 4/2/14
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGAppDelegate.h"

#import "LEGMainViewController.h"

@implementation LEGAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    LEGMainViewController * mainVC = [[LEGMainViewController alloc] init];
    self.window.rootViewController = mainVC;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
