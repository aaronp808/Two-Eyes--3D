//
//  DemographicsViewController.m
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

#import "DemographicsViewController.h"
#import "SpatialTestViewController.h"
#import "SurveySetupViewController.h"
#import "QuizManager.h"
#import "CWRadioButtonGroup.h"
#import "CWRadioButtonOptions.h"
#import "Constants.h"
#import "CWPinEntry.h"

@implementation DemographicsViewController
@synthesize manager;

static int const kInputFieldHeight = 26;
static int const kInputFieldWidth = 325;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register Tap gesture for dismissing keyboard.
    offKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [offKeyboardTap setNumberOfTapsRequired:1];
    [offKeyboardTap setEnabled:NO];
    [self.view addGestureRecognizer:offKeyboardTap];
    
    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
	// Initialize values.
    beginButton.enabled = NO;
    genderSelected = NO;
    difficultySelected = NO;
    knowledgeSelected = NO;
    ageSelecting = NO;
    ageSelected = 0;
    minimumAge = 18;
    maximumAge = 100;
    ageLabel.text = @"--";
    
    // Create radio options for radio control.
    CWRadioButtonOptions *radioOptions = [[CWRadioButtonOptions alloc] init];
    radioOptions.fontName = @"HelveticaNeue-Light";
    radioOptions.fontSize = 25;
    radioOptions.textColor = @"0x000000ff";
    radioOptions.radioPosition = positionLeft;
    radioOptions.radioDistance = 20;
    radioOptions.itemLayout = layoutHorizontal;
    radioOptions.itemBuffer = 35;
    radioOptions.itemsUntilWrap = 0;
    radioOptions.itemMaxDimension = CGSizeMake(150, 100);
    radioOptions.radioOrigin = CGPointMake(436, 310);
    radioOptions.radioOnName = kRadioStateOn;
    radioOptions.radioOffName = kRadioStateOff;
    
    // Create radio object for gender selection.
    genderSelect = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
    [genderSelect addTextButton:@"Male"];
    [genderSelect addTextButton:@"Female"];
    [[self view] addSubview:genderSelect];
    
    // Create radio object for difficulty selected, use same options just update origin.
    difficultySelect = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
    [difficultySelect setOrigin:CGPointMake(90, 444)];
    [difficultySelect addTextButton:@"Yes"];
    [difficultySelect addTextButton:@"No"];
    [[self view] addSubview:difficultySelect];
    
    // Create radio object for knowledge selected, use same options just update origin.
    knowledgeSelect = [[CWRadioButtonGroup alloc] initWithOptions:radioOptions];
    [knowledgeSelect setOrigin:CGPointMake(90, 570)];
    [knowledgeSelect addTextButton:@"Very High"];
    [knowledgeSelect addTextButton:@"Medium"];
    [knowledgeSelect addTextButton:@"Low"];
    [[self view] addSubview:knowledgeSelect];
    
    // Create an age picker.
    UIViewController *ageViewController = [[UIViewController alloc] init];
    agePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 170, 140)];
    [ageViewController.view addSubview:agePickerView];
    agePickerView.delegate = self;
    agePickerView.showsSelectionIndicator = YES;
    agePopover = [[UIPopoverController alloc] initWithContentViewController:ageViewController];
    agePopover.popoverContentSize = agePickerView.frame.size;

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
    
    // Start the App Session
    [[manager session] startAppSession];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"DemoToSurveySegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    } else if ([[segue identifier] isEqualToString:@"SpatialTestViewControllerSegue"]) {
        SpatialTestViewController *spatialVC = [segue destinationViewController];
        spatialVC.manager = manager;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pinEntry removeFromSuperview];
    pinEntry = nil;
    [genderSelect removeFromSuperview];
    genderSelect = nil;
    [difficultySelect removeFromSuperview];
    difficultySelect = nil;
    [knowledgeSelect removeFromSuperview];
    knowledgeSelect = nil;
    [agePickerView removeFromSuperview];
    agePickerView.delegate = nil;
    agePickerView = nil;
    agePopover = nil;
    ageButton = nil;
    beginButton = nil;
    nameInput = nil;
    emailInput = nil;
    difficultyLabel = nil;
    knowledgeLabel = nil;
    ageLabel = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
}

#pragma mark -
#pragma mark TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    if (nameInput == aTextView) {
        if ([self validateEmail:emailInput.text valueRequired:YES] == NO) {
            nameInput.returnKeyType = UIReturnKeyNext;
        } else {
            nameInput.returnKeyType = UIReturnKeyDone;
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
    pinEntry.enabled = NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    pinEntry.enabled = YES;
    if ([nameInput isFirstResponder]) {
        [nameInput resignFirstResponder];
        if (nameInput.returnKeyType == UIReturnKeyNext) {
            [emailInput becomeFirstResponder];
            return NO;
        }
    } else if ([emailInput isFirstResponder]) {
        if ([self validateEmail:emailInput.text valueRequired:YES] == NO) {
            [emailInput setTextColor:[UIColor redColor]];
        }
        [emailInput resignFirstResponder];
    }
    beginButton.enabled = [self requiredInputReceived];
    return YES;
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString *)aText {
    if (aTextView == emailInput) {
        if ([self validateEmail:emailInput.text valueRequired:NO]) {
            [emailInput setTextColor:[UIColor blackColor]];
        }
    }
    beginButton.enabled = [self requiredInputReceived];
    
    if ([aText isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    
    NSString *newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
    CGSize strSize = [newText sizeWithFont:aTextView.font constrainedToSize:CGSizeMake(1000, 1000) lineBreakMode:UILineBreakModeWordWrap];
    
    if (strSize.height > kInputFieldHeight) { // Can't enter more text.
        return NO;
    } else if (strSize.width > kInputFieldWidth) {
        return NO; // Can't enter more text.
    } else {
        return YES; // Handle more text.
    }
}

- (BOOL)requiredInputReceived {
    if (genderSelected && difficultySelected && knowledgeSelected && ageSelected &&
        ![nameInput.text isEqualToString:@""] && [self validateEmail:emailInput.text valueRequired:YES]) {
        return YES;
    }
    return NO;
}

- (BOOL)validateEmail:(NSString *)checkString valueRequired:(BOOL)required {
    if ((required == NO) && ([checkString length] == 0)) {
        return YES;
    }
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark -
#pragma mark Event Handlers

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    if ([nameInput.text isEqualToString:@""]) {
        [nameInput becomeFirstResponder];
    } else if ([self validateEmail:emailInput.text valueRequired:NO] == NO) {
        [emailInput setTextColor:[UIColor redColor]];
        [emailInput becomeFirstResponder];
    } else {
        if ([nameInput isFirstResponder]) {
            [nameInput resignFirstResponder];
        } else if ([emailInput isFirstResponder]) {
            [emailInput resignFirstResponder];
        }
        beginButton.enabled = [self requiredInputReceived];
    }
}

- (void)receiveRadioTappedNotification:(NSNotification *)notification {
    int index = 0;
    if ([notification object] == genderSelect) {
        genderSelected = YES;
        index = [[[notification userInfo] valueForKey:kCWRadioIndexKey] intValue];
        LogDebug(@"Gender Index: %d", index);
    } else if ([notification object] == difficultySelect) {
        difficultySelected = YES;
        index = [[[notification userInfo] valueForKey:kCWRadioIndexKey] intValue];
        LogDebug(@"Difficulty Index: %d", index);
    } else if ([notification object] == knowledgeSelect) {
        knowledgeSelected = YES;
        index = [[[notification userInfo] valueForKey:kCWRadioIndexKey] intValue];
        LogDebug(@"Knowledge Index: %d", index);
    }
    beginButton.enabled = [self requiredInputReceived];
}

- (IBAction)beginButtonTapped:(id)sender {
    beginButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[manager session] saveDemographic:nameInput.text email:emailInput.text age:[NSNumber numberWithInt:ageSelected] genderId:[NSNumber numberWithInt:[genderSelect getSelected]] diffId:[NSNumber numberWithInt:[difficultySelect getSelected]] knowledgeId:[NSNumber numberWithInt:[knowledgeSelect getSelected]]];
    [[manager quizManager] startSpatialQuiz];
    [self performSegueWithIdentifier:@"SpatialTestViewControllerSegue" sender:self];
}

- (IBAction)ageButtonTapped:(id)sender {
    [agePopover presentPopoverFromRect:ageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    [offKeyboardTap setEnabled:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [offKeyboardTap setEnabled:NO];
}

#pragma mark -
#pragma mark Picker View Delegate Methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return maximumAge - minimumAge + 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 37)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25.0f];
    if (row != 0) {
        label.text = [NSString stringWithFormat:@"%d", row + minimumAge - 1];
    } else {
        label.text = @"--";
    }
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    return label;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        ageLabel.text = @"--";
        ageSelected = 0;
    } else {
        ageSelected = row + minimumAge - 1;
        ageLabel.text = [NSString stringWithFormat:@"%d", ageSelected];
        LogDebug(@"Age Selected: %d", ageSelected);
    }
    beginButton.enabled = [self requiredInputReceived];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 140;
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
            [self performSegueWithIdentifier:@"DemoToSurveySegue" sender:self];
        }
    }
}

@end
