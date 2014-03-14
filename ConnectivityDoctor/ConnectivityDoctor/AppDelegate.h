//
//  AppDelegate.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *uiManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *bgManagedObjectContext;


- (void)saveContext;


@end
