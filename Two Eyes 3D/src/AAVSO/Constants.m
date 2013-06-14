//
//  Constants.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/17/12.
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

#import "Constants.h"

@implementation Constants

// Server Response Keys
NSString *const kServerErrorMsgKey = @"error_msg";
NSString *const kServerErrorCodeKey = @"error_code";
NSString *const kServerStatusKey = @"status";
NSString *const kServerStatusError = @"error";
NSString *const kServerStatusSuccess = @"success";
// JSON Quiz Data Keys
NSString *const kQuizVersionKey = @"version";
NSString *const kQuizQuizKey = @"quiz";

// NSUserDefaults Keys
NSString *const kAppInitializedKey = @"app_initialized";
NSString *const kAppVersionKey = @"app_version";
NSString *const kLocalQuizVersionKey = @"quiz_version";
NSString *const kPinCodeKey = @"pin_code";
NSString *const kAppAuthorizedKey = @"app_authorized";
NSString *const kSessionInProgressKey = @"session_in_progress";
NSString *const kFinishedSessionsKey = @"finished_sessions";

// Alert View Copy
int const kAlertAcceptIndex = 1;
NSString *const kAlertLockTitle = @"Deauthorize App";
NSString *const kAlertLockCopy = @"Would you like to lock the app?";
NSString *const kAlertTimesUpTitle = @"Time's Up!";
NSString *const kAlertTimesUpCopy = @"Hit OK to begin the knowledge quiz.";
NSString *const kAlertResetTitle = @"Reset Quiz";
NSString *const kAlertResetCopy = @"Would you like to start a new quiz session?";

// Filesystem Keys
NSString *const kSessionsFolderKey = @"Sessions";

// Radio Control Setup String
NSString *const kRadioPositionTop = @"top";
NSString *const kRadioPositionBottom = @"bottom";
NSString *const kRadioPositionLeft = @"left";
NSString *const kRadioPositionRight = @"right";
NSString *const kRadioLayoutHorizontal = @"horizontal";
NSString *const kRadioLayoutVertical = @"vertical";
// Radio Button State Image Names
NSString *const kRadioStateOn = @"RadioButtonSelected.png";
NSString *const kRadioStateOff = @"RadioButtonUnselected.png";

@end