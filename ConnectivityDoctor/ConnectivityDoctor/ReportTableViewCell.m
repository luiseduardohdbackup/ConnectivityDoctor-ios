//
//  ReportTableViewCell.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/9/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ReportTableViewCell.h"
#import "ServerGroups.h"

@interface ReportTableViewCell()
@property float progress;
@property (nonatomic) ServerGroups * serverGroupStore;
@end

@implementation ReportTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
     self.serverGroupStore = [ServerGroups sharedInstance];
    
    //fonts for labels
    [self.nameLabel setFont:[UIFont fontWithName:@"Muli"size:14.0f]];
    [self.nameDetailLabel setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    [self.testResult setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    [self.message setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    [self.messageDetail setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    
    //default to non red
    
    [self.messageDetail setTextColor:[UIColor colorWithRed:178.0/255 green:89.0/255 blue:0.0/255 alpha:1 ]];
    
    //red color
   // [self.testResult setTextColor:[UIColor colorWithRed:193.0/255 green:27.0/255 blue:23.0/255 alpha:1 ]];
    

    
}

-(void) setPath: (NSIndexPath *)indexPath
{
    NSArray * groupNames = [self.serverGroupStore groupLabels];
    
    NSDictionary * dict = groupNames[indexPath.row];
    NSString* groupName = [dict objectForKey:SGName];
    
    self.nameLabel.text = groupName;
    self.nameDetailLabel.text = [dict objectForKey:SGDescription];
    [self.nameDetailLabel sizeToFit];
    
    
    SGFinishedStatus status = [self.serverGroupStore groupFinishedStatus:[dict objectForKey:SGJSONName]];
    
    if ((status == SGAllHostsConnected) || (status == SGSomeHostConnected))
    {
        [self.finishedView setImage:[UIImage imageNamed:@"connected"]];
        self.messageDetail.text = [dict objectForKey:SGResultSuccess];

    } else if(status == SGAllHostsFailed)
    {
        [self.finishedView setImage:[UIImage imageNamed:@"notConnected"]];
        self.messageDetail.text = [dict objectForKey:SGErrorMessage];
        
    }
    else if(status == SGAllHostsSomeConnectedAndSomeFailed)
    {
        [self.finishedView setImage:[UIImage imageNamed:@"unknown"]];
        self.messageDetail.text = [dict objectForKey:SGWarningSecure];
    }
    
    
    [self.messageDetail sizeToFit];

    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
