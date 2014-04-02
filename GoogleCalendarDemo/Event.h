//
//  Event.h
//  GoogleCalendarDemo
//
//  Created by Hemanth on 02/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * googleid;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * summary;

@end
