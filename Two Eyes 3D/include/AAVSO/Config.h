//
//  Config.h
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

#ifndef Two_Eyes_3D_Config_h
#define Two_Eyes_3D_Config_h

// Macro for retrieving a background queue.
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// Motion Data
float const kMotionUpdateInterval;

// This is the administrator pin code, must be 4 digits.
extern NSString *const kPinCode;

// This is the session data zip password.
extern NSString *const kZipPassword;

// Server username.
extern NSString *const kServerUsername;

// Server password.
extern NSString *const kServerPassword;

// Quiz request parameters.
extern NSString *const kRequestVersion;

// Upload parameters.
extern NSString *const kUploadChecksum;
extern NSString *const kUploadResult;

// Whether or not a remote quiz should be loaded.
extern BOOL const kLoadRemoteQuiz;

// Whether or not to use the debug web service instead of production.
extern BOOL const kUseDebugRemote;

// The production URL to query for the remote quiz.
extern NSString *const kRemoteReachabilityHost;
extern NSString *const kRemoteQuizUrl;
extern NSString *const kRemoteUploadUrl;

// The debug URL to query for the remote quiz.
extern NSString *const kDebugReachabilityHost;
extern NSString *const kDebugQuizUrl;
extern NSString *const kDebugUploadUrl;

// The hardcoded quiz JSON file.
extern NSString *const kQuizName;

@interface Config : NSObject 

@end

#endif
