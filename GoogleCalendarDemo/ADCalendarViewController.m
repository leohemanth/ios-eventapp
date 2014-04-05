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
}

// Fetch calendar events. Show a pull-down spinner while updating.
- (void)updateCalendar {
    [self.refreshControl beginRefreshing];
    NSLog(@"sadsdf");
    NSString * calendarUrl = @"https://script.google.com/macros/s/AKfycbzFeP6g6XKoyu9vRWWhKZQlSgNCGAtUA0sGNVBVq0BWPTAaMS8R/exec?id=0AraZ8rUzuRiRdGppRWZPNzBBZkR3THhmY0M4aVRpS1E&sheet=TMP";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:calendarUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        self.eventsArray = [ADManagedObjectContext updateEvents:responseObject[@"TMP"]];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [(ADCalendarEventCell *)cell setSummary:[event valueForKey:@"summary"] date:[event valueForKey:@"date"] andLocation:[event valueForKey:@"location"]];
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
//    if (!cell) {
//        cell = [[ADCalendarEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
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
        
        //[self.fetchedResultsController objectAtIndexPath:indexPath];
        
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
       Event *event = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"eventDetail"]) {
        DetailViewTableViewController* detail= segue.destinationViewController;
        detail.event=event;
    }
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

@end
