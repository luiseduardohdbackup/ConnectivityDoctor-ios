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

+ (NSString *) decodeJWT : (NSString *) jwt withKey:(NSString *)key
{
    NSArray *segments = [jwt componentsSeparatedByString:@"."];
    NSString *base64String = [segments objectAtIndex: 1];
    //NSLog(@"%@", base64String);
    
    int requiredLength = (int)(4 * ceil((float)[base64String length] / 4.0));
    int nbrPaddings = requiredLength - [base64String length];
    
    if (nbrPaddings > 0) {
        NSString *padding =
        [[NSString string] stringByPaddingToLength:nbrPaddings
                                        withString:@"=" startingAtIndex:0];
        base64String = [base64String stringByAppendingString:padding];
    }
    
    base64String = [base64String stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    
    NSData *decodedData =
    [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    NSString *decodedString =
    [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSLog(@"JWT decoded stuff - %@", decodedString);
    
    
    return  decodedString;
}
@end
