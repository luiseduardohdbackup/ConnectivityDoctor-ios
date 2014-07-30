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
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.serverGroupStore = [ServerGroups sharedInstance];

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
    [cell startDisplayAtPath:indexPath];
    return cell;
}

@end
