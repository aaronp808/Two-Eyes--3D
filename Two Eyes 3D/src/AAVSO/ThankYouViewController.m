//
//  ThankYouViewController.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/16/12.
//
//  Two Eyes, 3D is software for creating quizzes that capture user input as well as
//  timing data, and motion data.
//
//  Copyright (c) 2012-2013 AAVSO. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
// details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//
// Also add information on how to contact you by electronic and paper mail.
//
// If your software can interact with users remotely through a computer network,
// you should also make sure that it provides a way for users to get its source.
// For example, if your program is a web application, its interface could
// display a “Source” link that leads users to an archive of the code.  There
// are many ways you could offer source, and different solutions will be better
// for different programs; see section 13 for the specific requirements.
//
// You should also get your employer (if you work as a programmer) or school, if
// any, to sign a “copyright disclaimer” for the program, if necessary.  For
// more information on this, and how to apply and follow the GNU AGPL, see
// http://www.gnu.org/licenses/.
//

#import <Quartzcore/Quartzcore.h>
#import <QuartzCore/CAAnimation.h>
#import "ThankYouViewController.h"
#import "SurveySetupViewController.h"
#import "CWPinEntry.h"

@implementation ThankYouViewController
@synthesize manager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loaded = NO;
    completedLabel.layer.shadowColor = [completedLabel.textColor CGColor];
    completedLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    completedLabel.layer.shadowRadius =  10.0f;
    completedLabel.layer.shadowOpacity = 0.0f;
    completedLabel.layer.masksToBounds = NO;
    loadWheel.alpha = 0.0f;
    
    // Setup Pin Number Entry Component
    pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    [pinEntry setPinNum:kPinCode];
    [self.view addSubview:pinEntry];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinAuthorizedNotification:) 
                                                 name:kCWPinEntryAuthorizedNotif object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinUnauthorizedNotification:) 
                                                 name:kCWPinEntryUnauthorizedNotif object:self.view.window];
}

- (void)viewDidLayoutSubviews {
    if (!loaded) {
        loaded = YES;
        [self completeSession];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    completedLabel = nil;
    loadWheel = nil;
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ThanksToSurveySegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)completeSession {
    [[manager session] endAppSession];
    
    dispatch_async(kBgQueue, ^(void) {
        if ([[manager session] writeSessionZip]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([manager reachableState] == kReachableState) {
                    LogDebug(@"Loading sessions...");
                    [self uploadSessions];
                } else {
                    LogDebug(@"Waiting for reachability...");
                    // Listen for reachability so we can potentially upload completed sessions.
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) 
                                                                 name:kReachabilityNotif object:manager];
                }
            });
        }
    });
}

#pragma mark -
#pragma mark Notification Handlers

- (void)reachabilityChanged:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:kReachableKey] boolValue]) {
        [self uploadSessions];
    }
}

- (void)uploadSessions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUploadComplete:) 
                                                 name:kSessionsUploadedNotif object:manager];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         loadWheel.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         LogDebug(@"Starting upload!");
                         [manager uploadSavedSessions];
                     }];
}

- (void)sessionUploadComplete:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityNotif object:nil];
    
    if (![[[notification userInfo] valueForKey:kSessionsUploadedKey] boolValue]) {
        completedLabel.layer.shadowColor = [[UIColor redColor] CGColor];
    }
    [UIView animateWithDuration:1.0f
                     animations:^{
                         loadWheel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         LogDebug(@"Finished upload!");
                     }];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.duration = 1.0f;
    [completedLabel.layer addAnimation:anim forKey:@"shadowOpacity"];
    completedLabel.layer.shadowOpacity = 1.0f;
}

#pragma mark -
#pragma mark Pin Entry Handler

- (void)PinAuthorizedNotification:(NSNotification *)notification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertResetTitle
                                                        message:kAlertResetCopy
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)PinUnauthorizedNotification:(NSNotification *)notification {
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertView.delegate = nil;
    
    if ([alertView.title isEqualToString:kAlertResetTitle]) {
        if (buttonIndex == kAlertAcceptIndex) {
            [manager resetApp];
            [self performSegueWithIdentifier:@"ThanksToSurveySegue" sender:self];
        }
    }
}

@end
