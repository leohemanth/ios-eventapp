//
//  EventFilter.h
//  USCEvents
//
//  Created by Hemanth on 05/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventFilter : NSManagedObject

@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * eventid;
@property (nonatomic, retain) NSString * fbgroup;
@property (nonatomic, retain) NSString * type;

@end
