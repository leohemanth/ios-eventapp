//
//  ADManagedObjectContext.m
//  GoogleCalendarDemo
//
//  Created by Andrew Davis on 1/14/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "ADManagedObjectContext.h"
#import "ADCalendarViewController.h"
#import "Event.h"
#import "EntityFilter.h"
@implementation ADManagedObjectContext

// Get or create a managed object context.
+ (NSManagedObjectContext *)sharedContext {
    static NSManagedObjectContext *context;
    if (!context) {
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context performBlockAndWait:^{
            NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
            NSString *applicationDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSURL *persistentStoreUrl = [NSURL fileURLWithPath:[applicationDocumentsDirectory stringByAppendingPathComponent:@"store.sqlite"]];
            NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
            [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:persistentStoreUrl options:nil error:nil];
            context.persistentStoreCoordinator = persistentStoreCoordinator;
        }];
    }
    return context;
}

// Parse a dictionary of events and add new events to the Core Data store.
+ (NSMutableArray*)updateEvents:(NSArray *)events {
    NSMutableArray *eventArray =[[NSMutableArray alloc]init];
    
    static NSDateFormatter *dayFormatter, *timeFormatter;
    if (!dayFormatter || !timeFormatter) {
        dayFormatter = [[NSDateFormatter alloc] init];
        dayFormatter.dateFormat = @"yyyy-MM-dd";
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    }
    
    NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
    
    [context performBlock:^{
        // Add all new events.
        for (NSDictionary *eventData in events) {
            // Find an event if it is already stored or create it otherwise.
            Event *event;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            NSString *fbID=@"";
            
            //Check if the event is FB or Google
            //If FB filter based on fbid or else based on googleid
            if ([eventData[@"id"] rangeOfString:@"@facebook.com"].location != NSNotFound) {
                NSError *error;
                NSString *pattern = @"e(.*)@facebook.com";
                NSString *string = eventData[@"id"];
                NSRange range = NSMakeRange(0, string.length);
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
                NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
    
                fbID = [eventData[@"id"] substringWithRange:[matches[0] rangeAtIndex:1]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"fbid == %@",fbID];
            }
            else
            {
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"googleid == %@", eventData[@"id"]];
            }
            
            NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
            
            event = (results.count > 0) ? results[0] : [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
            
            if(results.count > 0)
            {
                NSLog(@"matched");
            }
            // Find the start date of the event.
            NSDate *startDate,*endDate;
            /* if (eventData[@"start"][@"date"]) {
             date = [dayFormatter dateFromString:eventData[@"start"][@"date"]];
             } else if (eventData[@"start"][@"dateTime"]) {
             date = [timeFormatter dateFromString:eventData[@"start"][@"dateTime"]];
             }*/
            
            NSString * stDateString = eventData[@"startTime"];
            NSString *stDatevalue = [stDateString substringWithRange:NSMakeRange(0,19)];
            startDate = [timeFormatter dateFromString:stDatevalue];
            
            NSString * endDateString = eventData[@"endTime"];
            NSString *endDatevalue = [endDateString substringWithRange:NSMakeRange(0,19)];
            endDate = [timeFormatter dateFromString:endDatevalue];
            
            // Update event properties.
            [event setValue:eventData[@"id"] forKey:@"googleid"];
            
            if ([eventData[@"id"] rangeOfString:@"@facebook.com"].location != NSNotFound) {
                NSError *error;
                NSString *pattern = @"e(.*)@facebook.com";
                NSString *string = eventData[@"id"];
                NSRange range = NSMakeRange(0, string.length);
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
                NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:range];
                event.fblink = [NSString stringWithFormat:@"https://www.facebook.com/events/%@",[eventData[@"id"] substringWithRange:[matches[0] rangeAtIndex:1]]];
                event.fbid =[eventData[@"id"] substringWithRange:[matches[0] rangeAtIndex:1]];
            }
            
            [event setValue:eventData[@"title"] forKey:@"summary"];
             
            [event setValue:startDate forKey:@"date"];
        
            [event setValue:eventData[@"location"] forKey:@"location"];
            
            [event setValue:eventData[@"description"] forKey:@"desc"];
            
            [event setValue:endDate forKey:@"endDate"];
            // Delete cancelled events.
            if ([eventData[@"status"] isEqualToString:@"cancelled"]) {
                [context deleteObject:event];
            }
            
            [eventArray addObject:event];
        }
        
        // Delete old events.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date < %@", [self today]];
        NSArray *oldEvents = [context executeFetchRequest:fetchRequest error:nil];
        for (NSManagedObject *oldEvent in oldEvents) {
            [context deleteObject:oldEvent];
        }
        
        NSString *titleConstant = @"title";
        // Get all the title filtered events.
        NSFetchRequest *fetchFilterRequest = [[NSFetchRequest alloc] initWithEntityName:@"EntityFilter"];
        fetchFilterRequest.predicate = [NSPredicate predicateWithFormat:@"field = %@",titleConstant];
        NSArray *filterObjArray = [context executeFetchRequest:fetchFilterRequest error:nil];
        
        for(NSManagedObject * filter in filterObjArray)
        {
            NSFetchRequest *fetchDelRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
            fetchDelRequest.predicate = [NSPredicate predicateWithFormat:@"summary = %@",((EntityFilter*)filter).summary];
            NSArray *oldEvents = [context executeFetchRequest:fetchDelRequest error:nil];
            for (NSManagedObject *oldEvent in oldEvents) {
                [context deleteObject:oldEvent];
            }
        }
        
        [context save:nil];
    }];
    
    return eventArray;
}

// Create a fetched results controller to get events that will occur in the next year.
+ (NSFetchedResultsController *)createEventResultsController {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    // Get the date of today and one year from today.
    NSDate *today = [self today];
    NSDate *nextYear = [self yearFromDate:today];
    
    // The fetched results controller should show events in the next year sorted by date.
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    request.returnsDistinctResults=YES;
    [request setPropertiesToFetch:@[@"fblink"]];
    request.predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", today, nextYear];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
    NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"EventCache"];
}

// Get the beginning of today's date in GMT.
+ (NSDate *)today {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    return [calendar dateFromComponents:components];
}

// Get a date in GMT by adding one year to the given date.
+ (NSDate *)yearFromDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.year = 1;
    return [calendar dateByAddingComponents:offsetComponents toDate:date options:0];
}

@end
