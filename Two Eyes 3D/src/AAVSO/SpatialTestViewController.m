//
//  SpatialTestViewController.m
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

#import <CoreMotion/CoreMotion.h>
#import "SpatialTestViewController.h"
#import "SurveySetupViewController.h"
#import "TestViewController.h"
#import "CWRadioButtonGroup.h"
#import "SpatialResultVO.h"
#import "QuizManager.h"
#import "CWPinEntry.h"

@implementation SpatialTestViewController
@synthesize manager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize values.
    result = [[SpatialResultVO alloc] init];
    [result setQuestionId:[[manager quizManager] getQuestionId]];
    [result setType:[[manager quizManager] getQuestionType]];
    timeLimit = 0;
    currentTime = 0;
    nextButton.enabled = NO;
    answerSelected = NO;
    answerId = [[NSNumber alloc] initWithInt:-1];

    // Set the Progress label.
    progressLabel.text = [NSString stringWithFormat:@"PROGRESS: %d/%d", [[[manager quizManager] getQuestionId] intValue] + 1, [[manager quizManager] getQuizTotal]];
    
    // Set the Attribution.
    attributionLabel.text = [[manager quizManager] getQuestionAttribution];
    
    // Get the Question Image.
    questionImage = [[manager quizManager] getSpatialQuestionImage];
    // Make sure it isn't nil.
    if (questionImage) {
        [[self view] addSubview:questionImage];
    }
    
    // If it's a radio selection control, set it up.
    if (([[manager quizManager] getQuestionType] == kRadioImage) || ([[manager quizManager] getQuestionType] == kRadioText)) {
        CWRadioButtonOptions *radioOptions = [[manager quizManager] getRadioOptions];

        // Create radio object for type selected, use same options just update origin.
        radioQuestion = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
        
        // Get an array of generated radio choices.
        NSArray *choices = [[manager quizManager] getRadioChoicesWithOptions:radioOptions];
        
        // Add them to the radio selector component.
        for (CWRadioButtonChoice *choice in choices) {
            [radioQuestion addChoice:choice];
        }
        [[self view] addSubview:radioQuestion];
        
        // Listen for and handle radio button tapped event.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveRadioTappedNotification:) 
                                                     name:kCWRadioButtonTapped
                                                   object:nil];
    }
    
    // Setup Pin Number Entry Component
    pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    [pinEntry setPinNum:kPinCode];
    [self.view addSubview:pinEntry];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinAuthorizedNotification:) 
                                                 name:kCWPinEntryAuthorizedNotif object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinUnauthorizedNotification:) 
                                                 name:kCWPinEntryUnauthorizedNotif object:self.view.window];
    
    // Start listening for motion data.
    if ([[manager motionManager] isDeviceMotionActive]) {
        [[manager motionManager] stopDeviceMotionUpdates];
    }
    [[manager motionManager] startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
        [self handleMotionData:data];
    }];
    
    // Setup timer.
    timeLimit = [[manager quizManager] getSpatialTimeLimitSeconds];
    quizTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStep:) userInfo:nil repeats:YES];
    [result setStartTime];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [quizTimer invalidate];
    quizTimer = nil;
    progressLabel = nil;
    headingText = nil;
    attributionLabel = nil;
    shadowLine = nil;
    nextButton = nil;
    [radioQuestion removeFromSuperview];
    radioQuestion = nil;
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    self.manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

#pragma mark -
#pragma mark Question Selection Notification

- (void)receiveRadioTappedNotification:(NSNotification *)notification {
    answerSelected = YES;
    answerId = [[notification userInfo] valueForKey:kCWRadioIndexKey];
    [result setAnswerId:answerId];
    LogDebug(@"Answer Id: %d", [[result answerId] intValue]);
    nextButton.enabled = YES;
}

#pragma mark -
#pragma mark Timer Handler

- (void)timerStep:(NSTimer *)timer {
    currentTime++;
    if (currentTime >= timeLimit) {
        [quizTimer invalidate];
        quizTimer = nil;
        [radioQuestion setEnabled:NO];
        [result setEndTime];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertTimesUpTitle message:kAlertTimesUpCopy delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark Motion Handling

- (void)handleMotionData:(CMDeviceMotion *)data {
    [result saveAttitude:data.attitude];
    [result saveUserAcceleration:data.userAcceleration];
}

#pragma mark -
#pragma mark Button Handler

- (IBAction)nextButtonTapped:(id)sender {
    [radioQuestion setEnabled:NO];
    [quizTimer invalidate];
    [result setEndTime];
    [self nextQuestion];
}

#pragma mark -
#pragma mark Transition Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SpatialToSurveySegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"TestViewControllerSegue"]) {
        TestViewController *testVC = [segue destinationViewController];
        testVC.manager = manager;
    }
}

- (void)nextQuestion {
    if ([[manager motionManager] isDeviceMotionActive]) {
        [[manager motionManager] stopDeviceMotionUpdates];
    }
    // Save the results.
    [[manager session] saveSpatialResult:result];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[manager quizManager] nextSpatialQuestion:(timeLimit - currentTime)]) {
        
        // Manually handle transition.
        SpatialTestViewController *destVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"SpatialTestViewController"];
        destVC.manager = manager;  
        [self.view.superview addSubview:destVC.view];
        self.view.frame = CGRectMake(0, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
        destVC.view.frame = CGRectMake(destVC.view.frame.size.width, destVC.view.frame.origin.y, destVC.view.frame.size.width, destVC.view.frame.size.height);
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.view.frame = CGRectMake(-self.view.frame.size.width, self.view.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height);
                             destVC.view.frame = CGRectMake(0, destVC.view.frame.origin.y, destVC.view.frame.size.width, destVC.view.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             [self.navigationController setViewControllers:[NSArray arrayWithObject:destVC] animated:NO];
                         }];
    } else {
        [[manager quizManager] endSpatialQuiz];
        LogDebug(@"QuizKey: %@", [[manager quizManager] getQuizKeyAtIndex:[[manager quizManager] getMovieIndex]]);
        [[manager quizManager] setQuizKey:[[manager quizManager] getQuizKeyAtIndex:[[manager quizManager] getMovieIndex]]];
        [[manager quizManager] startQuizWithKey:[[manager quizManager] getQuizKey]];
        [self performSegueWithIdentifier:@"TestViewControllerSegue" sender:self];
    }
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

#pragma mark -
#pragma mark Alert View Handler

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertView.delegate = nil;
    
    if ([alertView.title isEqualToString:kAlertTimesUpTitle]) {
        [self nextQuestion];
    } else if ([alertView.title isEqualToString:kAlertResetTitle]) {
        if (buttonIndex == kAlertAcceptIndex) {
            if ([[manager motionManager] isDeviceMotionActive]) {
                [[manager motionManager] stopDeviceMotionUpdates];
            }
            [manager resetApp];
            [self performSegueWithIdentifier:@"SpatialToSurveySegue" sender:self];
        }
    }
}

@end
