//
//  LEGAppDelegate.m
//  Legible
//
//  Created by Christopher Truman on 4/2/14
//  Copyright (c) 2014 truman. All rights reserved.
//

#import "LEGAppDelegate.h"

#import "LEGLibraryTableViewController.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

@implementation LEGAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [MagicalRecord setupCoreDataStack];

    LEGLibraryTableViewController * libraryTableVC = [[LEGLibraryTableViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:libraryTableVC];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

@end
