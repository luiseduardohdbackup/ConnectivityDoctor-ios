//
//  GroupCell.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/14/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DACircularProgressView;
@class MKNumberBadgeView;


@interface GroupCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameDetailLabel;
@property (nonatomic, weak) IBOutlet DACircularProgressView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *finishedView;



-(void) networkTestForGroup : (NSString *) name;
@property (nonatomic) NSIndexPath * path;
@end




