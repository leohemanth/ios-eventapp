//
//  DetailViewController.h
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/5/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface DetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblStartDate;
@property (strong, nonatomic) IBOutlet UILabel *lblEndDate;
@property (strong, nonatomic) IBOutlet UIImageView *calView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblEventURL;
@property (strong, nonatomic) IBOutlet UIButton *btnCalendarAdd;
@property (strong,nonatomic) Event * currentEvent;
-(void)fillDetails : (Event *) eventObj;
@end
