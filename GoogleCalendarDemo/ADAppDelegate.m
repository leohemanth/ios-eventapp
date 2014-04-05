//
//  ADAppDelegate.m
//  GoogleCalendarDemo
//
//  Created by Andrew Davis on 1/12/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "ADAppDelegate.h"
#import "ADCalendarViewController.h"
#import <Parse/Parse.h>

@implementation ADAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ADCalendarViewController alloc] init]];
//    [self.window makeKeyAndVisible];
    [Parse setApplicationId:@"SZvrNV7McrZ3jTD7WA2tvF7HxC2RssUBx1upFIx3"
                  clientKey:@"T0t9VgkBqGUhSdGGWPUwbHnXASXqRh9lvAfH43sd"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
@end
