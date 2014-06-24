//
//  Utils.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/16/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "Utils.h"
NSString * const kUtils_ReportHeaderText = @"Network diagnostic report";

@implementation Utils

+(NSString *) date_HH_AP_MM_DD_YYYY
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
    // [df setDateFormat:@"ss"];
    // NSString* mySecondString = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    //am or pm
    [df setDateFormat:@"a"];
    NSString* myAmPm = [NSString stringWithFormat:@"%@", [df stringFromDate:currDate]];
    
    return [NSString stringWithFormat:@"%@:%@ %@ %@ %@,%@",myHourString,myMinuteString,myAmPm,myMonthString,myDayString,myYearString];
}

+ (void)showAlert:(NSString *)string
{
    // show alertview on main UI
	dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connectivity Doctor"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}


@end
