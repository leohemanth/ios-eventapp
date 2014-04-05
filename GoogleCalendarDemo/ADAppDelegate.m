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
#import "LoginVCViewController.h"

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
    
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Load the FBProfilePictureView
    // You can find more information about why you need to add this line of code in our troubleshooting guide
    // https://developers.facebook.com/docs/ios/troubleshooting#objc
    [FBProfilePictureView class];
    
    
    
    return YES;
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
            }

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
@end
