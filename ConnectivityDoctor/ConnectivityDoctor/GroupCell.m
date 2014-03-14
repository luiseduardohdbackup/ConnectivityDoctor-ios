//
//  GroupCell.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/14/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()
@property (strong, nonatomic) NSTimer *timer;
@property float progress;
@end

@implementation GroupCell
-(void) awakeFromNib
{

    [self startAnimation];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark TimerChecks
- (void)progressChange
{
    self.progressView.roundedCorners = NO;
    //self.progressView.trackTintColor = [UIColor brownColor];
    self.progressView.progressTintColor = [UIColor blackColor];
    self.progressView.thicknessRatio = 1.0f;
    self.progressView.clockwiseProgress = NO;

    if(self.progress >= 1.0) self.progress = 0.0f;
    else self.progress += 0.1;
    [self.progressView setProgress:self.progress];

    
}
- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                 repeats:YES];
    
}



@end
