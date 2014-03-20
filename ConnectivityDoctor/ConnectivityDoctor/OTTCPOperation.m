//
//  TCPOperation.m
//  OpenTokHelloWorld
//
//  Created by Jaideep Shah on 1/2/14.
//
//

#import "OTTCPOperation.h"
#import "GCDAsyncSocket.h"



@interface OTTCPOperation () <GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket * tcpSocket;
@property (nonatomic,strong) NSString * host;
@property NSUInteger port;
@property NSTimeInterval timeout;
@property BOOL finished;
@property BOOL executing;
@end

@implementation OTTCPOperation


-(id) init
{
    [NSException exceptionWithName:@"Invalid init call" reason:@"Use initWithHost:port" userInfo:nil];
    return  nil;
}

-(id) initWithHost:(NSString*) host port:(NSInteger) port timeout:(NSTimeInterval)time
{
    self = [super init];
    if(self != nil)
    {
        self.host = host;
        self.port = port;
        self.timeout = time;
        
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

            self.tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            NSError *error = nil;
            if (![self.tcpSocket connectToHost:self.host onPort:self.port withTimeout:self.timeout error:&error]) // Asynchronous!
            {
                // If there was an error, it's likely something like "already connected" or "no delegate set"
                NSLog(@"I goofed - already connected or delegate not set: %@", error);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"something went wrong in TCPOperation");
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
    self.tcpSocket = nil;
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    self.connected = YES;
    [self tearDown];

}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    self.connected = NO;
    [self tearDown];
}

@end
