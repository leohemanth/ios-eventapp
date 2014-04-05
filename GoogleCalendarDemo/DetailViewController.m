//
//  DetailViewController.m
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/5/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
	// Do any additional setup after loading the view.
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
