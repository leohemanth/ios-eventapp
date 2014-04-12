//
//  DetailViewController.m
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/5/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, strong) EKEventStore *eventStore;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventStore = [[EKEventStore alloc] init];
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
    
    if(self.currentEvent.fbid)
    [self attendingfriendsList:self.currentEvent.fbid];
    
    //CGSize size = img.size;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addToCall)];
    
	// Do any additional setup after loading the view.
}
-(void)addToCall{
    EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
    EKEvent *event;
    addController.editViewDelegate = self;
    addController.eventStore = self.eventStore;
    event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = self.currentEvent.summary;
    event.location = self.currentEvent.location;
    event.startDate = self.currentEvent.date;
    event.endDate =  self.currentEvent.endDate;
    event.notes = self.currentEvent.desc;
    event.URL= [NSURL URLWithString:self.currentEvent.fblink];
    addController.event=event;
    [self presentViewController:addController animated:YES completion:nil];
    // Do any additional setup after loading the view.
   }

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"b:%f",self.scrollView.contentSize.height);
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    self.scrollView.contentSize = contentRect.size;
    NSLog(@"a:%f",self.scrollView.contentSize.height);
    [super viewDidAppear:animated];
}


- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
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

-(void) attendingfriendsList:(NSString *) eventId
{
    NSString * query = @"select name from user"
                                @" where uid IN"
                                    @" (select uid"
                                        @" from event_member"
                                        @" where rsvp_status='attending' and uid IN"
                                            @" (select uid2 from friend where uid1=me())"
                                                @" and eid='";
    NSString *queryString = [NSString stringWithFormat:@"%@%@')",query,eventId];
    
    
}

@end
