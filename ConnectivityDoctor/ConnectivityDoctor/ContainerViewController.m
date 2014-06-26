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

@interface ContainerViewController ()
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
                 [self.masterController.tableView reloadData];
                 [self.masterController.tableView setNeedsDisplay];
             });

             
         }
         else if ([data length] == 0 && error == nil)
         {
             [Utils showAlert:@"Could not fetch valid data"];
         }
             
         else if (error != nil && error.code == NSURLErrorTimedOut)
         {
             [Utils showAlert:@"Could not fetch the list of servers.Try again after making sure that the network connection is present"];
         }
         else if (error != nil)
         {
            [Utils showAlert:@"Could not fetch the list of servers.Try again after making sure that the network connection is present"];
            NSLog(@"Network error : %@", error.description);
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
          //  [self resultsPost];
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
-(void) resultsPost
{
    // post string creation
    
    NSString * data = [NSString stringWithFormat:@"report=%@",[self.servers jsonString]];
    
    data = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                  (CFStringRef) data,
                                                                                  NULL,
                                                                                  (CFStringRef) @"!*'();@+$,/?%#[]_",
                                                                                  kCFStringEncodingUTF8));
    //printf("%s\n",[data UTF8String]);
    
    //url creation
    NSURL *url = [NSURL URLWithString:@"https://dashboard-dev.tokbox.com/send_reports"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Basic aW9zdXNlckB0b2tib3guY29tOnQwa2IweCEh" forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
    


    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSHTTPURLResponse * r = (NSHTTPURLResponse*) response;
         
         NSLog(@"POST response=%ld",(long)r.statusCode);
         //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
     }];
     

    
    
}


@end
