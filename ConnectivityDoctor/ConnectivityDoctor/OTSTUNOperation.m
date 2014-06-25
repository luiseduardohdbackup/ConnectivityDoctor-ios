//
//  STUNOperation.m
//  OpenTokHelloWorld
//
//  Created by Jaideep Shah on 1/3/14.
//
//

#import "OTSTUNOperation.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "STUNClient.h"


@interface OTSTUNOperation () <STUNClientDelegate,GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncUdpSocket * udpSocket;
@property (nonatomic,strong) GCDAsyncSocket * tcpSocket;
@property (nonatomic,strong) STUNClient *stunClient;
@property (nonatomic,strong) NSString * host;
@property NSUInteger port;
@property NSTimeInterval timeout;
@property BOOL finished;
@property BOOL executing;
@property BOOL isTCPProtocol;
@end

@implementation OTSTUNOperation


-(id) init
{
    [NSException exceptionWithName:@"Invalid init call" reason:@"Use initWithHost:port" userInfo:nil];
    return  nil;
}

-(id) initWithHost:(NSString*) host port:(NSInteger) port timeout:(NSTimeInterval)time isTCPProtocol:(BOOL)p
{
    self = [super init];
    if(self != nil)
    {
        self.host = host;
        self.port = port;
        self.timeout = time;
        self.isTCPProtocol = p;
        
        self.finished = NO;
        self.executing = NO;
        self.connected = NO;
    }
    return self;
}


#pragma mark NSOperation override methods
- (void) start
{
    /* If we are cancelled before starting, then
     we have to return immediately and generate the required KVO notifications */
    if ([self isCancelled]){
        /* If this operation *is* cancelled */
        /* KVO compliance */
        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    } else {
        /* If this operation is *not* cancelled */
        /* KVO compliance */
        [self willChangeValueForKey:@"isExecuting"];
        self.executing = YES;
        /* Call the main method from inside the start method */ [self didChangeValueForKey:@"isExecuting"];
        [self main];
    }
}
-(void) main
{
    @try {
        @autoreleasepool {
            self.stunClient = [[STUNClient alloc] initWithHost:self.host port:self.port timeout:self.timeout];

            if(!self.isTCPProtocol)
            {
                //UDP
               
                self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self.stunClient delegateQueue:dispatch_get_main_queue()];
                [self.stunClient requestPublicIPandPortWithUDPSocket:self.udpSocket delegate:self];
                
            } else {
                self.tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

                
                NSError *error = nil;
                if (![self.tcpSocket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&error]) // Asynchronous!
                {
                    // If there was an error, it's likely something like "already connected" or "no delegate set"
                    NSLog(@"I goofed - already connected or delegate not set: %@", error);
                } else {
                    while(!self.isFinished && !self.isCancelled)
                    {
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                    }
 

                   
                }
                
            }
             
            //now wait
            double delayInSeconds = self.timeout;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if(self.finished == NO)
                {
                    self.connected = NO;
                    [self tearDown];
                    
                }
            });
       
        }
    }
    @catch (NSException *exception) {
        NSLog(@"something went wrong in UDPOperation");
    }
    @finally {
        
    }
}

- (BOOL) isConcurrent{
    return YES;
}
- (BOOL) isFinished{
    /* Simply return the value */
    return(self.finished);
}
- (BOOL) isExecuting{
    /* Simply return the value */
    return(self.executing);
}

- (void) tearDown
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    self.finished = YES;
    self.executing = NO;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
    // make socket nil
    self.udpSocket = nil;
    self.tcpSocket = nil;
}
#pragma matk GCDAsyncSocket
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    if(self.isTCPProtocol)
    {
        [self.stunClient requestPublicIPandPortWithTCPSocket:sender delegate:self];
       
    }
    
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if(self.isTCPProtocol)
    {
        self.connected = NO;
        
        [self tearDown];
    
        
    }


}

#pragma mark STUN Client Delegate
-(void)didReceivePublicIPandPort:(NSDictionary *) data{
    
    self.connected = YES;

    [self tearDown];

//    NSLog(@"Public IP=%@, public Port=%@, NAT is Symmetric: %@", [data objectForKey:publicIPKey],
//          [data objectForKey:publicPortKey], [data objectForKey:isPortRandomization]);
//    
//    
//    [self.stunClient startSendIndicationMessage];
}

-(void) didReceiveAnError:(NSError *)err
{
    if(self.isTCPProtocol)
    {
        self.connected = NO;
        
        [self tearDown];
        
        //NSLog(@"socket error stun %@",self.host);
    }

    
}

@end

//                    [self.tcpSocket performBlock:^{
//                        int fd = [self.tcpSocket socketFD];
//                        int on = 1;
//                        if (setsockopt(fd, SOL_SOCKET, SO_REUSEPORT, (char*)&on, sizeof(on)) == -1) {
//                            /* handle error */
//                            NSLog(@"resuse error");
//                        }
//                    }];


//                    NSError *err = nil;
//                    if (![self.tcpSocket acceptOnPort:self.port error:&err])
//                    {
//                        NSLog(@"I goofed: %@", err);
//                    }
//

