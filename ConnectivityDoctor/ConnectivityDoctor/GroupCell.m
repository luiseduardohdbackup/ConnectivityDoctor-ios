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
@property float hostTotalCount;
@property float hostCheckedCount;
@end

@implementation GroupCell
-(void) awakeFromNib
{
    self.hostCheckedCount = 0.0f;


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
-(void) incrementHostCheckedCount
{
//        [self.managedObject setValue:[NSString stringWithFormat:@"%f",self.hostCheckedCount++] forKey:kGroupEntity_HostCheckedCount];
    
}
- (void)progressChange
{

    
    self.progressView.roundedCorners = NO;
 
   
    self.progressView.trackTintColor = [UIColor redColor];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 1.0f;
    self.progressView.clockwiseProgress = YES;


  //  self.hostTotalCount = [[self.managedObject valueForKey:kGroupEntity_HostCount] floatValue];
    

    self.progressView.progress = self.hostCheckedCount/self.hostTotalCount;
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.progressView.progress * 100];
    
//    if(self.progress >= 1.0) self.progress = 0.0f;
//    else self.progress += 0.1;
//    [self.progressView setProgress:self.progress];

    
}
- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(incrementHostCheckedCount)
                                                userInfo:nil
                                                 repeats:YES];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self progressChange];
}
@end
