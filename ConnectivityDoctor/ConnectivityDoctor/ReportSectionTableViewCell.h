//
//  ReportSectionTableViewCell.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/5/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportSectionTableViewCell : UITableViewCell
//section header
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
