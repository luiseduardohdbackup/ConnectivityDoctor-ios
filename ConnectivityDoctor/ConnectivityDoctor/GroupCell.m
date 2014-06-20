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
    
    //throttle so the user experience is slow
   // [self.queue setMaxConcurrentOperationCount:3];
    
    //fonts for labels
    [self.nameLabel setFont:[UIFont fontWithName:@"Muli"size:14.0f]];
    [self.nameDetailLabel setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
    [self.progressLabel setFont:[UIFont fontWithName:@"Muli"size:12.0f]];
}



#pragma mark Progressing
- (void)progressChange
{

    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.progressTintColor = [UIColor blackColor];
    self.progressView.backgroundColor = [UIColor clearColor];
    self.progressView.thicknessRatio = 0.1f;
    self.progressView.clockwiseProgress = YES;
    self.progressView.progress = self.hostConnectedCount/self.hostTotalCount;
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f%%", self.progressView.progress * 100];
    
    
    if(self.hostConnectedCount)
    {
        //One guy broke thru the FireWall ok, so finish up and cancel all others
        [self.queue cancelAllOperations];
        [self.finishedView setImage:[UIImage imageNamed:@"connected"]];
        self.finishedView.hidden = NO;
        self.progressView.hidden = YES;
        self.progressLabel.hidden = YES;

    } else {
        if(self.hostTotalCount == self.hostCheckedSoFarCount)
        {
            [self.finishedView setImage:[UIImage imageNamed:@"notConnected"]];
            self.finishedView.hidden = NO;
            self.progressView.hidden = YES;
            self.progressLabel.hidden = YES;

        }
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
               // NSLog(@"OPERATION +CANCELLED");
            }
            
        };
        
        
        [self.queue addOperation:operation];


        
        
    }];
}

-(void) setPath: (NSIndexPath *)indexPath
{
    NSArray * groupNames = [self.servers groupLabels];
    
    NSDictionary * dict = groupNames[indexPath.row];
    NSString* groupName = [dict objectForKey:SGName];
    
    self.nameLabel.text = groupName;
    [self networkTestForGroup:[dict objectForKey:SGJSONName]];
    
    self.nameDetailLabel.text = [dict objectForKey:SGDescription];
    //make sure auto-layout is checked off in IB for this cell
    [self.nameDetailLabel sizeToFit];

    
    if(indexPath.row % 2 == 0)
    {
        //even
        self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1];
        
    } else {
        //odd
        self.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1];
    }
    //TEST
    //    if([groupName isEqualToString:@"logging"]){
    //        cell.nameLabel.text = groupName;
    //        [cell networkTestForGroup:groupName];
    //    }

    
}

@end
