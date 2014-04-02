//
//  DetailViewTableViewController.m
//  GoogleCalendarDemo
//
//  Created by Hemanth on 02/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import "DetailViewTableViewController.h"

@interface DetailViewTableViewController ()

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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *components;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                         fromDate:[NSDate date] toDate: self.event.date options: 0];
            cell.textLabel.text = [formatter stringFromDate:self.event.date];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%d days left",[components day]];
            break;
        case 1:
            components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                         fromDate: self.event.endDate toDate:self.event.date options: 0];
            cell.textLabel.text = [formatter stringFromDate:self.event.endDate];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%d days event",[components day]];
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
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
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
