//
//  MasterViewController.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/3/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController 
@property (strong, nonatomic) DetailViewController *detailViewController;



@end
