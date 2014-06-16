//
//  MailViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/28/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "MailViewController.h"
#import "ServerGroups.h"
#import "Utils.h"


@interface MailViewController ()
@property (nonatomic) ServerGroups * serverGroupStore;
@end

@implementation MailViewController
-(id)initWithCoder:(NSCoder *)aDecoder
{
    return [super init];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    if ([MFMailComposeViewController canSendMail])
    {
        NSString * body =  [NSString new];
        NSString * testResultMessage = [NSString new];
        self.serverGroupStore = [ServerGroups sharedInstance];

        body = [NSString stringWithFormat:@"<h3>%@:",kUtils_ReportHeaderText];
        body = [body stringByAppendingString:@"<p>"];
        body = [body stringByAppendingString:[Utils date_HH_AP_MM_DD_YYYY]];
        body = [body stringByAppendingString:@"</p></h3>"];
        
        for (NSDictionary * d in [self.serverGroupStore groupLabels]) {
            body = [body stringByAppendingString:@"<h4>"];
            body = [body stringByAppendingString:[d objectForKey:SGName]];
            body = [body stringByAppendingString:@"</h4>"];
            
//            body = [body stringByAppendingString:@"<p><span style=\"font-size:10px;\">"];
//            body = [body stringByAppendingString:[d objectForKey:SGDescription]];
//            body = [body stringByAppendingString:@"</span></p>"];
            
            body = [body stringByAppendingString:@"<p><span style=\"font-size:10px;\">"];
            body = [body stringByAppendingString:@"Test Result:"];
           
            
            testResultMessage = @"OK";
            for (NSDictionary * d1 in [self.serverGroupStore hostsForGroup:[d objectForKey:SGJSONName]])
            {
                
                if([[d1 objectForKey:kConnected] isEqualToString:@"NO"])
                {
                    
                    testResultMessage = [d objectForKey:SGErrorMessage];
                    break;
                }
            }
           
            body = [body stringByAppendingString:testResultMessage];
            body = [body stringByAppendingString:@"</span></p>"];
        }
        self.mailComposeDelegate = self;
        [self setSubject:@"Connectivity Doctor"];
        [self setMessageBody:body isHTML:YES];
        [self setToRecipients:@[@"jaideep@tokbox.com"]];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MFMailComposeResultCancelled:
                NSLog(@"Mail view cancelled");
                break;
            case MFMailComposeResultFailed:
                 NSLog(@"Mail view failed");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"Mail view saved");
                break;
            case MFMailComposeResultSent:
                //TODO send message to TokBox servers
                NSLog(@"Mail view sent");
                break;

        }

    }];
}
@end
