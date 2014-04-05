//
//  EntityFilter.h
//  USCEvents
//
//  Created by Hemanth on 05/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EntityFilter : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * field;
@property (nonatomic, retain) NSString * type;

@end
