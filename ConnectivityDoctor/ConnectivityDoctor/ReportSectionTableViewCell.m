//
//  ReportSectionTableViewCell.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/5/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ReportSectionTableViewCell.h"

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
    [self dateFillup];

}
-(void) dateFillup
{
    NSDate *currDate = [NSDate date];   //Current Date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    //Day
    [df setDateFormat:@"dd"];
    NSString* myDayString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    //Month
    [df setDateFormat:@"MMM"]; //MM will give you numeric "03", MMM will give you "Mar"
    NSString* myMonthString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    //Year
    [df setDateFormat:@"yyyy"];
    NSString* myYearString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    //Hour
    [df setDateFormat:@"hh"];
    NSString* myHourString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    //Minute
    [df setDateFormat:@"mm"];
    NSString* myMinuteString = [NSString stringWithFormat:@"%@",[df stringFromDate:currDate]];
    
    //Second
    [df setDateFormat:@"ss"];
    NSString* mySecondString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    //am or pm
    [df setDateFormat:@"a"];
    NSString* myAmPm = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];

    
    self.date.text = [NSString stringWithFormat:@"%@:%@ %@ %@ %@,%@",myHourString,myMinuteString,myAmPm,myMonthString,myDayString,myYearString];
    NSLog(@"Year: %@, Month: %@, Day: %@, Hour: %@, Minute: %@, Second: %@ ampm:%@", myYearString, myMonthString, myDayString, myHourString, myMinuteString, mySecondString,myAmPm);
 
    return;
    
    
    self.date.text = [[NSDate new] descriptionWithLocale:[NSLocale systemLocale]];
    return;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm";

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    self.date.text = [dateFormatter stringFromDate:[NSDate date]];
 
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
