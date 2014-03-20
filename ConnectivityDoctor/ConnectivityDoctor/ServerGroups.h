//
//  ServerGroups.h
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/18/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const kConnected ;
extern NSString * const kURL ;
extern NSString * const kGenericURL ;
extern NSString * const kPort ;
extern NSString * const kProtocol ;
extern NSString * const kHostCount ;
extern NSString * const kHostCheckedCount;

@interface ServerGroups : NSObject

@property (nonatomic, readonly) NSArray * groupNames;

+(ServerGroups *) sharedInstance;

//designated init
-(void) initWithJSON : (NSData  *) data;

//name of groups in no particular order
-(NSArray *) groupNames;
//array of NSDictionary with host info
-(NSArray *) hostsForGroup : (NSString *) groupName;
//set connected flag
-(void) markConnectedStatusOfGroup : (NSString *) groupName hostURL:(NSString *)hosturl port:(NSString*) p flag:(BOOL) f;
//reset all connections
-(void) resetAllConnections;

@end
