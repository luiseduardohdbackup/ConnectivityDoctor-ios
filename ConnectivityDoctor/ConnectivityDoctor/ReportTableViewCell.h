//
//  ReportTableViewCell.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/9/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportTableViewCell : UITableViewCell
//cells
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *testResult;

@property (nonatomic, weak) IBOutlet UIImageView *finishedView;
@property (weak, nonatomic) IBOutlet UILabel *messageDetail;
@property (weak, nonatomic) IBOutlet UILabel *message;

@property (nonatomic) NSIndexPath * path;



@end
