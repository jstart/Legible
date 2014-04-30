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
#import <Crashlytics/Crashlytics.h>

@implementation LEGAppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [MagicalRecord setupCoreDataStack];

    LEGLibraryTableViewController * libraryTableVC = [[LEGLibraryTableViewController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:libraryTableVC];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    [Crashlytics startWithAPIKey:@"ff6f76d45da103570f8070443d1760ea5199fc81"];
    return YES;
}

@end
