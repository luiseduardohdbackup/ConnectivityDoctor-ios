//
//  OTWebSocketOperation.m
//  OpenTokHelloWorld
//
//  Created by Jaideep Shah on 2/3/14.
//
//

#import "OTWebSocketOperation.h"
#import "SRWebSocket.h"


@interface OTWebSocketOperation () <SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *webSocket;
@property (nonatomic,strong) NSString * host;
@property NSUInteger port;
@property NSTimeInterval timeout;
@property BOOL finished;
@property BOOL executing;
@end

@implementation OTWebSocketOperation

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

            NSString * url = [NSString stringWithFormat:@"wss://%@:%d/rumorwebsockets",self.host,self.port];

            _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
            _webSocket.delegate = self;

            [_webSocket open];



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
        NSLog(@"something went wrong in OTWebSocketOperation");
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
    self.webSocket.delegate = nil;
    self.webSocket = nil;
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
   // NSLog(@"Websocket Connected");
    self.connected = YES;
    [self tearDown];

    
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
   // NSLog(@":( Websocket Failed With Error %@", error);
    self.connected = NO;
    [self tearDown];
    

}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
   // NSLog(@"Received \"%@\"", message);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
   // NSLog(@"WebSocket closed");
    
    [self tearDown];
  
}


@end
