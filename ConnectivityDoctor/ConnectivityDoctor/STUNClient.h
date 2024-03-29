//
//  STUNClient.h
//  STUN
//
//  Created by Igor Khomenko on 9/19/12.
//  Copyright (c) 2012 Quickblox. All rights reserved. Check our BAAS quickblox.com
//
//
// This a simple and ad-hoc STUN client (UDP), partially compliant with RFC5389
// it gets the public(reflective) IP and Port of a UDP socket
//
// Documentation http://tools.ietf.org/html/rfc5389#page-10
// Russian tutorial http://svitter.ru/?p=442
//
// From quickblox.com team with love!
//


#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"


// STUN default port
#define STUNPort 3478

// The following is a list of some public/free stun servers
// some of them send the trasport address as both MAPPED-ADDRESS and XOR-MAPPED-ADDRESS -
// and others send only MAPPED-ADDRESS
// All list - http://www.tek-tips.com/faqs.cfm?fid=7542
#define STUNServer @"turn802-lhr.tokbox.com"

#define publicIPKey @"publicIPKey"
#define publicPortKey @"publicPortKey"
#define isPortRandomization @"isPortRandomization"

#define log 0
#define STUNLog(...) if (log) NSLog(__VA_ARGS__)


@protocol STUNClientDelegate;
@interface STUNClient : NSObject <GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate>{
    GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket * tcpSocket;
    id<STUNClientDelegate>delegate;
    
    // binding request
    NSData *msgTypeBindingRequest;
    NSData *bodyLength;
    NSData *magicCookie;
    NSData *transactionIdBindingRequest;
    
    // indication message
    NSData *msgTypeIndicationMessage;
    NSData *transactionIdIndicationMessage;
    
    NSTimer *retentionTimer;
}
- (id) initWithHost:(NSString*) host  port:(uint16_t) port timeout:(NSTimeInterval)t;
- (void)requestPublicIPandPortWithUDPSocket:(GCDAsyncUdpSocket *)socket delegate:(id<STUNClientDelegate>)delegate;
- (void)requestPublicIPandPortWithTCPSocket:(GCDAsyncSocket *)socket delegate:(id<STUNClientDelegate>)delegate;
- (void)startSendIndicationMessage;
- (void)stopSendIndicationMessage;

@end

@protocol STUNClientDelegate <NSObject>
-(void)didReceivePublicIPandPort:(NSDictionary *) data;
-(void)didReceiveAnError : (NSError *) err;
@end