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
    
    self.lblEndDate.text = [timeFormatter stringFromDate:self.currentEvent.date];
    self.lblStartDate.text = [timeFormatter stringFromDate:self.currentEvent.date];
    
    self.lblLocation.text = self.currentEvent.location;
    self.lblTitle.text = self.currentEvent.summary;
    self.lblEventURL.text = self.currentEvent.fblink;
    self.lblDesc.text=self.currentEvent.desc;
    NSURL *url = [NSURL URLWithString:self.currentEvent.pic];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    //CGSize size = img.size;
    [self.bannerView setImage:img];
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

@end
