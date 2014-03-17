//
//  JSONParser.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/10/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kGroupEntity ;
extern NSString * const kGroupEntity_Name ;
extern NSString * const kGroupEntity_HostCount ;
extern NSString * const kGroupEntity_HostCheckedCount ;
@interface JSONParser : NSObject

// Gets the server list in JSON from tokbox server, parses it and stores it in Core data.
// If the http GET call is successful only then is the core data cleared and the new entries populated
// If GET fails the old core data entries are left s it is.
// The checked at attribute in the Server Entity reflects this.
- (void) serversList;

// Returns a JSON string which has the status of the network checks.
- (NSString *) report;
@end
