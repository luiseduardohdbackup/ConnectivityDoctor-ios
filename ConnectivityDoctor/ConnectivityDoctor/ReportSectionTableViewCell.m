//
//  ReportSectionTableViewCell.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/5/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ReportSectionTableViewCell.h"
#import "Utils.h"



@implementation ReportSectionTableViewCell

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
    //fonts for labels
    [self.title setFont:[UIFont fontWithName:@"Muli"size:14.0f]];
    [self.date setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    self.title.text = kUtils_ReportHeaderText;
    self.date.text = [Utils date_HH_AP_MM_DD_YYYY];
   

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
