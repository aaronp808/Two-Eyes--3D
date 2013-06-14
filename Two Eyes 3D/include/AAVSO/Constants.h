//
//  Constants.h
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

#ifndef Two_Eyes_3D_Constants_h
#define Two_Eyes_3D_Constants_h

// Server Response Keys
extern NSString *const kServerErrorMsgKey;
extern NSString *const kServerErrorCodeKey;
extern NSString *const kServerStatusKey;
extern NSString *const kServerStatusError;
extern NSString *const kServerStatusSuccess;

// NSUserDefaults Keys
extern NSString *const kAppInitializedKey;
extern NSString *const kAppVersionKey;
extern NSString *const kLocalQuizVersionKey;
extern NSString *const kPinCodeKey;
extern NSString *const kAppAuthorizedKey;
extern NSString *const kSessionInProgressKey;
extern NSString *const kFinishedSessionsKey;

// Alert View Copy
extern int const kAlertAcceptIndex;
extern NSString *const kAlertLockTitle;
extern NSString *const kAlertLockCopy;
extern NSString *const kAlertTimesUpTitle;
extern NSString *const kAlertTimesUpCopy;
extern NSString *const kAlertResetTitle;
extern NSString *const kAlertResetCopy;

// Filesystem Keys
extern NSString *const kSessionsFolderKey;

// JSON Quiz Data Keys
extern NSString *const kQuizVersionKey;
extern NSString *const kQuizStatusKey;
extern NSString *const kQuizQuizKey;
extern NSString *const kQuizErrorKey;
// JSON Quiz Status Options
extern NSString *const kQuizStatusSuccess;
extern NSString *const kQuizStatusError;

// Radio Control Setup String
extern NSString *const kRadioPositionTop;
extern NSString *const kRadioPositionBottom;
extern NSString *const kRadioPositionLeft;
extern NSString *const kRadioPositionRight;
extern NSString *const kRadioLayoutHorizontal;
extern NSString *const kRadioLayoutVertical;
// Radio Button State Image Names
extern NSString *const kRadioStateOn;
extern NSString *const kRadioStateOff;

@interface Constants : NSObject 

@end

#endif
