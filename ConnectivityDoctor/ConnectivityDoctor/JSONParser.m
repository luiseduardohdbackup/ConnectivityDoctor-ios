//
//  JSONParser.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/10/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "JSONParser.h"
#import "AppDelegate.h"




static NSString * kServerListGetURL = @"http://sup301-sat.tokbox.com/dynamicTestConfig.json";

NSString * const kGroupEntity = @"Group";
NSString * const kGroupEntity_Name = @"name";
static NSString * const kGroupEntity_Relationship_Protocol = @"protocol";
static NSString * const kGroupEntity_Relationship_Host = @"url";

static NSString * const kHostEntity = @"Host";
static NSString * const kHostEntity_GenericURL = @"genericURL";
static NSString * const kHostEntity_URL = @"url";
static NSString * const kHostEntity_connected = @"connected";

static NSString * const kProtocolEntity = @"Protocol";
static NSString * const kProtocolEntity_Name = @"name";
static NSString * const kProtocolEntity_UrlPathExtension = @"urlPathExtension";
static NSString * const kProtocolEntity_Port = @"port";

@interface JSONParser ()
@property (nonatomic) AppDelegate * appDelegate;
@property (nonatomic) NSManagedObjectContext * managedObjectContext;
@end


@implementation JSONParser
- (id)init
{
    self = [super init];
    if (self) {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = self.appDelegate.bgManagedObjectContext;
        
    }
    
    return self;
}
#pragma mark Helpers
-(void) printAllManagedObjects
{
    // Server
    NSFetchRequest *fetchRequestGroup = [[NSFetchRequest alloc] init];

    [fetchRequestGroup setEntity:[NSEntityDescription entityForName:kGroupEntity inManagedObjectContext:self.managedObjectContext]];
   
    NSArray * objs = [self.managedObjectContext executeFetchRequest:fetchRequestGroup error:nil];
    for (NSManagedObject * obj in objs) {
        NSLog(@"%@",obj);
    }
    
    //Protocol
    NSFetchRequest *fetchRequestProtocol = [[NSFetchRequest alloc] init];
    [fetchRequestProtocol setEntity:[NSEntityDescription entityForName:kProtocolEntity inManagedObjectContext:self.managedObjectContext]];
    
    NSArray * protocols = [self.managedObjectContext executeFetchRequest:fetchRequestProtocol error:nil];
    for (NSManagedObject * protocol in protocols) {
        NSLog(@"%@",protocol);
    }

    //Host
    NSFetchRequest *fetchRequestHost = [[NSFetchRequest alloc] init];
    [fetchRequestHost setEntity:[NSEntityDescription entityForName:kHostEntity inManagedObjectContext:self.managedObjectContext]];
    
    NSArray * hosts = [self.managedObjectContext executeFetchRequest:fetchRequestHost error:nil];
    for (NSManagedObject * host in hosts) {
        NSLog(@"%@",host);
    }

    
    
    
}
-(void) scratchOffAllObjectsIn : (NSString *) entity
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError * error = nil;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO]; //only managedObjectID
    NSArray * objs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject * obj in objs) {
        [self.managedObjectContext deleteObject:obj];
    }
}

-(void) scratchOffAllManagedObjects
{
    [self scratchOffAllObjectsIn:kGroupEntity];
//    [self scratchOffAllObjectsIn:kHostEntity];
//    [self scratchOffAllObjectsIn:kProtocolEntity];
 
}


#pragma mark Load/Unload

- (void) serversList
{
    NSLog(@"json loading started");
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerListGetURL]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:10];
    [urlRequest setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if ([data length] > 0 && error == nil) {
             
        
            [self.managedObjectContext performBlock:^{
                
            
                [self scratchOffAllManagedObjects];
                
                 
                 NSDictionary * info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 NSDictionary * groups = [info objectForKey:@"servers"];
                 
                 //iterate through all groups
                 for (NSString* group in groups) {
                    
                      NSManagedObject * groupManagedObject = [NSEntityDescription insertNewObjectForEntityForName:kGroupEntity
                                                                      inManagedObjectContext:self.managedObjectContext];
                     
                     [groupManagedObject setValue:group forKey:kGroupEntity_Name];
                     
                     //groupInfo object
                     NSDictionary * groupInfo = [groups objectForKey:group];
     
                     
                     NSArray * tests = [groupInfo objectForKey:@"tests"];
                     NSMutableSet * protocolSet = [NSMutableSet new];
                     
                     for (NSDictionary * test in tests) {
                         //loop thru ports list
                         NSArray *ports = [[test objectForKey:@"range"] componentsSeparatedByString:@","];
                         for (NSString * port in ports) {
                             //now fill up the Protocol Object
                             NSManagedObject* p = [NSEntityDescription insertNewObjectForEntityForName:kProtocolEntity
                                                                                inManagedObjectContext:self.managedObjectContext];
                             
                             [p setValue:[test objectForKey:@"protocol"] forKey:kProtocolEntity_Name];
                             [p setValue:port forKey:kProtocolEntity_Port];
                             [p setValue:[test objectForKey:@"path"] forKey:kProtocolEntity_UrlPathExtension];
                             [protocolSet addObject:p];
                         }
                         
                     }
                     //link to server managed object
                     [groupManagedObject setValue:protocolSet forKey:kGroupEntity_Relationship_Protocol];

                     // now fill up Host
                     NSMutableSet * hostSet = [NSMutableSet new];
     
                     NSArray * hosts = [groupInfo objectForKey:@"urls"];
                     
                     for (NSString * host in hosts) {
                         NSManagedObject * h = [NSEntityDescription insertNewObjectForEntityForName:kHostEntity inManagedObjectContext:self.managedObjectContext];
                         [h setValue:host forKey:kHostEntity_URL];
                         [h setValue: @"Yes" forKey:kHostEntity_connected];
                         [h setValue:[groupInfo objectForKey:@"generic_url"] forKey:kHostEntity_GenericURL];
                         [hostSet addObject:h];
                         
                         }
                     
                     //link all hosts to Server
                     [groupManagedObject setValue:hostSet forKey:kGroupEntity_Relationship_Host];
                 }
                 
                 //save
                [self.appDelegate saveContext];
                [self printAllManagedObjects];
            }];
             //input print
              //NSLog(@"%@",groups);
         }
         
         else if ([data length] == 0 && error == nil)
             NSLog(@"NTWK:got no data");
         else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"NTWK:timeout");
         else if (error != nil)
             NSLog(@"NTWK:error %@",error.description);
     }];

}

/*
 { "ConnectivityDoctorServerCheckedReport" :
 { "servers": {
 "http" :
 [
 {
 "url": "www.anvil.com",
 "protocol": "http",
 "port": 80,
 
 "status" : "connected"
 
 },
 {
 "url": "www.logging.com",
 "protocol": "http",
 "port": 80,
 
 "status" : "notConnected"
 
 }
 
 ],
 "mantis" : [
 {
 "url": "www.mantis1.com",
 "protocol": "tcp",
 "port": 443,
 
 "status" : "connected"
 
 },
 {
 "url": "www.mantis2.com",
 "protocol": "stun",
 "port": 5560,
 
 "status" : "notConnected"
 
 }
 ]
 
 },
 "checkedAt" : "03-21-14 15:28:03"
 }
 }
*/
- (NSString *) report
{
    
    
    NSFetchRequest *fetchRequestGroup = [[NSFetchRequest alloc] init];
    
    [fetchRequestGroup setEntity:[NSEntityDescription entityForName:kGroupEntity inManagedObjectContext:self.managedObjectContext]];
    
    NSArray * groups = [self.managedObjectContext executeFetchRequest:fetchRequestGroup error:nil];
    
    if(groups == nil) return @"nothing to report";
    
    NSString * jsonString = @"{\"ConnectivityDoctorServerCheckedReport\":{\"groups\":{";
    for (NSManagedObject * group in groups) {
        jsonString = [[[jsonString  stringByAppendingString:@"\""]
                                    stringByAppendingString:[group valueForKey:kGroupEntity_Name]]
                                    stringByAppendingString:@"\":["];
        
        //protcol outer loop
        //protocols
        NSMutableSet * protocols = [group mutableSetValueForKey:kGroupEntity_Relationship_Protocol];
        NSMutableSet * hosts = [group mutableSetValueForKey:kGroupEntity_Relationship_Host];
        
        for (NSManagedObject* protocol in protocols) {
            
            for (NSManagedObject * host in hosts) {
            jsonString = [jsonString stringByAppendingString:@"{\"protocol\":\""];
            jsonString = [[jsonString stringByAppendingString:[protocol valueForKey:kProtocolEntity_Name]]
                          stringByAppendingString:@"\","];
            jsonString = [[[jsonString  stringByAppendingString:@"\"port\":\""]
                           stringByAppendingString:[protocol valueForKey:kProtocolEntity_Port]]
                          stringByAppendingString:@"\","];
            
        

            //hosts

                jsonString = [[[jsonString  stringByAppendingString:@"\"url\":\""]
                               stringByAppendingString:[host valueForKey:kHostEntity_URL]]
                              stringByAppendingString:@"\","];


                jsonString = [[[jsonString  stringByAppendingString:@"\"status\":\""]
                               stringByAppendingString:[host valueForKey:kHostEntity_connected]]
                              stringByAppendingString:@"\","];
                
                NSString * generic_url = [host valueForKey:kHostEntity_GenericURL];
                jsonString = [[[jsonString  stringByAppendingString:@"\"generic_url\":\""]
                               stringByAppendingString:generic_url?generic_url:@"n/a"]
                              stringByAppendingString:@"\"},"];
            }
        }
        //remove the last comma
        jsonString = [jsonString substringToIndex:[jsonString length]-1];
        jsonString = [jsonString stringByAppendingString:@"],"];
        
    }
    //remove the last comma
     jsonString = [jsonString substringToIndex:[jsonString length]-1];
    // put check date and end everything
    jsonString = [jsonString stringByAppendingString:@"},\"checkedAt\":\""];
    NSString * date =  [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                      dateStyle:NSDateFormatterShortStyle
                                                      timeStyle:NSDateFormatterLongStyle];
    jsonString = [jsonString stringByAppendingString:date];
    jsonString = [jsonString stringByAppendingString:@"\"}}"];
    

    return jsonString;
}
@end
