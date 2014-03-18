//
//  WelcomeViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ServerGroups.h"

@interface WelcomeViewController ()
@property (nonatomic) ServerGroups * servers;
@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.servers = [ServerGroups sharedInstance];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://sup301-sat.tokbox.com/dynamicTestConfig.json"]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:10];
    [urlRequest setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if ([data length] > 0 && error == nil) {
             [self.servers initWithJSON:data];
             NSArray * groups = [self.servers groupNames];
             for (NSString * group in groups) {
                 NSArray * hostList = [self.servers hostsForGroup:group];
                 for (NSDictionary * host in hostList) {
                     [self.servers markConnectedStatusOfGroup:group hostURL:[host objectForKey:@"url"] port:@"3478" flag:YES];
                     NSLog(@"%@",host);
                 }
             }
             [self.servers resetAllConnections];
             for (NSString * group in groups) {
                 NSArray * hostList = [self.servers hostsForGroup:group];
                 for (NSDictionary * host in hostList) {
                    
                     NSLog(@"%@",host);
                 }
             }

         }
         else if ([data length] == 0 && error == nil)
             NSLog(@"NTWK:got no data");
         else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"NTWK:timeout");
         else if (error != nil)
             NSLog(@"NTWK:error %@",error.description);
     }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToWelcome:(UIStoryboardSegue *)segue {
    
}

@end
