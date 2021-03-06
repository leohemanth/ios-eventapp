//
//  DetailViewController.m
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/5/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "DetailViewController.h"
#import "FBUserDetails.h"
#import "ADManagedObjectContext.h"
#import "FriendListTableViewController.h"

@interface DetailViewController ()
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic,strong) NSMutableArray *friendList;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventStore = [[EKEventStore alloc] init];
    self.friendList = [[NSMutableArray alloc]init];
    
    NSLog(@"in view did load!!");
    NSLog(@"fillDetail: %@",self.currentEvent);
    NSDateFormatter *dayFormatter, *timeFormatter;
    //= [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MMM-dd"];
    dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = @"yyyy-MM-dd";
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    
    
    NSString * startDateTime = [timeFormatter stringFromDate:self.currentEvent.date];
    NSString *startDate = @"",*startTime=@"";
    NSString * endDateTime = [timeFormatter stringFromDate:self.currentEvent.endDate];
    NSString *endDate=@"",*endTime=@"";
    
    if(self.currentEvent.calIdentifier)
    {
        self.navigationItem.rightBarButtonItem=nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Add to calendar" style:UIBarButtonItemStyleDone target:self action:@selector(addToCall)];
    }
    
    if(startDateTime.length>9)
    {
        NSArray* foo = [startDateTime componentsSeparatedByString: @"T"];
        if(foo.count>0)
            startDate = [foo objectAtIndex:0];
        if(foo.count>1)
            startTime = [foo objectAtIndex:1];
    }
    
    if(endDateTime.length>9)
    {
        
        NSArray* foo = [endDateTime componentsSeparatedByString: @"T"];
        if(foo.count>0)
            endDate = [foo objectAtIndex:0];
        if(foo.count>1)
            endTime = [foo objectAtIndex:1];
    }
    
    
    
    self.lblEndDate.text = [NSString stringWithFormat:@"%@  %@",startDate,startTime];
    self.lblStartDate.text = [NSString stringWithFormat:@"%@  %@",endDate,endTime];;
    
    self.lblLocation.text = self.currentEvent.location;
    self.lblTitle.text = self.currentEvent.summary;
    self.lblEventURL.text = self.currentEvent.fblink;
    self.lblDesc.text=self.currentEvent.desc;
    
    NSURL *url = [NSURL URLWithString:self.currentEvent.pic];
    
    UIImage *image = [[UIImage alloc] init];
    if(url!=NULL)
    {
        NSURLRequest * imgRequest = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if(!error)
            {
                if([imgRequest.URL isEqual:url])
                {
                    UIImage *imgDwnLoaded = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.bannerView setImage:imgDwnLoaded];
                        
                    });
                }
            }
        }];
        [task resume];
        
        
    }
    else
    {
        image=[UIImage imageNamed:@"usc.jpeg"];
        [self.bannerView setImage:image];
        
    }
    
    self.buttonFriendList.hidden = true;
    
    if(self.currentEvent.fbid)
    {
        [self attendingfriendsList:self.currentEvent.fbid];
    }
    else
    {
        self.buttonFriendList.hidden = true;
    }
    
    //CGSize size = img.size;
    if(!self.currentEvent.fblink)
    {
        self.fbbutton.hidden=YES;
        self.lblStatus.hidden=YES;
        self.statusSwitch.hidden=YES;
        self.lblStatusValue.hidden=YES;
        
    }
    else
    {
        self.fbbutton.hidden=NO;
        self.lblStatus.hidden=NO;
        self.statusSwitch.hidden=NO;
        self.lblStatusValue.hidden=NO;
        
        if([self.currentEvent.rsvp  isEqual: @"attending"])
        {
            self.lblStatusValue.text = @"Attending";
            self.statusSwitch.on=YES;
        }
        else if([self.currentEvent.rsvp  isEqual: @"not_replied"])
        {
            self.lblStatusValue.text = @"Not Replied";
            self.statusSwitch.on=NO;
        }
        else if([self.currentEvent.rsvp  isEqual: @"unsure"])
        {
            self.lblStatusValue.text = @"Unsure";
            self.statusSwitch.on=NO;
        }else if([self.currentEvent.rsvp  isEqual: @"declined"])
        {
            self.lblStatusValue.text = @"Declined";
            self.statusSwitch.on=NO;
        }
        else
        {   self.lblStatusValue.text = @"Not Replied";
            self.statusSwitch.on=NO;
        }
    }
  	// Do any additional setup after loading the view.
    [self.statusSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}
- (IBAction)fbbuttonClicked:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentEvent.fblink]];
}

- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
    NSString * status = @"";
    if(state==YES)
    {
        self.lblStatusValue.text = @"Attending";
        status=@"attending";
        
        NSString *queryString = [NSString stringWithFormat:@"/%@/attending",self.currentEvent.fbid];
        [self updateRsvp:queryString];
        
    }
    else
    {
        self.lblStatusValue.text = @"Declined";
        status=@"declined";
        NSString *queryString = [NSString stringWithFormat:@"/%@/declined",self.currentEvent.fbid];
        [self updateRsvp:queryString];
    }
    
    NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fbid == %@", self.currentEvent.fbid];
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if(results.count > 0)
    {
        Event * event = results[0];
        self.currentEvent.rsvp = status;
        event.rsvp = status;
    }
    [context save:nil];
    
}

-(void) updateRsvp:(NSString *) queryString{
    
    NSArray *permissionsNeeded = @[@"rsvp_event",@"publish_actions",@"status_update"];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissionsNeeded
                                            defaultAudience:FBSessionDefaultAudienceFriends
                                          completionHandler:nil];
    
    [FBRequestConnection startWithGraphPath:queryString parameters:nil
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  //[self parseFriendListResult:result];
                              }
                          }];
    
}

-(void)addToCall{
    
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(granted) {
            
            // create/edit your event here
            
            EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
            EKEvent *event;
            addController.editViewDelegate = self;
            addController.eventStore = self.eventStore;
            event = [EKEvent eventWithEventStore:self.eventStore];
            event.title = self.currentEvent.summary;
            event.location = self.currentEvent.location;
            event.startDate = self.currentEvent.date;
            if(self.currentEvent.endDate!=nil)
                event.endDate =  self.currentEvent.endDate;
            else
                event.endDate =  self.currentEvent.date;
            
            event.notes = self.currentEvent.desc;
            event.URL= [NSURL URLWithString:self.currentEvent.fblink];
            addController.event=event;
            [addController.eventStore saveEvent:event span:EKSpanThisEvent error:nil];
            [self presentViewController:addController animated:YES completion:nil];
            // Do any additional setup after loading the view.
        }}];
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"b:%f",self.scrollView.contentSize.height);
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    contentRect.size.height = contentRect.size.height + 50;
    self.scrollView.contentSize = contentRect.size;
    //self.scrollView.contentSize =  contentRect.size;
    
    NSLog(@"a:%f",self.scrollView.contentSize.height);
    self.scrollView.contentSize = self.scrollView.frame.size;
    [super viewDidAppear:animated];
}


- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    
    //Save this calIdentifier into the managed store
    
    if(controller.event.eventIdentifier)
    {
        NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"googleid == %@", self.currentEvent.googleid];
        NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
        
        if(results.count > 0)
        {
            Event * event = results[0];
            event.calIdentifier = [NSString stringWithFormat:@"%@", controller.event.eventIdentifier];
        }
        [context save:nil];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillDetails : (Event *) eventObj
{
    self.currentEvent=eventObj;
    
}

// This method lists all the friends who are going to the event
-(void) attendingfriendsList:(NSString *) eventId
{
    NSString * query = @"select name,pic_small,uid from user"
    @" where uid IN"
    @" (select uid"
    @" from event_member"
    @" where rsvp_status='attending' and uid IN"
    @" (select uid2 from friend where uid1=me())"
    @" and eid='";
    NSString *queryString = [NSString stringWithFormat:@"%@%@')",query,eventId];
    
    NSLog(@"FQL friend fetch query : %@",queryString);
    
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": queryString };
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
                                  [self parseFriendListResult:result];
                              }
                          }];
    
    //[FBRequest requestForPostWithGraphPath:@"<EVENT ID HERE>/attending" graphObject:nil];
}

-(void) parseFriendListResult:(id) result
{
    
    NSArray * friendListData = [result objectForKey:@"data"];
    
    for(int count=0;count<[friendListData count];count++)
    {
        FBGraphObject *friendObject = friendListData[count];
        
        FBUserDetails *fbFriend = [[FBUserDetails alloc]init];
        fbFriend.name = friendObject[@"name"];
        fbFriend.picURL = friendObject[@"pic_small"];
        fbFriend.userID = friendObject[@"uid"];
        
        [self.friendList addObject:fbFriend];
    }
    
    if([self friendList].count>0)
    {
        self.buttonFriendList.hidden = false;
    }
    else
    {
        self.buttonFriendList.hidden = true;
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Inside prepare for segue friend click");
    if(self.friendList.count > 0)
    {
        FriendListTableViewController *friendListController = segue.destinationViewController;
        friendListController.friendArray = [[NSMutableArray alloc]init];
        friendListController.friendArray = self.friendList;
    }
}



@end
