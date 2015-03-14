//
//  MPMAppDelegate.m
//  Hiking Maps
//
//  Created by Morgan McCoy on 5/19/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMAppDelegate.h"
#import "MPMHomeViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation MPMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // API key for Google Maps SDK
    [GMSServices provideAPIKey:@"AIzaSyB9dWWo3kdDkuQz2aynUe7mA3djUxzg4tk"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // create the home view controller and set it as the root
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MPMHomeViewController alloc] init]];
    
    // set navigation bar to olive green color
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.729 green:0.722 blue:0.424 alpha:1.0]];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
