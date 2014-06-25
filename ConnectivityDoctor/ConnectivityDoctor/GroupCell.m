//
//  GroupCell.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/14/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "GroupCell.h"
#import "DACircularProgressView.h"
#import "ServerGroups.h"
#import "OTConnectivityBaseOperation.h"
#import "OTTCPOperation.h"
#import "OTSTUNOperation.h"
#import "OTWebSocketOperation.h"
#import "OTHTTPOperation.h"


@interface GroupCell()
@property float progress;
@property (nonatomic) ServerGroups * servers;
@property (nonatomic, strong) NSOperationQueue * queue;
@property (nonatomic) NSDictionary * dictDisplay;
@end

@implementation GroupCell
-(void) awakeFromNib
{
    self.servers = [ServerGroups sharedInstance];
    self.queue = [NSOperationQueue new];
    self.finishedView.hidden = YES;

    //throttle so the user experience is slow
   // [self.queue setMaxConcurrentOperationCount:3];
    
    //fonts for labels
    [self.nameLabel setFont:[UIFont fontWithName:@"Muli"size:14.0f]];
    [self.nameDetailLabel setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    [self.progressLabel setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
}



#pragma mark Progressing
-(void) showFinishedView : (UIImage *) img
{
    [self.finishedView setImage:img];
    self.finishedView.hidden = NO;
    self.progressView.hidden = YES;
    self.progressLabel.hidden = YES;

    
}
- (void)progressChange
{

    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.progressTintColor = [UIColor blackColor];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.clockwiseProgress = YES;
    
    self.progressView.progress = [self.servers groupProgress:[self.dictDisplay objectForKey:SGJSONName]];
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.progressView.progress * 100];
    
    SGFinishedStatus status = [self.servers groupFinishedStatus:[self.dictDisplay objectForKey:SGJSONName]];
    
    if ((status == SGAllHostsConnected) || (status == SGSomeHostConnected))
    {
       [self showFinishedView:[UIImage imageNamed:@"connected"]];
        if(status == SGSomeHostConnected) [self.queue cancelAllOperations];
        
    } else if(status == SGAllHostsFailed)
    {
         [self showFinishedView:[UIImage imageNamed:@"notConnected"]];
    }
    else if(status == SGAllHostsSomeConnectedAndSomeFailed)
    {
         [self showFinishedView:[UIImage imageNamed:@"unknown"]];

    }

    
}


- (OTConnectivityBaseOperation *) operationForProtocolList : (NSString *) protocol host:(NSString*) url port:(int) port
{
    OTConnectivityBaseOperation *  operation = nil;
    
    if ([protocol isEqualToString:@"http"]) {
        operation = [[OTHTTPOperation alloc] initWithHost:url port:port timeout:10 https:NO];
        
    }
    else if ([protocol isEqualToString:@"https"])
    {
         operation = [[OTHTTPOperation alloc] initWithHost:url port:port timeout:10 https:YES];
        
    }
    else if ([protocol isEqualToString:@"tcp"])
    {
        operation = [[OTTCPOperation alloc] initWithHost:url port:port timeout:10];
        
    }
    else if([protocol isEqualToString:@"ws"])
    {
        operation = [[OTWebSocketOperation alloc] initWithHost:url port:port timeout:10];
        
    }
    else if([protocol isEqualToString:@"wss"])
    {
        //TODO make it secure
        operation = [[OTWebSocketOperation alloc] initWithHost:url port:port timeout:10];
    }
    else if ([protocol isEqualToString:@"stun/udp"])
    {
       operation = [[OTSTUNOperation alloc] initWithHost:url port:port timeout:10 isTCPProtocol:NO];
        
    } else if ([protocol isEqualToString:@"stun/tcp"])
    {

        operation = [[OTSTUNOperation alloc] initWithHost:url port:port timeout:10 isTCPProtocol:YES];
        
    }
   // NSLog(@"operation = %@ protocols = %@ url=%@ port=%d",[operation class], protocols, url,port);
    return operation;

    
}
-(void) networkTestForGroup : (NSString *) name
{
    NSArray * hosts = [self.servers hostsForGroup:name];
    if(hosts.count == 0) return;
    
    self.finishedView.hidden = YES;
    self.progressView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self progressChange];
    });

 
    [hosts enumerateObjectsUsingBlock:^(NSDictionary * host, NSUInteger idx, BOOL *stop) {
        
        OTConnectivityBaseOperation * operation = [self operationForProtocolList:[host objectForKey:kProtocol]
                                                                            host:[host objectForKey:kURL]
                                                                            port:[[host objectForKey:kPort] intValue]];
        __block __weak OTConnectivityBaseOperation * weakOperation = operation;
        operation.completionBlock = ^{

            if(weakOperation.isCancelled == NO)
            {

                
                [self.servers markConnectedStatusOfGroup:name hostURL:[host objectForKey:kURL]
                                                    port:[host objectForKey:kPort] flag:weakOperation.connected];
  
                if(weakOperation.connected) {
                  //  NSLog(@"ok  host = %@ port = %d protocol=%@", [host objectForKey:kURL],[[host objectForKey:kPort] intValue],[host objectForKey:kProtocol]);


                } else {
                    // NSLog(@"NOT connected  host = %@ port = %d protocol=%@", [host objectForKey:kURL],[[host objectForKey:kPort] intValue],[host objectForKey:kProtocol]);
                }
                weakOperation = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressChange];
                });
                
            } else {
               // NSLog(@"OPERATION +CANCELLED");
            }
            
        };
        
        
        [self.queue addOperation:operation];


        
        
    }];
}
-(void) startDisplayAtPath : (NSIndexPath *) path

{
    NSArray * groupNames = [self.servers groupLabels];
    
    self.dictDisplay = groupNames[path.row];
    NSString* groupName = [self.dictDisplay objectForKey:SGName];
    
    self.nameLabel.text = groupName;
    self.nameDetailLabel.text = [self.dictDisplay objectForKey:SGDescription];
    //make sure auto-layout is checked off in IB for this cell
    [self.nameDetailLabel sizeToFit];
    
    //alternate bg color
    if(path.row % 2 == 0)
    {
        //even
        self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
        
    } else {
        //odd
        self.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
    }
    
    //start the testing
     [self networkTestForGroup:[self.dictDisplay objectForKey:SGJSONName]];
    
}

@end
