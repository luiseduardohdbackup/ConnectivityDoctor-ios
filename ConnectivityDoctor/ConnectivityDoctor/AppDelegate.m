//
//  AppDelegate.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
@interface AppDelegate()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeApperance];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark Customize apperance
-(void) customizeApperance
{
  
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
    

    UIColor * colorFg = [[UIColor alloc] initWithHue:102.0/256.0 saturation:102.0/256.0 brightness:102.0/256.0 alpha:1.0];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: colorFg,
                                                            NSFontAttributeName: [UIFont fontWithName:@"Muli" size:18.0f]
                                                          
                                                            }];
    
  //   [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
  //   [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];


    
}
@end
