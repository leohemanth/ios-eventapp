//
//  DetailViewTableViewController.h
//  GoogleCalendarDemo
//
//  Created by Hemanth on 02/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import <EventKitUI/EventKitUI.h>
@interface DetailViewTableViewController : UITableViewController <EKEventEditViewDelegate>
@property (strong,nonatomic) Event *event;
@end
