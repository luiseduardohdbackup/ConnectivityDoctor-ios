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

static NSString * kServerEntity = @"Server";
static NSString * kServerEntity_Name = @"name";
static NSString * kServerEntity_GenericURL = @"genericURL";
static NSString * kServerEntity_Relationship_Protocol = @"protocol";
static NSString * kServerEntity_Relationship_Host = @"url";

static NSString * kHostEntity = @"Host";

static NSString * kProtocolEntity = @"Protocol";
static NSString * kProtocolEntity_Name = @"name";
static NSString * kProtocolEntity_UrlPath = @"urlPath";
static NSString * kProtocolEntity_Port = @"port";

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
        self.managedObjectContext = self.appDelegate.managedObjectContext;
    }
    return self;
}
#pragma mark Helpers
-(void) printAllManagedObjects
{
    // Server
    NSFetchRequest *fetchRequestServer = [[NSFetchRequest alloc] init];

    [fetchRequestServer setEntity:[NSEntityDescription entityForName:kServerEntity inManagedObjectContext:self.managedObjectContext]];
   
    NSArray * objs = [self.managedObjectContext executeFetchRequest:fetchRequestServer error:nil];
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
    [self scratchOffAllObjectsIn:kServerEntity];
    [self scratchOffAllObjectsIn:kHostEntity];
    [self scratchOffAllObjectsIn:kProtocolEntity];
    
    [self.appDelegate saveContext];
    
}
#pragma mark Load/Unload

- (void) loadServersListFromScratch
{
    NSLog(@"json loading started");
    [self scratchOffAllManagedObjects];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerListGetURL]
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:10];
    [urlRequest setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) {
             NSDictionary * info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
             NSDictionary * servers = [info objectForKey:@"servers"];
             
             //iterate through all servers
             for (NSString* key in servers) {
                 
                 //
                  NSManagedObject * serverManagedObject = [NSEntityDescription insertNewObjectForEntityForName:kServerEntity
                                                                  inManagedObjectContext:self.managedObjectContext];
                 
                 [serverManagedObject setValue:key forKey:kServerEntity_Name];
                 
                 NSDictionary * server = [servers objectForKey:key];
                 [serverManagedObject setValue:[server objectForKey:@"generic_url"] forKey:kServerEntity_GenericURL];
                 
                 //now fill up the Protocol Object
                 NSArray * tests = [server objectForKey:@"tests"];
                 NSMutableSet * set = [NSMutableSet new];
                 for (NSDictionary * test in tests) {
                     NSManagedObject * protocolManagedObject = [NSEntityDescription insertNewObjectForEntityForName:kProtocolEntity
                                                                           inManagedObjectContext:self.managedObjectContext];
                     [protocolManagedObject setValue:[test objectForKey:@"protocol"] forKey:kProtocolEntity_Name];
                     [protocolManagedObject setValue:[test objectForKey:@"range"] forKey:kProtocolEntity_Port];
                     [protocolManagedObject setValue:[test objectForKey:@"path"] forKey:kProtocolEntity_UrlPath];
                     
                     [set addObject:protocolManagedObject];
                     
            
                 }
                 //link to server managed object
                 [serverManagedObject setValue:set forKey:kServerEntity_Relationship_Protocol];
                 
                 
                 
             }
             
             [self.appDelegate saveContext];
             // NSLog(@"%@",servers);
             [self printAllManagedObjects];
         }
         
         else if ([data length] == 0 && error == nil)
             NSLog(@"NTWK:got no data");
         else if (error != nil && error.code == NSURLErrorTimedOut)
             NSLog(@"NTWK:timeout");
         else if (error != nil)
             NSLog(@"NTWK:error %@",error.description);
     }];

}
@end
