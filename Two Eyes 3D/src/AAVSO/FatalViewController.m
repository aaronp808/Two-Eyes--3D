//
//  FatalViewController.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/23/12.
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

#import "FatalViewController.h"
#import "SurveySetupViewController.h"
//#import "CWPinEntry.h"

@implementation FatalViewController
@synthesize manager;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Setup Pin Number Entry Component
    //pinEntry = [[CWPinEntry alloc] initWithOrigin:CGPointMake(18, 720)];
    //[pinEntry setPinNum:kPinCode];
    //[self.view addSubview:pinEntry];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinAuthorizedNotification:) 
    //                                             name:kCWPinEntryAuthorizedNotif object:self.view.window];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PinUnauthorizedNotification:) 
    //                                             name:kCWPinEntryUnauthorizedNotif object:self.view.window];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"FatalToSurveySegue"]) {
        SurveySetupViewController *surveySetupVC = [segue destinationViewController];
        surveySetupVC.manager = manager;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[pinEntry removeFromSuperview];
    //pinEntry = nil;
    manager = nil;
    [self.view removeFromSuperview];
    self.view = nil;
    [self removeFromParentViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Pin Entry Handler

/*- (void)PinAuthorizedNotification:(NSNotification *)notification {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAlertResetTitle
                                                        message:@"Would you like to try and reset the app?"
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
            [self performSegueWithIdentifier:@"FatalToSurveySegue" sender:self];
        }
    }
}*/

@end
