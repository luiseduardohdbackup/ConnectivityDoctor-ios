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
#import "MKNumberBadgeView.h"

@interface GroupCell()
@property (strong, nonatomic) NSTimer *timer;
@property float progress;
@property float hostTotalCount;
@property float hostConnectedCount;
@property float hostCheckedSoFarCount;
@property (nonatomic) ServerGroups * servers;
@property (nonatomic, strong) NSOperationQueue * queue;
@end

@implementation GroupCell
-(void) awakeFromNib
{
    self.hostConnectedCount = 0;
    self.hostCheckedSoFarCount = 0;
    self.servers = [ServerGroups sharedInstance];
    self.queue = [NSOperationQueue new];
    self.finishedView.hidden = YES;
    self.badgeView.hidden = YES;
    //throttle so the user experience is slow
    [self.queue setMaxConcurrentOperationCount:3];
}



#pragma mark TimerChecks
-(void) incrementHostCheckedCount
{
    self.hostConnectedCount++;
    [self progressChange];
    
}
- (void)progressChange
{

    
    self.progressView.roundedCorners = NO;
 
   
    self.progressView.trackTintColor = [UIColor redColor];
    self.progressView.progressTintColor = [UIColor greenColor];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 1.0f;
    self.progressView.clockwiseProgress = YES;

    self.progressView.progress = self.hostConnectedCount/self.hostTotalCount;
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.progressView.progress * 100];
    self.badgeView.hidden = YES;
    
    if(self.hostTotalCount == self.hostCheckedSoFarCount)
    {
        if(self.hostTotalCount == self.hostConnectedCount)
        {
            [self.finishedView setImage:[UIImage imageNamed:@"connected"]];
        } else {
            [self.finishedView setImage:[UIImage imageNamed:@"notConnected"]];
            self.badgeView.value = self.hostTotalCount - self.hostConnectedCount;
            self.badgeView.hidden = NO;
            
        }
        self.finishedView.hidden = NO;
        self.progressView.hidden = YES;
    }

    
}
- (void)startAnimation
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(incrementHostCheckedCount)
                                                userInfo:nil
                                                 repeats:YES];
    
}



- (OTConnectivityBaseOperation *) operationForProtocolList : (NSString *) protocols host:(NSString*) url port:(int) port
{
    OTConnectivityBaseOperation * operation = nil;
    NSArray * protocol = [protocols componentsSeparatedByString:@"/"];
   
    NSString * p1 = protocol[0];
    NSString * p2 = (protocol.count == 2)? protocol[1]:nil;
    
    if (([p1 isEqualToString:@"tcp"] && (p2 == nil)) || (p1 && [p2 isEqualToString:@"tcp"]))
    {
        operation = [[OTTCPOperation alloc] initWithHost:url port:port timeout:10];
    }
    else if([p1 isEqualToString:@"ws"])
    {
        operation = [[OTWebSocketOperation alloc] initWithHost:url port:port timeout:10];
        
    }
    else if([p1 isEqualToString:@"wss"])
    {
        //TODO make it secure
        operation = [[OTWebSocketOperation alloc] initWithHost:url port:port timeout:10];
    }
    else if ([p1 isEqualToString:@"stun"] &&  [p2 isEqualToString:@"udp"] )
    {
        operation = [[OTSTUNOperation alloc] initWithHost:url port:port timeout:10];
        
    }
   // NSLog(@"operation = %@ protocols = %@ url=%@ port=%d",[operation class], protocols, url,port);
    return operation;

    
}
-(void) networkTestForGroup : (NSString *) name
{
    NSArray * hosts = [self.servers hostsForGroup:name];
    if(hosts.count == 0) return;
    
    self.hostTotalCount = hosts.count;
    self.hostConnectedCount = 0;
    self.hostCheckedSoFarCount = 0;
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
            self.hostCheckedSoFarCount++;
            if(weakOperation.isCancelled == NO)
            {

                
                [self.servers markConnectedStatusOfGroup:name hostURL:[host objectForKey:kURL]
                                                    port:[host objectForKey:kPort] flag:weakOperation.connected];
                
                
                
                if(weakOperation.connected) {
                  //  NSLog(@"ok  host = %@ port = %d protocol=%@", [host objectForKey:kURL],[[host objectForKey:kPort] intValue],[host objectForKey:kProtocol]);

                    self.hostConnectedCount++;
                } else {
                    // NSLog(@"NOT connected  host = %@ port = %d protocol=%@", [host objectForKey:kURL],[[host objectForKey:kPort] intValue],[host objectForKey:kProtocol]);
                }
                weakOperation = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self progressChange];
                });
                
            } else {
                NSLog(@"OPERATION +CANCELLED");
            }
            
        };
        
        
        [self.queue addOperation:operation];


        
        
    }];
}
@end
