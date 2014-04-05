//
//  LoginVCViewController.m
//  USCEvents
//
//  Created by Hemanth on 04/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "LoginVCViewController.h"
#import "Event.h"
# import <FacebookSDK/FacebookSDK.h>
#import "ADManagedObjectContext.h"

@interface LoginVCViewController ()

@end

@implementation LoginVCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info",@"email"]];
    // Align the button in the center horizontally
    loginView.delegate = self;
    
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)),95);
    [self.view addSubview:loginView];
    // Do any additional setup after loading the view.
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    [self requestEvents];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
   // self.statusLabel.text = @"You're logged in as";
    
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
   
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)requestEvents
{
    // We will request the user's events
    // These are the permissions we need:
    NSArray *permissionsNeeded = @[@"user_events",@"friends_events",@"friends_about_me",@"friends_location",@"friends_groups",@"user_friends",@"user_groups"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSLog([NSString stringWithFormat:@"current permissions %@", currentPermissions]);
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewReadPermissions:requestPermissions
                                                                       completionHandler:^(FBSession *session, NSError *error) {
                                                                           if (!error) {
                                                                               // Permission granted
                                                                               NSLog([NSString stringWithFormat:@"new permissions %@", [FBSession.activeSession permissions]]);
                                                                               // We can request the user information
                                                                               [self fqlRequest];
                                                                           } else {
                                                                               // An error occurred, we need to handle the error
                                                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                                                               NSLog([NSString stringWithFormat:@"error %@", error.description]);
                                                                           }
                                                                       }];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      [self fqlRequest];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog([NSString stringWithFormat:@"error %@", error.description]);
                              }
                          }];
}

- (void)makeRequestForUserEvents
{
    [FBRequestConnection startWithGraphPath:@"me/events?fields=cover,name,start_time"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSLog([NSString stringWithFormat:@"user events: %@", result]);
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog([NSString stringWithFormat:@"error %@", error.description]);
                              }
                          }];
}


-(void) fqlRequest{
    // Query to fetch the active user's friends, limit to 25.
    
    NSString *query =
    @"SELECT name, venue, location, start_time, eid FROM event"
    @" WHERE eid IN (SELECT eid FROM event_member WHERE uid IN ("
    @" SELECT uid2 FROM friend WHERE uid1 = me() and uid2 in ("
    @" SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) or uid=me()"
    @" AND current_location.state = 'California')) or uid=me())";
    
    
 
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  [self parseResult:result];
                              }
                          }];
}

-(void) parseResult:(id) result
{
    NSArray *resultArray = (NSArray *)[result valueForKey:@"data"];
    NSMutableArray *eventArray = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
    
    static NSDateFormatter *dayFormatter, *timeFormatter;
    if (!dayFormatter || !timeFormatter) {
        dayFormatter = [[NSDateFormatter alloc] init];
        dayFormatter.dateFormat = @"yyyy-MM-dd";
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    }

    for(int i=0;i<resultArray.count;i++)
    {
        FBGraphObject *eventData = resultArray[i];
        Event * fbEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
       
        fbEvent.googleid=eventData[@"eid"];
        fbEvent.location=eventData[@"location"];
        fbEvent.summary=eventData[@"name"];
        fbEvent.desc=eventData[@"name"];
        fbEvent.fbid=eventData[@"eid"];

        NSString * stDateString = eventData[@"start_time"];
        NSString *stDatevalue = [stDateString substringWithRange:NSMakeRange(0,19)];
        fbEvent.date = [timeFormatter dateFromString:stDatevalue];
        
        [eventArray addObject:fbEvent];

    }
    [context save:nil];
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
