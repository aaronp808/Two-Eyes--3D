//
//  IntermissionViewController.m
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

#import "IntermissionViewController.h"
#import "TestViewController.h"
#import "QuizManager.h"
#import "CWPinEntry.h"

@implementation IntermissionViewController
@synthesize manager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    beginButton.enabled = NO;
    
    // Create Pin Number Entry Component
    pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    [pinEntry setPinNum:kPinCode];
    [self.view addSubview:pinEntry];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinAuthorizedNotification:) 
                                                 name:kCWPinEntryAuthorizedNotif object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinUnauthorizedNotification:) 
                                                 name:kCWPinEntryUnauthorizedNotif object:self.view.window];
    
    // Setup timer.
    timeLimit = [[manager quizManager] getIntermissionTime];
    LogDebug(@"Intermission Seconds: %d", timeLimit);
    intermissionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStep:) userInfo:nil repeats:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [intermissionTimer invalidate];
    intermissionTimer = nil;
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    beginButton = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

#pragma mark -
#pragma mark Transition Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TestViewController *testVC = [segue destinationViewController];
    testVC.manager = manager;
}

#pragma mark -
#pragma mark Timer Handler

- (void)timerStep:(NSTimer *)timer {
    currentTime++;
    if (currentTime >= timeLimit) {
        [intermissionTimer invalidate];
        beginButton.enabled = YES;
    }
}

#pragma mark -
#pragma mark Button Handler

- (IBAction)beginButtonTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [intermissionTimer invalidate];
    LogDebug(@"QuizKey: %@", [[manager quizManager] getQuizKeyAtIndex:[[manager quizManager] getMovieIndex]]);
    [[manager quizManager] setQuizKey:[[manager quizManager] getQuizKeyAtIndex:[[manager quizManager] getMovieIndex]]];
    [[manager quizManager] startQuizWithKey:[[manager quizManager] getQuizKey]];
    [self performSegueWithIdentifier:@"IntermissionToTestSegue" sender:self];
}

#pragma mark -
#pragma mark Pin Entry Handler

- (void)PinAuthorizedNotification:(NSNotification *)notification {
    beginButton.enabled = YES;
}

- (void)PinUnauthorizedNotification:(NSNotification *)notification {
    LogDebug(@"Pin Entry Unauthorized!");
}

@end
