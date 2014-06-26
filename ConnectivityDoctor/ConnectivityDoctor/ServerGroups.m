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
NSString * const SGResultSuccess = @"results_success";
NSString * const SGResultError = @"results_error";
NSString * const SGResultWarning = @"results_warning";
NSString * const SGErrorMessage = @"errorMessage";
NSString * const SGWarningSecure = @"warning_secure";
NSString * const SGWarningNonSecure = @"warning_non_secure";




@interface ServerGroups()
// This contains all the hosts for a particular group. The host are massaged out of the
@property (nonatomic) NSMutableDictionary * groupHosts;
//This contains all the Display Strings for name, description,result,error and warnings of a group.
@property (nonatomic) NSMutableDictionary * groupDisplays;

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
        self.groupHosts = [NSMutableDictionary new];
        self.groupDisplays = [NSMutableDictionary new];
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
    



    //return
   
    return groupsJSON;
}
-(void) initWithJSON : (NSData  *) data
{
    self.groupHosts = [NSMutableDictionary new];
    self.groupDisplays = [NSMutableDictionary new];

    NSMutableDictionary * info = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil] mutableCopy];
    NSMutableDictionary * groupsJSON = [[info objectForKey:@"servers"] mutableCopy];
    
    //massage to correct
    groupsJSON = [self massageToFixRestGETServerListShortComings:groupsJSON];
    
    //iterate through all groups to fill up group names

    
    for (NSString* group in groupsJSON) {
 
        //localized test - REMOVE
        //if([group isEqualToString:@"anvil"] == NO) continue;
        //end localized test
        
        //get all the parts
        NSDictionary * groupInfo = [groupsJSON objectForKey:group];
        NSArray * tests = [groupInfo objectForKey:@"tests"];
        NSArray * urls = [groupInfo objectForKey:@"urls"];
        NSArray * display = [groupInfo objectForKey:@"display"];
        
        //set display
        [self.groupDisplays setObject:display[0] forKey:group];
        
        //set hosts, this is a combination of many fields. The code below is dense.
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
        [self.groupHosts setObject:hostList forKey:group];
    }
    //properties resets
    self.areAllHostsChecked = NO;
    self.areAllGroupsFinished = NO;
}
- (NSString *) jsonString
{
    
    
    NSString * jsonString = @"{\"ConnectivityDoctorServerCheckedReport\":{\"servers\":{";
    for (NSString * group in self.groupHosts) {
        jsonString = [[[jsonString  stringByAppendingString:@"\""]
                       stringByAppendingString:group]
                      stringByAppendingString:@"\":["];
        
        //protcol outer loop
        //protocols
        NSArray * hostList = [self.groupHosts objectForKey:group];
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
    
    for (NSInteger i = 0; i < self.groupDisplays.count; ++i)
    {
        [a addObject:[NSNull null]];
    }

 
    for (NSString * group in self.groupDisplays) {
       
        NSDictionary * dictDisplay = [self.groupDisplays valueForKeyPath:group];
        NSDictionary * dictResult = [dictDisplay valueForKeyPath:@"result"];
        NSDictionary * dictWarning = [dictDisplay valueForKeyPath:@"warning"];
        NSMutableDictionary * dictValues = [NSMutableDictionary new];
        
        [dictValues setValue:group forKey:SGJSONName];
        [dictValues setValue:[dictDisplay valueForKeyPath:@"name"] forKey:SGName];
        [dictValues setValue:[dictDisplay valueForKeyPath:@"description"] forKey:SGDescription];
        //Results
        [dictValues setValue:[dictResult valueForKeyPath:@"success"] forKey:SGResultSuccess];
        [dictValues setValue:[dictResult valueForKeyPath:@"error"] forKey:SGResultError];
        [dictValues setValue:[dictResult valueForKeyPath:@"warning"]?[dictResult valueForKeyPath:@"warning"]:@"" forKey:SGResultWarning];
        //error
        [dictValues setValue:[dictDisplay valueForKeyPath:@"error"] forKey:SGErrorMessage];
        //warning for Secure/NonSecure
        if (dictWarning) {
            [dictValues setValue:[dictWarning valueForKeyPath:@"secure"] forKey:SGWarningSecure];
            [dictValues setValue:[dictWarning valueForKeyPath:@"nonSecure"] forKey:SGWarningNonSecure];
        } else {
            [dictValues setValue:@"" forKey:SGWarningSecure];
            [dictValues setValue:@"" forKey:SGWarningNonSecure];
        }
        
        if([group isEqualToString:@"anvil"])
        {
 
            a[0] = dictValues;
        }
        else if([group isEqualToString:@"mantis"])
        {
            
            a[1] = dictValues;
        } else if([group isEqualToString:@"turn"])
        {
            
            a[2] = dictValues;
        } else if([group isEqualToString:@"logging"])
        {
            
            a[3] = dictValues;
        }

    }
    return a;
}


//array of NSDictionary with host info
-(NSArray *) hostsForGroup : (NSString *) groupName
{
    return [[self.groupHosts objectForKey:groupName]copy] ;
}


-(BOOL) allHostsChecked
{
    for (NSDictionary * dict in [self groupLabels]) {
        NSString * groupName = [dict objectForKey:SGJSONName];
        NSArray * hosts = [self.groupHosts objectForKey:groupName];
        for (NSDictionary * host in hosts) {
            NSString * val = [host objectForKey:kHostChecked];
            
            if([val isEqualToString:@"NO"]) return NO;
        }
        
    }
 
    return YES;
}

-(BOOL) allGroupsFinishedStatus
{
   for (NSDictionary * dict in [self groupLabels]) {
       if([self groupFinishedStatus:[dict objectForKey:SGJSONName]] == SGNotFinished)
       {
           
           return NO;
       }
    }
   
    return YES;
}


-(SGFinishedStatus) groupFinishedStatus : (NSString *) groupName
{
    NSArray * hosts = [self.groupHosts objectForKey:groupName];
    int hostCheckedSoFar = 0;
    int hostConnectedSoFar = 0;
    int hostTotalCount = hosts.count;
    
    for (NSDictionary * host in hosts) {

        BOOL checked = [[host objectForKey:kHostChecked] isEqualToString:@"YES"];
        BOOL connected = [[host objectForKey:kConnected] isEqualToString:@"YES"];
        if(checked) hostCheckedSoFar++;
        if(connected) hostConnectedSoFar++;
        
        if([groupName isEqualToString:@"anvil"] || [groupName isEqualToString:@"logging"])
        {
            if((hostCheckedSoFar == hostTotalCount) && (hostConnectedSoFar == hostTotalCount))
                return SGAllHostsConnected;
            if((hostCheckedSoFar == hostTotalCount) && (hostConnectedSoFar == 0)) return SGAllHostsFailed;
            if((hostCheckedSoFar == hostTotalCount) && (hostConnectedSoFar)) return SGAllHostsSomeConnectedAndSomeFailed;
            
        } else {
      
            if(checked && connected) return SGSomeHostConnected;
            if((hostCheckedSoFar == hostTotalCount) && (hostConnectedSoFar == 0)) return SGAllHostsFailed;
            
        }
        
    }
    return SGNotFinished;
}
// a value between 0 and 1 indicating percentage of hosts checked.
//The host can be connected or not.
-(CGFloat) groupProgress : (NSString *) groupName
{
    NSArray * hosts = [self.groupHosts objectForKey:groupName];
    int hostCheckedCount = 0;
    for (NSDictionary * host in hosts) {

        if([[host objectForKey:kHostChecked] isEqualToString:@"YES"]) hostCheckedCount++;
    }
    //NSLog(@"the progress is total = %d, checkedsofar = %d answer = %f",hosts.count,hostCheckedCount, (CGFloat)hostCheckedCount/(CGFloat)hosts.count);
    return (CGFloat)hostCheckedCount/(CGFloat)hosts.count;
    
}
//set connected flag
-(void) markConnectedStatusOfGroup : (NSString *) groupName hostURL:(NSString *)hosturl port:(NSString*) p flag:(BOOL) f
{
    
    NSArray * hosts = [self.groupHosts objectForKey:groupName];
    for (NSDictionary * host in hosts) {

        if([[host objectForKey:kURL] isEqualToString:hosturl] && [[host objectForKey:kPort] isEqualToString:p])
        {
            [host setValue:f?@"YES":@"NO" forKey:kConnected];
            [host setValue:@"YES" forKey:kHostChecked];
            self.areAllHostsChecked = [self allHostsChecked];
            self.areAllGroupsFinished = [self allGroupsFinishedStatus];
        }
    }
}

@end
