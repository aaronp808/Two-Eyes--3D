//
//  TestViewController.m
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
#import "TestViewController.h"
#import "IntermissionViewController.h"
#import "SurveySetupViewController.h"
#import "ThankYouViewController.h"
#import "CWRadioButtonOptions.h"
#import "QuizResultVO.h"
#import "CWRadioButtonGroup.h"
#import "QuizManager.h"
#import "ExplainView.h"
#import "DrawView.h"
#import "DrawOptions.h"
#import "CWPinEntry.h"

@implementation TestViewController
@synthesize manager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize values.
    result = [[QuizResultVO alloc] init];
    [result setQuestionId:[[manager quizManager] getQuestionId]];
    [result setType:[[manager quizManager] getQuestionType]];
    [result setRound:[[NSNumber alloc] initWithInt:[[manager quizManager] getRound]]];
    nextButton.enabled = NO;
    nextPressed = NO;
    answerSelected = NO;
    answerId = [[NSNumber alloc] initWithInt:-1];
    
    // Set the Progress label.
    progressLabel.text = [NSString stringWithFormat:@"PROGRESS: %d/%d", [[[manager quizManager] getQuestionId] intValue] + 1, [[manager quizManager] getQuizTotal]];
    
    // Set the Question text.
    NSString *qText = [[manager quizManager] getQuestionText];
    questionText.text = qText;
    // Calculate fontsize until it fits.
    for (int i = questionText.font.pointSize; i > 10; i = i - 2) {
        questionText.font = [questionText.font fontWithSize:i];
        
        CGSize constraint = CGSizeMake(questionText.frame.size.width, MAXFLOAT);
        CGSize labelSize = [qText sizeWithFont:questionText.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        if (labelSize.height <= questionText.frame.size.height) {
            CGRect frame = questionText.frame;
            [questionText setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, labelSize.height)];
            break;
        }
    }
    // Update the position of the shadow line.
    CGRect frame = shadowLine.frame;
    [shadowLine setFrame:CGRectMake(frame.origin.x, questionText.frame.origin.y + questionText.frame.size.height + 20, frame.size.width, frame.size.height)];
    
    // Set the Attribution.
    attributionLabel.text = [[manager quizManager] getQuestionAttribution];
    
    float explainX = 0;
    // If it's a radio selection control, set it up.
    if (([[manager quizManager] getQuestionType] == kRadioImage) || ([[manager quizManager] getQuestionType] == kRadioText)) {
        CWRadioButtonOptions *radioOptions = [[manager quizManager] getRadioOptions];

        // Create radio object for type selected, use same options just update origin.
        radioQuestion = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
        //[radioQuestion setOrigin:CGPointMake(88, 236)];
        
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
        explainX = radioQuestion.frame.origin.x;
    } else if ([[manager quizManager] getQuestionType] == kDrawing) {
        DrawOptions *drawOptions = [[manager quizManager] getDrawingOptions];
        if (drawOptions) {
            explainX = drawOptions.origin.x + 1;
            drawView = [[DrawView alloc] initWithOptions:drawOptions];
            [self.view addSubview:drawView];
            
            drawingTouched = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(drawingChangedNotification:) 
                                                         name:kDrawingChangedNotif
                                                       object:nil];
        } else {
            LogError(@"Failed to retrieve drawing question options.");
        }
    } else {
        LogError(@"Unable to setup quiz question due to invalid question type.");
    }
    if ([[manager quizManager] hasQuestionExplain]) {
        explainView = [[ExplainView alloc] initWithOrigin:CGPointMake(explainX, 520.0f)];

        // Listen for and handle explain field started editing event.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(explainStartEditingNotification:) 
                                                     name:kExplainStartedEditing
                                                   object:nil];
        // Listen for and handle explain field stopped editing event.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(explainStopEditingNotification:) 
                                                     name:kExplainStoppedEditing
                                                   object:nil];
        // Listen for and handle explain text changed event.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(explainTextUpdateNotification:) 
                                                     name:kExplainTextChanged
                                                   object:nil];
        
        if ([[manager quizManager] getQuestionType] == kDrawing) {
            [explainView setLabel:@"Please explain:"];
        } else {
            [explainView setLabel:@"Please explain your choice:"];
        }
        [self.view addSubview:explainView];
    }
    
    // Setup Pin Number Entry Component
    pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    [pinEntry setPinNum:kPinCode];
    [self.view addSubview:pinEntry];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinActiveNotification:) 
                                                 name:kCWPinEntryActiveNotif object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinCompleteNotification:) 
                                                 name:kCWPinEntryCompleteNotif object:self.view.window];
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
    
    [result setStartTime];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (explainView) {
        [explainView removeFromSuperview];
        explainView = nil;
    }
    if (drawView) {
        [drawView removeFromSuperview];
        drawView = nil;
    }
    progressLabel = nil;
    questionText = nil;
    attributionLabel = nil;
    shadowLine = nil;
    nextButton = nil;
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    self.manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

- (BOOL)requiredInputReceived {
    if (([[manager quizManager] getQuestionType] == kRadioImage) || ([[manager quizManager] getQuestionType] == kRadioText)) {
        if (answerSelected) {
            return YES;
        }
    } else if ([[manager quizManager] getQuestionType] == kDrawing) {
        return drawingTouched;
    }
    return NO;
}

#pragma mark -
#pragma mark Notification Handling

- (void)receiveRadioTappedNotification:(NSNotification *)notification {
    answerSelected = YES;
    answerId = [[notification userInfo] valueForKey:kCWRadioIndexKey];
    [result setAnswerId:answerId];
    LogDebug(@"Answer Id: %d", [[result answerId] intValue]);
    nextButton.enabled = YES;
}

- (void)explainStartEditingNotification:(NSNotification *)notification {
    radioQuestion.enabled = NO;
    pinEntry.enabled = NO;
}

- (void)explainStopEditingNotification:(NSNotification *)notification {
    if (nextPressed) {
        [self nextButtonTapped:nextButton];
    } else {
        radioQuestion.enabled = YES;
        pinEntry.enabled = YES;
    }
}

- (void)explainTextUpdateNotification:(NSNotification *)notification {
    result.explanation = [[notification userInfo] valueForKey:kExplainTextKey];
}

- (void)drawingChangedNotification:(NSNotification *)notification {
    drawingTouched = YES;
    nextButton.enabled = YES;
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
    if (explainView.editing) {
        [explainView stopEditing];
        nextPressed = YES;
    } else {
        [radioQuestion setEnabled:NO];
        [result setEndTime];
        [self nextQuestion];
    }
}

#pragma mark -
#pragma mark Transition Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"TestToIntermissionSegue"]) {
        IntermissionViewController *intermissionVC = [segue destinationViewController];
        intermissionVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"TestToThanksSegue"]) {
        ThankYouViewController *thanksVC = [segue destinationViewController];
        thanksVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"TestToSurveySegue"]) {
        SurveySetupViewController *surveyVC = [segue destinationViewController];
        surveyVC.manager = manager;
    }
}

- (void)nextQuestion {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[manager motionManager] isDeviceMotionActive]) {
        [[manager motionManager] stopDeviceMotionUpdates];
    }
    
    // Save the results.
    if ([[manager quizManager] hasQuestionExplain]) {
        [result setExplanation:[explainView explainText]];
    }
    if (result.type == kDrawing) {
        result.drawingData = drawView.drawRecording;
        if ([drawView.drawingImage image] != nil) {
            result.drawingImage = [drawView.drawingImage image];
        } else {
            LogError(@"Drawing image is nil!");
            result.drawingImage = [drawView.backgroundImage image];
        }
    }
    [[manager session] saveQuizResult:result];

    if ([[manager quizManager] nextQuestion]) {
        // Manually handle transition.
        TestViewController *destVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"TestViewController"];
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
        [[manager quizManager] endQuiz];
        if ([[manager quizManager] getRound] == 1) {
            [self performSegueWithIdentifier:@"TestToIntermissionSegue" sender:self];
        } else if ([[manager quizManager] getRound] == 2) {
            [self performSegueWithIdentifier:@"TestToThanksSegue" sender:self];
        } else {
            LogError(@"Quiz is designed to handle only two rounds of questions.");
        }
    }
}

#pragma mark -
#pragma mark Pin Entry Handler

- (void)PinActiveNotification:(NSNotification *)notification {
    if ([[manager quizManager] hasQuestionExplain]) {
        explainView.userInteractionEnabled = NO;
    }
}

- (void)PinCompleteNotification:(NSNotification *)notification {
    if ([[manager quizManager] hasQuestionExplain]) {
        explainView.userInteractionEnabled = YES;
    }
}

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
            if ([[manager motionManager] isDeviceMotionActive]) {
                [[manager motionManager] stopDeviceMotionUpdates];
            }
            [manager resetApp];
            [self performSegueWithIdentifier:@"TestToSurveySegue" sender:self];
        }
    }
}

@end
