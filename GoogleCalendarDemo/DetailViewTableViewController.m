//
//  DetailViewTableViewController.m
//  GoogleCalendarDemo
//
//  Created by Hemanth on 02/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "DetailViewTableViewController.h"
#import <EventKit/EventKit.h>
#import "ADManagedObjectContext.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 30.0f

@interface DetailViewTableViewController ()
@property BOOL addedCalled;
@property (nonatomic, strong) EKEventStore *eventStore;
@end

@implementation DetailViewTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addedCalled=NO;
    self.eventStore = [[EKEventStore alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *components;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"detailCell"];
    }
    switch (indexPath.row) {
        case 0:
            if (self.event.date) {
                components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                             fromDate:[NSDate date] toDate: self.event.date options: 0];
                cell.textLabel.text = [formatter stringFromDate:self.event.date];
                cell.detailTextLabel.text =[NSString stringWithFormat:@"%d days left",[components day]];
            }
            break;
        case 1:
            if (self.event.date && self.event.endDate) {
                components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                             fromDate: self.event.endDate toDate:self.event.date options: 0];
                cell.textLabel.text = [formatter stringFromDate:self.event.endDate];
                cell.detailTextLabel.text =[NSString stringWithFormat:@"%d days event",[components day]];
            }
            break;
        case 2:
            cell.textLabel.text=@"desc";
            cell.detailTextLabel.text=self.event.desc;
            break;
        case 3:
            cell.textLabel.text=@"googleid";
            cell.detailTextLabel.text=self.event.googleid;
            break;
        case 4:
            cell.textLabel.text=@"location";
            cell.detailTextLabel.text=self.event.location;
            break;
        case 5:
            cell.textLabel.text=@"summary";
            cell.detailTextLabel.text=self.event.summary;
            break;
        case 6:
            cell.textLabel.text=@"fbid";
            cell.detailTextLabel.text=self.event.fbid;
            break;
        case 7:
            cell.textLabel.text=@"fblink";
            cell.detailTextLabel.text=self.event.fblink;
            break;
        case 8:
            if(self.addedCalled || self.event.calIdentifier!=nil)
                cell.textLabel.text=@"added to your calender";
            else
                cell.textLabel.text=@"add to calender";
            
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==8) {
        EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
        EKEvent *event;
        addController.editViewDelegate = self;
        addController.eventStore = self.eventStore;
        if (self.event.calIdentifier) {
//            NSLog(@"id:%@",self.event.calIdentifier);
//            event=[self.eventStore eventWithIdentifier:self.event.calIdentifier];
//            EKCalendarItem * cal =[self.eventStore calendarItemWithIdentifier:self.event.calIdentifier];
//            NSLog(@"event:%@ %@",event,cal);
//            addController.event = event;
//            
        }else{
            [self.tableView reloadData];
            event = [EKEvent eventWithEventStore:self.eventStore];
            event.title = self.event.summary;
            event.location = self.event.location;
            event.startDate = self.event.date;
            event.endDate =  self.event.endDate;
            event.notes = self.event.desc;
            event.URL= [NSURL URLWithString:self.event.fblink];
            addController.event=event;
        }
        [self presentViewController:addController animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (action==EKEventEditViewActionSaved) {
        self.addedCalled=YES;
        [self.eventStore commit:nil];
        NSManagedObjectContext *context = [ADManagedObjectContext sharedContext];
        self.event.calIdentifier=controller.event.calendarItemIdentifier;
        NSLog(@"%@",self.event.calIdentifier);
        [context save:nil];
    }
    [self.tableView reloadData];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
