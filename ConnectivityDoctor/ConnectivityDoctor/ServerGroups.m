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
    self.serversGroupStore = [NSMutableDictionary new];

    NSDictionary * info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary * groupsJSON = [info objectForKey:@"servers"];
    
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
    return [[self.serversGroupStore objectForKey:groupName]copy] ;
}
-(BOOL) allHostsChecked
{
    for (NSString * groupName in [self groupNames]) {
        
        NSArray * hosts = [self.serversGroupStore objectForKey:groupName];
        for (NSDictionary * host in hosts) {
            NSString * val = [host objectForKey:kHostChecked];
            
            if([val isEqualToString:@"NO"]) return NO;
        }
        
    }
 
    return YES;
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
        }
    }
}

@end
