//
//  Event.h
//  USCEvents
//
//  Created by Hemanth on 05/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * fbid;
@property (nonatomic, retain) NSString * fblink;
@property (nonatomic, retain) NSString * googleid;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * calIdentifier;
@property (nonatomic, retain) NSString * pic;
@property (nonatomic, retain) NSString * rsvp;

@end
