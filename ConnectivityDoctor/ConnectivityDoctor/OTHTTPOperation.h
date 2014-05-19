//
//  OTHTTPOperation.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 5/8/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTConnectivityBaseOperation.h"

@interface OTHTTPOperation : OTConnectivityBaseOperation
// Designated initializer. The host is a DNS name.
// The default init method is not to be used. Will return an exception, if used.
// This operation is concurrent in nature
// If postAction is NO , we default to GET
-(id) initWithHost:(NSString*) host port:(NSInteger) port timeout:(NSTimeInterval)time https:(BOOL)https;


@end
