//
//  ADCalendarEventCell.m
//  GoogleCalendarDemo
//
//  Created by Andrew Davis on 1/22/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "ADCalendarEventCell.h"

@interface ADCalendarEventCell ()
@property (strong, nonatomic) UILabel *summaryLabel;
@property (strong, nonatomic) UILabel *monthLabel;
@property (strong, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) UISwitch *removeObject;
@property (strong,nonatomic) IBOutlet UISwitch * addSwitch;
@property (strong, nonatomic) IBOutlet UILabel *subtitleView;
@end

@implementation ADCalendarEventCell

- (void)setSummary:(NSString *)summary date:(NSDate *)date location:(NSString*)location andFblink:(NSString*)fblink{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM";
    }

    NSInteger kMonthTopMargin = 4;
    NSInteger kMonthLeftMargin = 10;
    NSInteger kDayTopMargin = -4;
    NSInteger kSummaryLeftMargin = 12;

   // [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat monthLabelHeight = self.frame.size.height * .3;
    CGFloat dayLabelHeight = self.frame.size.height * .7;

    if(self.monthLabel==nil) self.monthLabel = [[UILabel alloc] init];
    self.monthLabel.text = [[dateFormatter stringFromDate:date] uppercaseString];
    self.monthLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGFloat monthFontSize = self.monthLabel.font.pointSize / [self.monthLabel.text sizeWithFont:self.monthLabel.font].height * monthLabelHeight;
    self.monthLabel.font = [UIFont boldSystemFontOfSize:monthFontSize];
    self.monthLabel.textColor = [UIColor grayColor];
    CGSize monthLabelSize = [self.monthLabel.text sizeWithFont:self.monthLabel.font];
    self.monthLabel.frame = CGRectMake(kMonthLeftMargin, kMonthTopMargin, monthLabelSize.width, monthLabelSize.height);
    [self.contentView addSubview:self.monthLabel];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    if(self.dayLabel==nil) self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.text = [NSString stringWithFormat:@"%02d", [calendar components:NSDayCalendarUnit fromDate:date].day];
    self.dayLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    CGFloat dayFontSize = self.dayLabel.font.pointSize / [self.dayLabel.text sizeWithFont:self.dayLabel.font].height * dayLabelHeight;
    self.dayLabel.font = [UIFont boldSystemFontOfSize:dayFontSize];
    CGSize dayLabelSize = [self.dayLabel.text sizeWithFont:self.dayLabel.font];
    CGFloat dayLabelX = self.monthLabel.frame.origin.x + self.monthLabel.frame.size.width / 2 - dayLabelSize.width / 2;
    CGFloat dayLabelY = self.monthLabel.frame.origin.y + self.monthLabel.frame.size.height + kDayTopMargin;
    self.dayLabel.frame = CGRectMake(dayLabelX, dayLabelY, dayLabelSize.width, dayLabelSize.height);
    self.dayLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.dayLabel];

    CGFloat summaryLabelX = self.dayLabel.frame.origin.x + self.dayLabel.frame.size.width + kSummaryLeftMargin;
    CGRect summaryLabelFrame = CGRectMake(summaryLabelX, 0, self.frame.size.width - summaryLabelX, self.frame.size.height-20);
    CGRect locationLabelFrame = CGRectMake(summaryLabelX, self.frame.size.height-20, self.frame.size.width - summaryLabelX, self.frame.size.height-20);

    if(self.summaryLabel==nil) self.summaryLabel = [[UILabel alloc] initWithFrame:summaryLabelFrame];
    if(self.subtitleView==nil) self.subtitleView = [[UILabel alloc] initWithFrame:locationLabelFrame];
    self.summaryLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.subtitleView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]-5];
    self.summaryLabel.text = summary;
    self.subtitleView.text =location;
    [self.contentView addSubview:self.summaryLabel];
            [self.contentView addSubview:self.subtitleView];
    [self.contentView bringSubviewToFront:self.addSwitch];
    
    if (fblink!=nil)
        self.contentView.backgroundColor=[UIColor colorWithRed:.29 green:.40 blue:64.3 alpha:.5];
    else
        self.contentView.backgroundColor=[UIColor clearColor];
   /* CGFloat summaryLabelX = self.dayLabel.frame.origin.x + self.dayLabel.frame.size.width + kSummaryLeftMargin;
    CGRect summaryLabelFrame = CGRectMake(summaryLabelX, 0, self.frame.size.width - summaryLabelX, self.frame.size.height);
    
    self.removeObject = [[UISwitch alloc]init];
    [self.contentView addSubview:self.removeObject];*/

    
}

@end
