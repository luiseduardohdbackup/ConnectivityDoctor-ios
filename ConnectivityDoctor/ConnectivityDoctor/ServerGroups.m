//
//  ServerGroups.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/18/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ServerGroups.h"

static NSString * const kConnected = @"connected";
static NSString * const kURL = @"url";
static NSString * const kGenericURL = @"generic_url";
static NSString * const kPort = @"port";
static NSString * const kProtocol = @"protocol";




@interface ServerGroups()
@property (nonatomic) NSMutableDictionary * serversGroupStore;
@end

@implementation ServerGroups

+(ServerGroups *) sharedInstance
{
    static ServerGroups * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ServerGroups new];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.serversGroupStore = [NSMutableDictionary new];
        
    }
    return self;
}
#pragma mark JSON
-(void) initWithJSON : (NSData  *) data
{
    NSDictionary * info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary * groupsJSON = [info objectForKey:@"servers"];
    
    //iterate through all groups to fill up group names

    
    for (NSString* group in groupsJSON) {
 
        NSDictionary * groupInfo = [groupsJSON objectForKey:group];
        NSArray * tests = [groupInfo objectForKey:@"tests"];
        NSArray * urls = [groupInfo objectForKey:@"urls"];
        NSMutableArray * hostList = [NSMutableArray new];
  
        for (NSDictionary * url in urls) {
            for (NSDictionary * test in tests) {
                
                NSArray *ports = [[test objectForKey:@"range"] componentsSeparatedByString:@","];
                
                for (NSString * port in ports) {
                    NSMutableDictionary * hostToBeAdded = [NSMutableDictionary new];
                    NSString * genericURL = [groupInfo objectForKey:kGenericURL];
                    [hostToBeAdded setObject:genericURL?genericURL:url forKey:kURL];
                    [hostToBeAdded setObject:@"NO" forKey:kConnected];
                    [hostToBeAdded setObject:port forKey:kPort];
                    [hostToBeAdded setObject:[test objectForKey:@"protocol"] forKey:kProtocol];
                    [hostList addObject:hostToBeAdded];
                }
            }
            
        }
        
        [self.serversGroupStore setObject:hostList forKey:group];
    }

}

#pragma mark Public
//name of groups in no particular order
-(NSArray *) groupNames
{
    NSMutableArray * a = [NSMutableArray new];
    for (NSString * group in self.serversGroupStore) {
        [a addObject:group];
    }
    return a;
}
//array of NSDictionary with host info
-(NSArray *) hostsForGroup : (NSString *) groupName
{
    return [self.serversGroupStore objectForKey:groupName];
}
//set connected flag
-(void) markConnectedStatusOfGroup : (NSString *) groupName hostURL:(NSString *)hosturl port:(NSString*) p flag:(BOOL) f
{
    NSArray * hosts = [self.serversGroupStore objectForKey:groupName];
    for (NSDictionary * host in hosts) {
        NSString * url = [host objectForKey:kURL];
        NSString * port = [host objectForKey:kPort];
        if([url isEqualToString:hosturl] && [port isEqualToString:p])
        {
            [host setValue:f?@"YES":@"NO" forKey:kConnected];
        }
    }
}
-(void) resetAllConnections
{
    for (NSDictionary * group in self.serversGroupStore) {
        NSArray * hosts = [self.serversGroupStore objectForKey:group];
        for (NSDictionary * host in hosts) {
            [host setValue:@"NO" forKey:kConnected];
        }

    }
    
}
@end
