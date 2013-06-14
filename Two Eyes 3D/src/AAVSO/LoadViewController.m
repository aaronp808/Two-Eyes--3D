//
//  LoadViewController.m
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

#import "LoadViewController.h"
#import "UnlockViewController.h"
#import "SurveySetupViewController.h"


@implementation LoadViewController
@synthesize manager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loadingLabel.alpha = 0;
    loadWheel.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    if ([manager getSavedSessions] && ([[manager getSavedSessions] count] > 0)) {
        if ([manager reachableState] == kUnknownState) {
            // Listen for reachability so we can potentially upload completed sessions.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) 
                                                         name:kReachabilityNotif object:manager];
            // Timer to move on in case there's no reachability response.
            timeout = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerComplete:) userInfo:nil repeats:NO];
            return;
        } else if ([manager reachableState] == kReachableState) {
            [self loadSessions];
            return;
        }
    }
    [self nextScreen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SetupSurveyViewControllerSegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"UnlockViewControllerSegue"]) {
        UnlockViewController *unlockVC = [segue destinationViewController];
        unlockVC.manager = manager;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timeout invalidate];
    timeout = nil;
    loadingLabel = nil;
    loadWheel = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

#pragma mark -
#pragma mark Private Methods

- (void)nextScreen {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([manager getAppAuthorized]) {
        LogInfo(@"App is authorized");
        [self performSegueWithIdentifier:@"SetupSurveyViewControllerSegue" sender:self];
    } else {
        LogInfo(@"App has not been authorized yet.");
        [self performSegueWithIdentifier:@"UnlockViewControllerSegue" sender:self];
    }
}

#pragma mark -
#pragma mark Notification Handlers

- (void)reachabilityChanged:(NSNotification *)notification {
    [timeout invalidate];
    if ([[[notification userInfo] valueForKey:kReachableKey] boolValue]) {
        [self loadSessions];
    } else {
        LogInfo(@"Server not available, not attempting to upload saved sessions.");
        [self nextScreen];
    }
}

- (void)loadSessions {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUploadComplete:) 
                                                 name:kSessionsUploadedNotif object:manager];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         loadingLabel.alpha = 1;
                         loadWheel.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [manager uploadSavedSessions];
                     }];
}

- (void)sessionUploadComplete:(NSNotification *)notification {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         loadingLabel.alpha = 0;
                         loadWheel.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self nextScreen];
                     }];
}

- (void)timerComplete:(NSTimer *)timer {
    [timer invalidate];
    [self nextScreen];
}

@end
