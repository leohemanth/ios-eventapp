//
//  ADCalendarViewController.m
//  GoogleCalendarDemo
//
//  Created by Andrew Davis on 1/13/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "ADCalendarViewController.h"
#import "AFNetworking.h"
#import "ADManagedObjectContext.h"
#import "ADCalendarEventCell.h"
#import "Event.h"
#import "DetailViewTableViewController.h"
#import "EntityFilter.h"
#import <FacebookSDK/FacebookSDK.h>
#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@interface ADCalendarViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) NSFetchedResultsController *filteredCandyArray;
@end

@implementation ADCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // In iOS 7+, don't extend the table view underneath the navigation bar.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self.navigationItem setHidesBackButton:YES animated:NO];
    // Add a navigation bar title.
    self.navigationItem.title = @"USC EVENTS";
    self.eventsArray  = [[NSMutableArray alloc] init];
    
    // Set up an NSFetchedResultsController to respond to changes in Core Data storage.
    self.fetchedResultsController = [ADManagedObjectContext createEventResultsController];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    
    // Set up the refresh control and start a refresh action.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateCalendar) forControlEvents:UIControlEventValueChanged];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
   [self updateCalendar];
    [self fqlRequest];
}

// Fetch calendar events. Show a pull-down spinner while updating.
- (void)updateCalendar {
    [self.refreshControl beginRefreshing];
    NSString * calendarUrl = @"https://script.google.com/macros/s/AKfycbzFeP6g6XKoyu9vRWWhKZQlSgNCGAtUA0sGNVBVq0BWPTAaMS8R/exec?id=0AraZ8rUzuRiRdGppRWZPNzBBZkR3THhmY0M4aVRpS1E&sheet=TMP";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:calendarUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.eventsArray = [ADManagedObjectContext updateEvents:responseObject[@"TMP"]];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(ADCalendarEventCell *)cell setSummary:[event valueForKey:@"summary"] date:[event valueForKey:@"date"] location:[event valueForKey:@"location"] andFblink:event.fblink];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ADCalendarViewControllerCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ADCalendarEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NSLog(@"swiped!! %@",[self.fetchedResultsController objectAtIndexPath:indexPath]);
       
        
        //Get the context
        NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
        
        NSManagedObject *eventFilter = [NSEntityDescription insertNewObjectForEntityForName:@"EntityFilter" inManagedObjectContext:context];
        
        EntityFilter *filter = (EntityFilter *)eventFilter;
        Event * selectedEvent = (Event *) [self.fetchedResultsController objectAtIndexPath:indexPath];
        filter.eventid=selectedEvent.googleid;
        filter.field=@"title";
        filter.summary=selectedEvent.summary;
        filter.type=selectedEvent.fbid;
        filter.value=selectedEvent.description;
        
        //Delete the row from event
        // Delete old events.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"summary = %@", selectedEvent.summary];
        NSArray *oldEvents = [context executeFetchRequest:fetchRequest error:nil];
        for (NSManagedObject *oldEvent in oldEvents) {
            [context deleteObject:oldEvent];
        }
        
        [context save:nil];
        NSError*error;
        [self.fetchedResultsController performFetch:&error];
         [self.tableView reloadData];
        
    }
}
//-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
//    Event *event=[self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
//    if (event.fblink==nil)
//        return YES;
//    else{
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:event.fblink]];
//        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
//        return NO;
//    }
//}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    Event *event = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
//    if ([segue.identifier isEqualToString:@"eventDetail"]) {
//        DetailViewTableViewController* detail= segue.destinationViewController;
//        detail.event=event;
//    }
//    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Event *event = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    DetailViewTableViewController* detail= [[DetailViewTableViewController alloc ] init];
    detail.event=event;
    [self.navigationController pushViewController:detail animated:YES];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


-(void) fqlRequest{
    // Query to fetch the active user's friends, limit to 25.
    
    NSString *query =
    @"SELECT name, venue, location, start_time, eid FROM event"
    @" WHERE eid IN (SELECT eid FROM event_member WHERE uid IN ("
    @" SELECT uid2 FROM friend WHERE uid1 = me() and uid2 in ("
    @" SELECT uid FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) or uid=me()"
    @" AND current_location.state = 'California')) or uid=me()) and venue.state IN ('California','CA')";
    
    
    NSLog(@"FQL:%@",query);
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Result: %@", result);
                                  [self parseResult:result];
                              }
                          }];
}

-(void) parseResult:(id) result
{
    NSArray *resultArray = (NSArray *)[result valueForKey:@"data"];
    NSMutableArray *eventArray = [[NSMutableArray alloc]init];
    NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
    
    static NSDateFormatter *dayFormatter, *timeFormatter;
    if (!dayFormatter || !timeFormatter) {
        dayFormatter = [[NSDateFormatter alloc] init];
        dayFormatter.dateFormat = @"yyyy-MM-dd";
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    }
    
    for(int i=0;i<resultArray.count;i++)
    {
        FBGraphObject *eventData = resultArray[i];
        Event * fbEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
        fbEvent.googleid=NULL_TO_NIL(eventData[@"eid"]);
        fbEvent.location=NULL_TO_NIL(eventData[@"location"]);
        fbEvent.summary=NULL_TO_NIL(eventData[@"name"]);
        fbEvent.desc=NULL_TO_NIL(eventData[@"name"]);
        fbEvent.fbid=NULL_TO_NIL(eventData[@"eid"]);
        fbEvent.fblink= [NSString stringWithFormat:@"https://www.facebook.com/events/%@",fbEvent.fbid ];
        NSString * stDateString = NULL_TO_NIL(eventData[@"start_time"]);
        if (stDateString.length>12)
            fbEvent.date = [timeFormatter dateFromString:stDateString];
        else
            fbEvent.date = [dayFormatter dateFromString:stDateString];
        [eventArray addObject:fbEvent];
    }
    [context save:nil];
    NSError*error;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
    
}


@end
