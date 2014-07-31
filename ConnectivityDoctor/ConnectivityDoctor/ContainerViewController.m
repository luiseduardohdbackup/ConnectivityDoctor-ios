//
//  ContainerViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/17/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ContainerViewController.h"
#import "MasterViewController.h"
#import "ServerGroups.h"
#import "Utils.h"

@interface ContainerViewController () <UIAlertViewDelegate>
@property (nonatomic) ServerGroups * servers;
@property (nonatomic) MasterViewController * masterController;
@end

@implementation ContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



// https://dashboard.tokbox.com/get_server_list
// http://sup301-sat.tokbox.com/dynamicTestConfig.json

-(void) fetchServerListFromNetworkAndStore
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://dashboard.tokbox.com/get_server_list"]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:10];

    
    [urlRequest setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if ([data length] > 0 && error == nil) {
             
             //NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             [self.servers initWithJSON:data];

             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //TODO - the network tests are embedded in GroupCell and this gets activated when the cell is visible.
                 // This is bad design . Better to have all the tests done independently and have the UI pick them up
                 // For now because we have 4 cells , the scroll to bottom works ok in older 3 inch devices. 
                 [self.masterController.tableView reloadData];
                 [self.masterController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

                 [self.masterController.tableView setNeedsDisplay];
             });

             
         }
         else if ([data length] == 0 && error == nil)
         {
             [self showRetryAlertWithTitle:@"Tokbox server error" message:@"Please try after some time."];
         }
             
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             [self showRetryAlertWithTitle:@"Network timed out" message:@"Please try after some time."];

         }
         else if (error != nil)
         {
            [self showRetryAlertWithTitle:@"Network connection not found" message:@"Enable network connection."];
         }

     }];
    
 
}


-(MasterViewController *) masterController
{
    if(_masterController == nil)
    {
 
        if([self.childViewControllers[0] isKindOfClass:[MasterViewController class]])
        {
            _masterController = (MasterViewController *) self.childViewControllers[0];
            
        } else {
            assert(0);
        }

        
    }
    return _masterController;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.servers = [ServerGroups sharedInstance];
    [self refresh:nil];

}
-(void) viewDidDisappear:(BOOL)animated
{
    [self.servers removeObserver:self forKeyPath:@"areAllGroupsFinished"];
}

-(void) viewDidAppear:(BOOL)animated
{
 
    [self.servers addObserver:self
               forKeyPath:@"areAllGroupsFinished"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:nil];
  
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"areAllGroupsFinished"])
    {
        BOOL old = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
        BOOL new = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if(!(old == NO && new == YES)) return;

        if(self.servers.areAllGroupsFinished)
        {
            [self resultsPost];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.servers.areAllGroupsFinished)
            {
                self.runTestAgain.enabled = YES;
                self.seeReport.enabled = YES;
            }


        });
    }
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
   
    self.runTestAgain.enabled = NO;
    self.seeReport.enabled = NO;
   
    [self fetchServerListFromNetworkAndStore];
}

#pragma mark POST results
//Right now we just send the date and device name to the logging data base .
// We could send the hosts connected status later on by using ServerGroup jsonString

-(void) resultsPost
{
    // post string creation
    
    NSString * data = [NSString stringWithFormat:@"Connectivity Doctor [%@] device=%@",[NSDate date],[[UIDevice currentDevice] name]];
    
    data = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                  (CFStringRef) data,
                                                                                  NULL,
                                                                                  (CFStringRef) @"!*'();@+$,/?%#[]_",
                                                                                  kCFStringEncodingUTF8));
    //printf("%s\n",[data UTF8String]);
    
    //url creation
    NSURL *url = [NSURL URLWithString:@"http://hlg.tokbox.com/prod/logging/ClientEvent"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Basic aW9zdXNlckB0b2tib3guY29tOnQwa2IweCEh" forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    


    // just post , response check not needed
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
//         NSHTTPURLResponse * r = (NSHTTPURLResponse*) response;
//         NSLog(@"POST response=%ld",(long)r.statusCode);
//         NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
     }];
     

    
    
}

- (void)showRetryAlertWithTitle:(NSString *)t message:(NSString *) m
{
    // show alertview on main UI
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:t
                                                        message:m
                                                       delegate:self
                                              cancelButtonTitle:@"Retry"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self fetchServerListFromNetworkAndStore];
}
@end
