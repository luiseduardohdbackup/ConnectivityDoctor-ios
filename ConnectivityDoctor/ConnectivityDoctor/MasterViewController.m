//
//  MasterViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "MasterViewController.h"
#import "ServerGroups.h"
#import "GroupCell.h"




@interface MasterViewController ()
@property (nonatomic) ServerGroups * serverGroupStore;
- (void)configureCell:(GroupCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   

    self.serverGroupStore = [ServerGroups sharedInstance];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[self.serverGroupStore groupLabels] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
       
       // [[segue destinationViewController] setDetailItem:[self.serverGroupStore groupLabels][indexPath.row]];
    }
}


- (void)configureCell:(GroupCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray * groupNames = [self.serverGroupStore groupLabels];
    
    NSDictionary * dict = groupNames[indexPath.row];
    NSString* groupName = [dict objectForKey:SGName];
    
    cell.nameLabel.text = groupName;
    [cell networkTestForGroup:[dict objectForKey:SGJSONName]];
    cell.nameDetailLabel.text = [dict objectForKey:SGDescription];
    
    if(indexPath.row % 2 == 0)
    {
        //even
         cell.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
        
    } else {
        //odd
         cell.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
    }
    
    //TEST
//    if([groupName isEqualToString:@"logging"]){
//        cell.nameLabel.text = groupName;
//        [cell networkTestForGroup:groupName];
//    }
    
   

}

@end
