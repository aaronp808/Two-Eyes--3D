//
//  SurveySetupViewController.m
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

#import "SurveySetupViewController.h"
#import "DemographicsViewController.h"
#import "UnlockViewController.h"
#import "CWRadioButtonGroup.h"
#import "CWRadioButtonOptions.h"
#import "Constants.h"
#import "QuizManager.h"
#import "CWPinEntry.h"

@implementation SurveySetupViewController
@synthesize manager;

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Initialize values.
    startButton.enabled = NO;
    movieSelected = NO;
    typeSelected = NO;
    movieId = -1;
    typeId = -1;
    
    // Set the question labels.
    movieLabel.text = @"Which movie are they watching?";
    typeLabel.text = @"What type of movie is it?";
    
    // Create radio options for radio control.
    CWRadioButtonOptions *radioOptions = [[CWRadioButtonOptions alloc] init];
    radioOptions.fontName = @"HelveticaNeue-Light";
    radioOptions.fontSize = 25;
    radioOptions.textColor = @"0x000000ff";
    radioOptions.radioPosition = positionLeft;
    radioOptions.radioDistance = 20;
    radioOptions.itemLayout = layoutVertical;
    radioOptions.itemBuffer = 16;
    radioOptions.itemsUntilWrap = 0;
    radioOptions.itemMaxDimension = CGSizeMake(800, 150);
    radioOptions.radioOrigin = CGPointMake(90, 240);
    radioOptions.radioOnName = kRadioStateOn;
    radioOptions.radioOffName = kRadioStateOff;
    
    // Create radio object for movie selection.
    movieSelect = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
    for (int i = 0; i < [[manager quizManager] getMovieTotal] ; ++i) {
        [movieSelect addTextButton:[[manager quizManager] getMovieTitleAtIndex:i]];
    }
    [[self view] addSubview:movieSelect];
    
    // Create radio object for type selected, use same options just update origin.
    typeSelect = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
    [typeSelect setOrigin:CGPointMake(90, 454)];
    for (int i = 0; i < [[manager quizManager] getMovieTypeTotal] ; ++i) {
        [typeSelect addTextButton:[[manager quizManager] getMovieTypeAtIndex:i]];
    }
    [[self view] addSubview:typeSelect];
    
    // Listen for and handle radio button tapped event.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRadioTappedNotification:) 
                                                 name:kCWRadioButtonTapped
                                               object:nil];
    
    // Setup Pin Number Entry Component
    pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    [pinEntry setPinNum:kPinCode];
    [self.view addSubview:pinEntry];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinAuthorizedNotification:) 
                                                 name:kCWPinEntryAuthorizedNotif object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinUnauthorizedNotification:) 
                                                 name:kCWPinEntryUnauthorizedNotif object:self.view.window];
    
    // Set Quiz version
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(QuizUpdated:) 
                                                 name: kQuizUpdatedNotif object:self.view.window];
    versionLabel.text = [NSString stringWithFormat:@"v%@", [manager getQuizVersion]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"SurveySetupViewControllerSegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"DemographicViewControllerSegue"]) {
        DemographicsViewController *demoVC = [segue destinationViewController];
        demoVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"SurveyToLockSegue"]) {
        UnlockViewController *unlockVC = [segue destinationViewController];
        unlockVC.manager = manager;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    [movieSelect removeFromSuperview];
    movieSelect = nil;
    [typeSelect removeFromSuperview];
    typeSelect = nil;
    versionLabel = nil;
    startButton = nil;
    movieLabel = nil;
    typeLabel = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

#pragma mark -
#pragma mark Event Handlers

- (void)QuizUpdated:(NSNotification *)notification {
    versionLabel.text = [NSString stringWithFormat:@"v%@", [manager getQuizVersion]];
}

- (void)receiveRadioTappedNotification:(NSNotification *)notification {
    if ([notification object] == movieSelect) {
        movieSelected = YES;
        movieId = [[[notification userInfo] valueForKey:kCWRadioIndexKey] intValue];
    } else if ([notification object] == typeSelect) {
        typeSelected = YES;
        typeId = [[[notification userInfo] valueForKey:kCWRadioIndexKey] intValue];
    }
    if (movieSelected && typeSelected) {
        startButton.enabled = YES;
    }
}

- (IBAction)startButtonTapped:(id)sender {
    startButton.enabled = NO;
    [[manager session] saveSurvey:[NSNumber numberWithInt:movieId] typeId:[NSNumber numberWithInt:typeId]];
    [[manager quizManager] setMovieIndex:movieId];
    LogDebug(@"QuizKey: %@", [[manager quizManager] getQuizKeyAtIndex:movieId]);
    [[manager quizManager] setMovieLength:[[manager quizManager] getMovieLengthAtIndex:movieId]];
    [self performSegueWithIdentifier:@"DemographicViewControllerSegue" sender:self];
}

#pragma mark -
#pragma mark Pin Entry Handler

- (void)PinAuthorizedNotification:(NSNotification *)notification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertLockTitle
                                                        message:kAlertLockCopy
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (void)PinUnauthorizedNotification:(NSNotification *)notification {
    LogDebug(@"Pin Entry Unauthorized!");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    alertView.delegate = nil;

    if ([alertView.title isEqualToString:kAlertLockTitle]) {
        if (buttonIndex == kAlertAcceptIndex) {
            [manager resetApp];
            [manager setAppAuthorized:NO];
            [self performSegueWithIdentifier:@"SurveyToLockSegue" sender:self];
        }
    }
}

@end
