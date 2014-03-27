//
//  GroupCell.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/14/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DACircularProgressView;


@interface GroupCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *completionImage;
@property (nonatomic, weak) IBOutlet DACircularProgressView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *finishedView;

-(void) networkTestForGroup : (NSString *) name;
@end

@protocol GroupCellDelegate <NSObject>



@end


