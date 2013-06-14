//
//  DataManager.h
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

#import <Foundation/Foundation.h>
#import "SessionData.h"
#import "SessionUpload.h"
#import "QuizLoad.h"

@class CMMotionManager;
@class QuizLoad;
@class QuizManager;

extern NSString *const kQuizUpdatedNotif;
extern NSString *const kSessionsUploadedNotif;
extern NSString *const kSessionsUploadedKey;
extern NSString *const kReachabilityNotif;
extern NSString *const kReachableKey;

typedef enum {
    kReachableState,
    kUnreachableState,
    kUnknownState
} ReachabilityState;

@interface DataManager : NSObject <QuizLoadDelegate, SessionUploadDelegate> {
    id delegate;
    CMMotionManager *motionManager;
    NSUserDefaults *appPreferences;
    QuizLoad *quizLoad;
    QuizManager *quizManager;
    SessionData *sessionData;
    NSString *errorMsg;
    ReachabilityState reachableState;
}

@property (nonatomic, assign) ReachabilityState reachableState;

- (void)startDataManager;

// Preference Helpers
- (void)setDelegate:(id)delegate;
- (BOOL)getAppInitialized;
- (void)setAppVersion:(NSString *)version;
- (NSString *)getAppVersion;
- (void)setQuizVersion:(NSString *)version;
- (NSString *)getQuizVersion;
- (void)setAppAuthorized:(BOOL)isAuthorized;
- (BOOL)getAppAuthorized;
- (void)saveSessionInProgress:(NSString *)path;
- (NSString *)getSessionInProgress;
- (void)clearSessionInProgress;
- (void)addSavedSession:(NSString *)path withUuid:(NSString *)uuid;
- (NSDictionary *)getSavedSessions;
- (void)removeSavedSessionWithUuid:(NSString *)uuid;

// Data and Manager Getters
- (CMMotionManager *)motionManager;
- (SessionData *)session;
- (QuizManager *)quizManager;

// Private Methods
- (BOOL)loadPreferences;
- (BOOL)loadQuiz;
- (void)resetApp;
- (void)initializeReachability;
- (void)reachabilityChanged:(NSNotification *)notification;
- (BOOL)firstStartInit;
- (BOOL)updateDataModel:(NSString *)oldVersion newVersion:(NSString *)newVersion;
- (BOOL)saveQuiz:(NSDictionary *)quiz;
- (BOOL)checkAndCreateQuiz;
- (BOOL)validateJsonQuiz:(NSDictionary *)aQuiz;
- (void)processQuizObject:(NSDictionary *)aQuiz;
- (BOOL)sessionMaintenence;
- (void)uploadSavedSessions;
- (void)displayAlert:(NSString *)title message:(NSString *)message;

// Static Methods
+ (void)logDirContentsAtPath:(NSString *)path;
+ (NSString *)getDocPath;
+ (BOOL)fileExistsAtAbsolutePath:(NSString *)filepath;
+ (BOOL)directoryExistsAtAbsolutePath:(NSString *)path; 
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end

@interface NSObject(DataManagerDelegate)

- (void)dataManagerDidFinishInitializing:(DataManager *)aDataManager;
- (void)dataManager:(DataManager *)aDataManager didFailWithFatalError:(NSString *)aErrorStr;

@end
