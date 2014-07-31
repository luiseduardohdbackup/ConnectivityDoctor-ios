//
//  ReportTableViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/5/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ReportTableViewController.h"
#import "ReportTableViewCell.h"
#import "ServerGroups.h"
#import "Utils.h"


@interface ReportTableViewController ()
@property (nonatomic) UIView * sectionView;
@property (nonatomic) ReportTableViewCell * cell;
@property (nonatomic) ServerGroups * serverGroupStore;
@end

@implementation ReportTableViewController

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
    
     self.sectionView = [self.tableView dequeueReusableCellWithIdentifier:@"SectionHeader"];
     self.cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    
     self.serverGroupStore = [ServerGroups sharedInstance];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)shareReport:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
  
    self.serverGroupStore = [ServerGroups sharedInstance];
    
    [sharingItems addObject:kUtils_ReportHeaderText];
    [sharingItems addObject:[Utils date_HH_AP_MM_DD_YYYY]];
    [sharingItems addObject:@"------------------------------------"];
    
    
    for (NSDictionary * d in [self.serverGroupStore groupLabels]) {
        [sharingItems addObject:[d objectForKey:SGName]];
        [sharingItems addObject:[d objectForKey:SGDescription]];
   
        SGFinishedStatus status = [self.serverGroupStore groupFinishedStatus:[d objectForKey:SGJSONName]];
        if ((status == SGAllHostsConnected) || (status == SGSomeHostConnected))
        {
            [sharingItems addObject:@"Test Result:"];
            [sharingItems addObject:[d objectForKey:SGResultSuccess]];

        } else if(status == SGAllHostsFailed)
        {
            [sharingItems addObject:@"Test Result:"];
            [sharingItems addObject:[d objectForKey:SGResultError]];
            [sharingItems addObject:@"Message:"];
            [sharingItems addObject:[d objectForKey:SGErrorMessage]];

        }
        else if(status == SGAllHostsSomeConnectedAndSomeFailed)
        {
            [sharingItems addObject:@"Test Result:"];
            [sharingItems addObject:[d objectForKey:SGResultWarning]];
            [sharingItems addObject:@"Message:"];
            
            NSArray * hosts = [self.serverGroupStore hostsForGroup:[d objectForKey:SGJSONName]];
            NSString * message = @"";
            for (NSDictionary * host in hosts) {
                NSString * connected = [host objectForKey:kConnected];
                NSString * checked = [host objectForKey:kHostChecked];
                NSString * secured = [host objectForKey:kSecured];
                if([connected isEqualToString:@"NO"] && [checked isEqualToString:@"YES"] && [secured isEqualToString:@"YES"])
                {
                    message = [d objectForKey:SGWarningNonSecure];
                } else if([connected isEqualToString:@"NO"] && [checked isEqualToString:@"YES"] && [secured isEqualToString:@"NO"])
                {
                    message = [d objectForKey:SGWarningSecure];
                }
                
            }

            [sharingItems addObject:message];

        }

        [sharingItems addObject:@"\n"];

    }
    [sharingItems addObject:@"------------------------------------"];
    [sharingItems addObject:@"If you have any questions, please contact TokBox at support@tokbox.com."];
  
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[sharingItems componentsJoinedByString:@"\n"]] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    return self.sectionView;
 
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.sectionView.frame.size.height;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
   return [[self.serverGroupStore groupLabels] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell" forIndexPath:indexPath];
    cell.path = indexPath;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cell.frame.size.height;
}
@end
