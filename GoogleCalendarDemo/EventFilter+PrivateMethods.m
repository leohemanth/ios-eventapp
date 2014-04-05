//
//  EventFilter+PrivateMethods.m
//  USCEvents
//
//  Created by Hemanth on 05/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "EventFilter+PrivateMethods.h"
#import "Event.h"
@implementation EventFilter (PrivateMethods)
-(void)filterEvent:(Event *)event{
    EventFilter *entityFilter = (EventFilter*)[NSEntityDescription entityForName:@"EventFilter" inManagedObjectContext:self.managedObjectContext];
    entityFilter.summary=event.summary;
}
@end
