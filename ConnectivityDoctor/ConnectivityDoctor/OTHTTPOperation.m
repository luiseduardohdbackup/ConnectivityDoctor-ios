//
//  OTHTTPOperation.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 5/8/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "OTHTTPOperation.h"
@interface OTHTTPOperation () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic) NSURLConnection * connection;
@property (nonatomic) NSMutableURLRequest * request;
@property (nonatomic,strong) NSString * host;
@property NSUInteger port;
@property NSTimeInterval timeout;
@property BOOL finished;
@property BOOL executing;

@end




@implementation OTHTTPOperation

-(id) init
{
    [NSException exceptionWithName:@"Invalid init call" reason:@"Use initWithHost:port" userInfo:nil];
    return  nil;
}

-(id) initWithHost:(NSString*) host port:(NSInteger) port timeout:(NSTimeInterval)time https:(BOOL)https
{
    self = [super init];
    if(self != nil)
    {
        self.host = host;
        self.port = port;
        self.timeout = time;
        self.secured = https;
        
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
            NSString * protocol = [NSString stringWithFormat:@"%@",self.secured?@"https":@"http"];
            NSArray * a = [self.host componentsSeparatedByString:@".com"];
            NSString * s = [NSString stringWithFormat:@"%@://%@.com:%lu%@",protocol,a[0],(unsigned long)self.port,a[1]];
            self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:s]
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval:self.timeout];

            [self.request setHTTPMethod:@"GET"];
           
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
            
            //run run till you get a callback. If you quit you have bad access on callback trigggered
            while(!self.isFinished && !self.isCancelled)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
           
            
           
        }
    }
    @catch (NSException *exception) {
        NSLog(@"something went wrong in HTTP operation");
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
    
    self.connection = nil;
    
}

#pragma mark NSURLCOnnection delegates
//-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",newStr);
//    
//}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connected = NO;
    [self tearDown];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

//http://stackoverflow.com/questions/6307400/load-https-url-in-a-uiwebview

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * r =  (NSHTTPURLResponse*)response;
    
    self.connected = (r.statusCode == 200);
    
    //TESTING CODE BELOW - ONE LINER
    //if(self.secured) self.connected = NO;
    
    [self tearDown];

 
   // NSLog(@"HTTP RESPONSE CODE = %ld",(long)r.statusCode);
}

@end
