//
//  Utils.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 6/16/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

extern NSString * const kUtils_ReportHeaderText ;

@interface Utils : NSObject
+ (NSString *) date_HH_AP_MM_DD_YYYY;
+ (NSString *) decodeJWT : (NSString *) jwt withKey : (NSString*) key;
@end
