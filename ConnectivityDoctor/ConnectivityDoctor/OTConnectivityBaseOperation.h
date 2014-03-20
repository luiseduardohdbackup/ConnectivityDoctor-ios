//
//  OTConnectivityBaseOperation.h
//  OpenTokServersConnectivity
//
//  Created by Jaideep Shah on 2/7/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTConnectivityBaseOperation : NSOperation

//On completion of the operation, this value can be tested to check if the connection was successful or not
@property  BOOL connected;


@end
