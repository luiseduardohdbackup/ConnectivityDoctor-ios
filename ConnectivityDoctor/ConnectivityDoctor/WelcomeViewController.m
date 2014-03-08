//
//  WelcomeViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

    [self startNetworkOperation];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToWelcome:(UIStoryboardSegue *)segue {
    
}

#pragma mark Network
-(void) startNetworkOperation
{
 
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://sup301-sat.tokbox.com/dynamicTestConfig.json"]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:10];
    [urlRequest setHTTPMethod: @"GET"];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ([data length] > 0 && error == nil) {
            NSDictionary * info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary * servers = [info objectForKey:@"servers"];
            
            NSManagedObject * newManagedObject;
            int i =0;
            for (NSString* key in servers) {
                
                newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"DiagnosticGroup"
                                                                 inManagedObjectContext:self.managedObjectContext];
                [newManagedObject setValue:@(i++) forKey:@"type"];
                [newManagedObject setValue:key forKey:@"name"];
            }
            
            NSLog(@"%@",servers);
        }
        
        else if ([data length] == 0 && error == nil)
             NSLog(@"NTWK:got no data");
        else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"NTWK:timeout");
        else if (error != nil)
             NSLog(@"NTWK:error %@",error.description);
    }];
}
@end
