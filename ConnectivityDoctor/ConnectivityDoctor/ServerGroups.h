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
extern NSString * const kPort ;
extern NSString * const kProtocol ;
extern NSString * const kSecured;
extern NSString * const kHostChecked;

extern NSString * const SGJSONName;
extern NSString * const SGName;
extern NSString * const SGDescription;
extern NSString * const SGResultSuccess;
extern NSString * const SGResultError;
extern NSString * const SGResultWarning;
extern NSString * const SGErrorMessage;
extern NSString * const SGWarningSecure;
extern NSString * const SGWarningNonSecure;


typedef NS_ENUM(NSUInteger, SGFinishedStatus)
{
    SGNotFinished,
    SGAllHostsConnected,
    SGAllHostsFailed,
    SGAllHostsSomeConnectedAndSomeFailed,  //some failed, some connected
    SGSomeHostConnected,
};

@interface ServerGroups : NSObject

// use this as a KVO to change UI elements
@property (nonatomic) BOOL areAllHostsChecked;
@property (nonatomic) BOOL areAllGroupsFinished;

+(ServerGroups *) sharedInstance;

//designated init.
//If you want to retry , start with this method again , for now
-(void) initWithJSON : (NSData  *) data;
//the output json string which can be POSTed to a logging server.
-(NSString *) jsonString;

//Each element of the array is an NSDictionary with keys as follows:
// name , description , errorMessage, okMessage
// The display order is maintained in the NSArray
-(NSArray *) groupLabels;

//array of NSDictionary with host info
-(NSArray *) hostsForGroup : (NSString *) groupName;

//set connected flag.
-(void) markConnectedStatusOfGroup : (NSString *) groupName hostURL:(NSString *)hosturl port:(NSString*) p flag:(BOOL) f secured:(BOOL) secure;

// return SGFinishedStatus
-(SGFinishedStatus) groupFinishedStatus : (NSString *) groupName;

// a value between 0 and 1 indicating percentage of hosts checked.
//The host can be connected or not.
-(CGFloat) groupProgress : (NSString *) groupName;

@end
