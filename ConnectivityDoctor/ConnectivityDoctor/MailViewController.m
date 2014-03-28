//
//  MailViewController.m
//  ConnectivityDoctor
//
//  Created by Jaideep Shah on 3/28/14.
//  Copyright (c) 2014 Jaideep Shah. All rights reserved.
//

#import "MailViewController.h"

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
        self.mailComposeDelegate = self;
        [self setSubject:@"Connectivity Doctor report"];
        [self setMessageBody:@"Report goes here" isHTML:NO];
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
