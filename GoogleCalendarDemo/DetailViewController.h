//
//  DetailViewController.h
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/5/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface DetailViewController : UIViewController<UIScrollViewDelegate,EKEventEditViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblStartDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEndDate;
@property (weak, nonatomic) IBOutlet UIImageView *calView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblEventURL;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIImageView *calImage;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusValue;
@property (weak,nonatomic) IBOutlet UIScrollView * scrollView;
@property (weak,nonatomic) IBOutlet UIButton *buttonFriendList;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@property (strong,nonatomic) Event * currentEvent;
@property (strong, nonatomic) IBOutlet UIButton *fbbutton;
-(void)fillDetails : (Event *) eventObj;

@end
