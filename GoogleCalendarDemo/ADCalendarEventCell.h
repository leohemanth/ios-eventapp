//
//  ADCalendarEventCell.h
//  GoogleCalendarDemo
//
//  Created by Andrew Davis on 1/22/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADCalendarEventCell : UITableViewCell
- (void)setSummary:(NSString *)summary date:(NSDate *)date location:(NSString*)location andFblink:(NSString*)fblink;
@end
