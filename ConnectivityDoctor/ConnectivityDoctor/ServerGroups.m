//
//  ServerGroups.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/18/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "ServerGroups.h"

NSString * const kConnected = @"connected";
NSString * const kURL = @"url";
NSString * const kPort = @"port";
NSString * const kProtocol = @"protocol";

static NSString * const kGenericURL = @"generic_url";
// YES if connectivity test was done. NO if no test were done
static NSString * const kHostChecked = @"hostChecked";

NSString * const SGJSONName = @"jsonName";
NSString * const SGName = @"name";
NSString * const SGDescription = @"description";
NSString * const SGErrorMessage = @"errorMessage";
NSString * const SGOKMessage = @"okMessage";


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
-(NSMutableDictionary *) massageToFixRestGETServerListShortComings : (NSMutableDictionary *) groupsJSON
{
    //fix anvil protocols tcp to http and https
    NSMutableDictionary * groupInfo = [[groupsJSON objectForKey:@"anvil"] mutableCopy];
    NSString * host = [groupInfo objectForKey:@"generic_url"];
    if([host isEqualToString:@"anvil.opentok.com"])
    {
//        [groupInfo setValue:@"anvil.opentok.com/session/2_MX4xMDB-flR1ZSBOb3YgMTkgMTE6MDk6NTggUFNUIDIwMTN-MC4zNzQxNzIxNX4?" forKey:@"generic_url"];
        [groupInfo setValue:@"anvil.opentok.com/session/some_junk_id_2_MX4xMDB-flR1ZSBOb3YgMTkgMTE6MDk6NTggUFNUIDIwMTN-MC4zNzQxNzIxNX4?" forKey:@"generic_url"];

    }
    [groupInfo removeObjectForKey:@"tests"];
    [groupInfo setValue:@[@{@"protocol": @"http", @"range" : @"80"},
                          @{@"protocol": @"https",@"range" : @"443"}]
                 forKey:@"tests"];
    [groupsJSON setValue:groupInfo forKey:@"anvil"];
    
   

    
    //fix hlg logging to http
    groupInfo = [[groupsJSON objectForKey:@"logging"]mutableCopy] ;
    host = [groupInfo objectForKey:@"generic_url"];
    if([host isEqualToString:@"hlg.tokbox.com"])
    {

        [groupInfo setValue:@"hlg.tokbox.com/heartbeat" forKey:@"generic_url"];
        
    }

    [groupInfo removeObjectForKey:@"tests"];
    [groupInfo setValue:@[@{@"protocol": @"http", @"range" : @"80"},
                          @{@"protocol": @"https",@"range" : @"443"}]
                 forKey:@"tests"];

    [groupsJSON setValue:groupInfo forKey:@"logging"];
    
    //remove oscar
    [groupsJSON removeObjectForKey:@"oscar"];


    //return
   
    return groupsJSON;
}
-(void) initWithJSON : (NSData  *) data
{
    self.serversGroupStore = [NSMutableDictionary new];

    NSMutableDictionary * info = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] mutableCopy];
    NSMutableDictionary * groupsJSON = [[info objectForKey:@"servers"] mutableCopy];
    
    //massage to correct
    groupsJSON = [self massageToFixRestGETServerListShortComings:groupsJSON];
    
    //iterate through all groups to fill up group names

    
    for (NSString* group in groupsJSON) {
 
        //localized test - REMOVE
        //if([group isEqualToString:@"anvil"] == NO) continue;
        //end localized test
        
        NSDictionary * groupInfo = [groupsJSON objectForKey:group];
        NSArray * tests = [groupInfo objectForKey:@"tests"];
        NSArray * urls = [groupInfo objectForKey:@"urls"];
        NSMutableArray * hostList = [NSMutableArray new];
        NSString * genericURL = [groupInfo objectForKey:kGenericURL];
        BOOL avoidURLIfGenericURLPresent = NO;
        
        for (NSString * url in urls) {
            if(avoidURLIfGenericURLPresent) continue;
            for (NSDictionary * test in tests) {
                
                NSArray *ports = [[test objectForKey:@"range"] componentsSeparatedByString:@","];
                
                for (NSString * port in ports) {
                    NSMutableDictionary * hostToBeAdded = [NSMutableDictionary new];
                    
                    NSString * urlToAdd ;
                    if ([url rangeOfString:@".tokbox.com"].length > 0) {
                        urlToAdd = url;
                    } else {
                        urlToAdd = [url stringByAppendingString:@".tokbox.com"];
                    }
                    [hostToBeAdded setValue:@"NO" forKey:kConnected];
                    [hostToBeAdded setValue:@"NO" forKeyPath:kHostChecked];
                    [hostToBeAdded setObject:genericURL?genericURL:urlToAdd forKey:kURL];
                    [hostToBeAdded setObject:port forKey:kPort];
                    [hostToBeAdded setObject:[test objectForKey:@"protocol"] forKey:kProtocol];
                    [hostList addObject:hostToBeAdded];
                }
            }
            avoidURLIfGenericURLPresent = (genericURL != nil);
        }
        avoidURLIfGenericURLPresent = NO;
        [self.serversGroupStore setObject:hostList forKey:group];
    }
    self.areAllHostsChecked = NO;
    self.areAllGroupsChecked = NO;
}
- (NSString *) jsonString
{
    
    
    NSString * jsonString = @"{\"ConnectivityDoctorServerCheckedReport\":{\"servers\":{";
    for (NSString * group in self.serversGroupStore) {
        jsonString = [[[jsonString  stringByAppendingString:@"\""]
                       stringByAppendingString:group]
                      stringByAppendingString:@"\":["];
        
        //protcol outer loop
        //protocols
        NSArray * hostList = [self.serversGroupStore objectForKey:group];
        for(NSDictionary* host in hostList)
        {
            jsonString = [jsonString stringByAppendingString:@"{\"protocol\":\""];
            jsonString = [[jsonString stringByAppendingString:[host objectForKey:kProtocol]]
                          stringByAppendingString:@"\","];
            jsonString = [[[jsonString  stringByAppendingString:@"\"port\":\""]
                           stringByAppendingString:[host objectForKey:kPort]]
                          stringByAppendingString:@"\","];
            jsonString = [[[jsonString  stringByAppendingString:@"\"url\":\""]
                           stringByAppendingString:[host objectForKey:kURL]]
                          stringByAppendingString:@"\","];
            
            
            jsonString = [[[jsonString  stringByAppendingString:@"\"status\":\""]
                           stringByAppendingString:[host objectForKey:kConnected]]
                          stringByAppendingString:@"\"},"];
            

            
        }
        //remove the last comma
        jsonString = [jsonString substringToIndex:[jsonString length]-1];
        jsonString = [jsonString stringByAppendingString:@"],"];
        
    }
    //remove the last comma
    jsonString = [jsonString substringToIndex:[jsonString length]-1];
    // put check date and end everything
    jsonString = [jsonString stringByAppendingString:@"},\"checkedAt\":\""];
    
//    NSString * date =  [NSDateFormatter localizedStringFromDate:[NSDate date]
//                                                      dateStyle:NSDateFormatterShortStyle
//                                                      timeStyle:NSDateFormatterLongStyle];
    jsonString = [jsonString stringByAppendingString:[self getUTCFormateCurrentDate]];
    jsonString = [jsonString stringByAppendingString:@"\","];
    
    //mail recipients
     jsonString = [jsonString stringByAppendingString:@"\"emails\":["];
    jsonString = [jsonString stringByAppendingString:@"\"a@b.com\""];
     jsonString = [jsonString stringByAppendingString:@"]"];
    
    jsonString = [jsonString stringByAppendingString:@"}}"];
    
    
    return jsonString;
}


-(NSString *)getUTCFormateCurrentDate
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS.SSS'Z'"];
    return [dateFormatter stringFromDate:[NSDate date]];

}
#pragma mark Public
//Each element of the array is an NSDictionary with keys as follows:
// name , description , errorMessage, okMessage
// The display order is maintained in the NSArray

-(NSArray *) groupLabels
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.serversGroupStore.count; ++i)
    {
        [a addObject:[NSNull null]];
    }

 
    for (NSString * group in self.serversGroupStore) {
       
        if([group isEqualToString:@"anvil"])
        {
 
            a[0] = @{@"order":@"1",
                     SGJSONName:group,
                     SGName: @"API Server",
                     SGDescription:@"Connect to the OpenTok API servers.",
                     SGErrorMessage:@"Potential issues,info to fix. This is a big issue and you should contact your administrator and fix it otherwise unknown things will happen in your inbox.",
                     SGOKMessage:@"Succesful."};
        }
        else if([group isEqualToString:@"mantis"])
        {
            
            a[1] = @{@"order":@"2",
                     SGJSONName:group,
                     SGName: @"Media Router",
                     SGDescription:@"Verifying multi-party calls,messaging,and the ability to archive.",
                     SGErrorMessage:@"Please contact your administrator to grant access to ports 3478,443 and UDP ports 1025-65535.",
                     SGOKMessage:@"Succesful."};
        } else if([group isEqualToString:@"turn"])
        {
            
            a[2] = @{@"order":@"3",
                     SGJSONName:group,
                     SGName: @"Mesh TURN Server",
                     SGDescription:@"Mesh calls with relay server fallback.",
                     SGErrorMessage:@"Potential issues,info to fix. This is a big issue and you should contact your administrator and fix it otherwise unknown things will happen in your inbox.",
                     SGOKMessage:@"Succesful."};
        } else if([group isEqualToString:@"logging"])
        {
            
            a[3] = @{@"order":@"4",
                     SGJSONName:group,
                     SGName: @"LoggingServer",
                     SGDescription:@"Connect to the OpenTok API servers.",
                     SGErrorMessage:@"Potential issues,info to fix. This is a big issue and you should contact your administrator and fix it otherwise unknown things will happen in your inbox.",
                     SGOKMessage:@"Succesful."};
        }

    }
    return a;
}


//array of NSDictionary with host info
-(NSArray *) hostsForGroup : (NSString *) groupName
{
    return [[self.serversGroupStore objectForKey:groupName]copy] ;
}


-(BOOL) allHostsChecked
{
    for (NSDictionary * dict in [self groupLabels]) {
        NSString * groupName = [dict objectForKey:SGJSONName];
        NSArray * hosts = [self.serversGroupStore objectForKey:groupName];
        for (NSDictionary * host in hosts) {
            NSString * val = [host objectForKey:kHostChecked];
            
            if([val isEqualToString:@"NO"]) return NO;
        }
        
    }
 
    return YES;
}

-(BOOL) allGroupsChecked
{
    BOOL allGroups = YES;

    
    for (NSDictionary * dict in [self groupLabels]) {
        
        allGroups = allGroups & [self connectedAnyWithinGroup:[dict objectForKey:SGJSONName]];
        if(allGroups == NO) break;
        
    }
    
    return allGroups;
}

//return a BOOL if any host whithin the given group got thru the firewll
-(BOOL) connectedAnyWithinGroup : (NSString *) groupname
{
    NSArray * hosts = [self.serversGroupStore objectForKey:groupname];
    for (NSDictionary * host in hosts) {
        if([[host objectForKey:kConnected] isEqualToString:@"YES"])
        {
            return YES;
        }
    }
    return NO;
    
    
}
//set connected flag
-(void) markConnectedStatusOfGroup : (NSString *) groupName hostURL:(NSString *)hosturl port:(NSString*) p flag:(BOOL) f
{

    NSArray * hosts = [self.serversGroupStore objectForKey:groupName];
    for (NSDictionary * host in hosts) {

        if([[host objectForKey:kURL] isEqualToString:hosturl] && [[host objectForKey:kPort] isEqualToString:p])
        {

            [host setValue:f?@"YES":@"NO" forKey:kConnected];
            [host setValue:@"YES" forKey:kHostChecked];
            self.areAllHostsChecked = [self allHostsChecked];
            self.areAllGroupsChecked = [self allGroupsChecked];
        }
    }
}

@end
