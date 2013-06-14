//
//  Config.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/29/12.
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

#import "Config.h"

@implementation Config

// Motion Data
float const kMotionUpdateInterval = 1.0f / 30.0f;

// This is the administrator pin code, must be 4 digits.
#warning A four digit code is required for administrative functions in app.
NSString *const kPinCode = @"";

// This is the session data zip password.
#warning Set the password used to zip test data.
NSString *const kZipPassword = @"";

// Server username.
#warning Set the server-side username for uploading test data.
NSString *const kServerUsername = @"";

// Server password.
#warning Set the server-side password for uploading test data.
NSString *const kServerPassword = @"";

// Quiz request parameters.
NSString *const kRequestVersion = @"version";

// Upload parameters.
NSString *const kUploadChecksum = @"checksum";
NSString *const kUploadResult = @"result";

// Whether or not a remote quiz should be loaded.
BOOL const kLoadRemoteQuiz = YES;

// Whether or not to use the debug web service instead of production.
BOOL const kUseDebugRemote = NO;

// The production URL to query for the remote quiz.
#warning The https url to the server-side scripts for handling uploads.
NSString *const kRemoteReachabilityHost = @"...";
NSString *const kRemoteQuizUrl = @"https://.../request_quiz.php";
NSString *const kRemoteUploadUrl = @"https://.../upload_result.php";

// The debug URL to query for the remote quiz.
#warning The https url to the debug server-side scripts for handling uploads.
NSString *const kDebugReachabilityHost = @"...";
NSString *const kDebugQuizUrl = @"https://.../request_quiz.php";
NSString *const kDebugUploadUrl = @"https://.../upload_result.php";

// The hardcoded quiz JSON file.
#warning Change this to the hardcoded name of the included quiz you want to use.
NSString *const kQuizName = @"example_quiz.json";

@end