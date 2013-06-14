//
//  DataManager.m
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

#import <sys/xattr.h>
#import <CoreMotion/CoreMotion.h>
#import "DataManager.h"
#import "QuizManager.h"
#import "QuizResultVO.h"
#import "Reachability.h"

@implementation DataManager
@synthesize reachableState = _reachableState;

NSString *const kQuizUpdatedNotif = @"quiz_updated";
NSString *const kSessionsUploadedNotif = @"sessions_upload_complete";
NSString *const kSessionsUploadedKey = @"sessions_upload_success";
NSString *const kReachabilityNotif = @"reachability_changed";
NSString *const kReachableKey = @"reachable";

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

#pragma mark -
#pragma mark Initialization

- (id)init {

    if (self = [super init]) {
        // Initialization Code
        reachableState = kUnknownState;
        
        [self initializeReachability];
        
        motionManager = [[CMMotionManager alloc] init];
        sessionData = [[SessionData alloc] init:self];
    }
    
    return self;
}

- (void)startDataManager {
    if (![self loadPreferences] || ![self loadQuiz] || ![self sessionMaintenence]) {
        [delegate dataManager:self didFailWithFatalError:errorMsg];
    } else {
        [delegate dataManagerDidFinishInitializing:self];
    }
}

#pragma mark -
#pragma mark App Preference Methods

- (BOOL)getAppInitialized {
    return [appPreferences boolForKey:kAppInitializedKey];
}

- (void)setAppVersion:(NSString *)version {
    [appPreferences setObject:version forKey:kAppVersionKey];
    [appPreferences synchronize];
}

- (NSString *)getAppVersion {
    return [appPreferences stringForKey:kAppVersionKey];
}

- (void)setQuizVersion:(NSString *)version {
    [appPreferences setObject:version forKey:kLocalQuizVersionKey];
    [appPreferences synchronize];
}

- (NSString *)getQuizVersion {
    return [appPreferences stringForKey:kLocalQuizVersionKey];
}

- (void)setAppAuthorized:(BOOL)isAuthorized {
    [appPreferences setBool:isAuthorized forKey:kAppAuthorizedKey];
    [appPreferences synchronize];
}

- (BOOL)getAppAuthorized {
    return [appPreferences boolForKey:kAppAuthorizedKey];
}

- (void)saveSessionInProgress:(NSString *)path {
    [appPreferences setObject:path forKey:kSessionInProgressKey];
    [appPreferences synchronize];
}

- (NSString *)getSessionInProgress {
    return [appPreferences stringForKey:kSessionInProgressKey];
}

- (void)clearSessionInProgress {
    [appPreferences removeObjectForKey:kSessionInProgressKey];
}

- (void)addSavedSession:(NSString *)path withUuid:(NSString *)uuid {
    NSDictionary *savedSessions = [appPreferences dictionaryForKey:kFinishedSessionsKey];
    NSMutableDictionary *newSessions = [[NSMutableDictionary alloc] init];
    
    if (savedSessions != nil) {
        [newSessions addEntriesFromDictionary:savedSessions];
    }
    [newSessions setObject:path forKey:uuid];
    [appPreferences setObject:newSessions forKey:kFinishedSessionsKey];
    [appPreferences synchronize];
}

- (NSDictionary *)getSavedSessions {
    return [appPreferences dictionaryForKey:kFinishedSessionsKey];
}

- (void)removeSavedSessionWithUuid:(NSString *)uuid {
    NSDictionary *savedSessions = [appPreferences dictionaryForKey:kFinishedSessionsKey];
    NSMutableDictionary *newSessions = [[NSMutableDictionary alloc] init];
    [newSessions addEntriesFromDictionary:savedSessions];
    
    NSString *path = [newSessions objectForKey:uuid];
    if ([DataManager fileExistsAtAbsolutePath:path]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            LogWarn(@"Failed to remove session data at: %@", path);
        }
    } else {
        LogWarn(@"Can't find session data to remove: %@", uuid);
    }
    [newSessions removeObjectForKey:uuid];
    
    [appPreferences setObject:newSessions forKey:kFinishedSessionsKey];
    [appPreferences synchronize];
}

#pragma mark -
#pragma mark Object Getters

- (CMMotionManager *)motionManager {
    return motionManager;
}

// Get the current session.
- (SessionData *)session {
    return sessionData;
}

- (QuizManager *)quizManager {
    return quizManager;
}

#pragma mark -
#pragma mark Private Methods

#pragma mark -
#pragma mark Initialization

- (BOOL)loadPreferences {
    appPreferences = [NSUserDefaults standardUserDefaults];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    if (([appPreferences objectForKey:kAppInitializedKey] != nil) && [self getAppInitialized]) {
        if ([version isEqualToString:[self getAppVersion]]) {
            LogDebug(@"App Versions are equal: %@", [self getAppVersion]);
        } else {
            LogInfo(@"App Version update detected, starting data model update...");
            return [self updateDataModel:[self getAppVersion] newVersion:version];
            LogInfo(@"Update complete!");
        }
    } else {
        LogInfo(@"Fresh application install detected.");
        [self setAppVersion:version];
        return [self firstStartInit];
    }
    return YES;
}

- (BOOL)loadQuiz {
    quizLoad = [[QuizLoad alloc] init];
    [quizLoad setDelegate:self];
    
    if ([self loadAndParseFile:[[DataManager getDocPath] stringByAppendingPathComponent:kQuizName]] == NO) {
        errorMsg = @"Failed to parse locally stored quiz.";
        LogError(errorMsg);
        return NO;
    }

    if (kLoadRemoteQuiz) {
        if (kUseDebugRemote) {
            LogInfo(@"Requesting latest quiz from debug webservice.");
            LogWarn(@"***Turn off kUseDebugRemote before production!***");
            [quizLoad requestLatestQuiz:[self getQuizVersion]];
        } else {
            LogInfo(@"Requesting latest quiz from webservice.");
            [quizLoad requestLatestQuiz:[self getQuizVersion]];
        }
    } else {
        LogInfo(@"OFFLINE MODE: Using locally saved quiz.");
    }
    
    return YES;
}

- (void)resetApp {
    LogDebug(@"Resetting App");
    [self clearSessionInProgress];
    sessionData = nil;
    sessionData = [[SessionData alloc] init:self];
    [self processQuizObject:[quizManager getQuiz]];
}

- (void)initializeReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    Reachability *reach;
    if (kUseDebugRemote) {
        LogWarn(@"***Turn off kUseDebugRemote before production!***");
        reach = [Reachability reachabilityWithHostname:kDebugReachabilityHost];
    } else {
        reach = [Reachability reachabilityWithHostname:kRemoteReachabilityHost];
    }
    
    /*reach.reachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            LogDebug(@"Block Says Reachable");
        });
    };
    
    reach.unreachableBlock = ^(Reachability *reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            LogDebug(@"Block Says Unreachable");
        });
    };*/
    
    [reach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *reach = [notification object];
    NSDictionary *notifData;
    
    if ([reach isReachable]) {
        reachableState = kReachableState;
        LogDebug(@"Host Reachable");
        notifData = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kReachableKey];
    } else {
        reachableState = kUnreachableState;
        LogDebug(@"Host Unreachable");
        notifData = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kReachableKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityNotif object:self userInfo:notifData];
}

#pragma mark -
#pragma mark Data Model Maintenance

- (BOOL)firstStartInit {
    // The first time the application starts up.
    
    // Copy the hardcoded quiz to Documents.
    if ([self checkAndCreateQuiz] == NO) {
        errorMsg = @"Failed to copy quiz into the Documents folder.";
        LogError(errorMsg);
        return NO;
    }
    
    [appPreferences setBool:YES forKey:kAppInitializedKey];
    [appPreferences synchronize];
    return YES;
}

- (BOOL)updateDataModel:(NSString *)oldVersion newVersion:(NSString *)newVersion {
    LogInfo(@"Updating from version %@...", oldVersion);
    if ([oldVersion isEqualToString:@"1.0"]) {
        // After release of version 1.0, this is where we will make any update changes
        // to installed apps that update from 1.0.
    } else if ([oldVersion isEqualToString:@"1.1"]) {
        // And so forth...
    }
    
    [self setAppVersion:newVersion];
    return YES;
}

#pragma mark -
#pragma mark Quiz Maintenance

- (BOOL)saveQuiz:(NSDictionary *)quiz {
    NSString *quizPath = [[DataManager getDocPath] stringByAppendingPathComponent:kQuizName];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:quiz options:NSJSONWritingPrettyPrinted error:&error];
    
    if (jsonData != nil) {
        LogDebug(@"Saving quiz to %@", quizPath);
        return [jsonData writeToFile:quizPath atomically:YES];
        
    } else {
        LogError(@"Failed to serialize new quiz to JSON data: %@", [error localizedDescription]);
    }
    
    return NO;
}

- (BOOL)checkAndCreateQuiz {
    NSString *quizPath = [[DataManager getDocPath] stringByAppendingPathComponent:kQuizName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// If the quiz already exists then return without doing anything
	if ([DataManager fileExistsAtAbsolutePath:quizPath]) {
        return YES;
    }

    // Get the path to the quiz in the application package.
	NSString *quizPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kQuizName];

	// Copy the quiz from the package to the users filesystem.
	NSError *error = nil;
    BOOL success = [fileManager copyItemAtPath:quizPathFromApp toPath:quizPath error:&error];
    if (success == NO) {
        LogError([error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (BOOL)loadAndParseFile:(NSString *)path {
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfFile:path
                                              options:NSDataReadingMappedIfSafe
                                                error:&error];
    if (jsonData == nil) {
        LogError([error localizedDescription]);
        return NO;
    }
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:kNilOptions
                                                           error:&error];
    if (json == nil) {
        LogError([error localizedDescription]);
        return NO;
    }
    
    if ([self validateJsonQuiz:json] == NO) {
        LogError(@"Quiz JSON is missing required data keys, reverting to local quiz.");
        return NO;
    }

    [self processQuizObject:json];    
    return YES;
}

- (void)quizLoadFinished:(QuizLoad *)aQuizLoad withQuiz:(NSDictionary *)aResult {
    if ([[aResult valueForKey:kQuizVersionKey] isEqualToString:[self getQuizVersion]]) {
        // No change in quiz.
        LogInfo(@"Quiz is up to date at v%@.", [self getQuizVersion]);
    } else if ([[aResult valueForKey:kQuizVersionKey] compare:[self getQuizVersion] options:NSNumericSearch] == NSOrderedDescending) {
        
        // Make sure the quiz is set.
        if ([aResult valueForKey:kQuizQuizKey]) {
            // New quiz!
            NSDictionary *quiz = [aResult objectForKey:kQuizQuizKey];
            LogInfo(@"Quiz updating from v%@ to v%@.", [self getQuizVersion],
                    [quiz valueForKey:kQuizVersionKey]);
            if ([self validateJsonQuiz:quiz]) {
                [self processQuizObject:quiz];
                [[NSNotificationCenter defaultCenter] postNotificationName:kQuizUpdatedNotif object:self userInfo:nil];
                if (![self saveQuiz:quiz]) {
                    LogWarn(@"Quiz failed to save to filesystem. Current quiz version will be lost on full app restart.");
                }
            }
        } else {
            [self quizLoad:aQuizLoad didFailWithError:@"Quiz data not found in response to upgrade."];
        }
    } else {
        LogWarn(@"Different quiz version found v%@, but it appears to be older than the current v%@.", [aResult valueForKey:kQuizVersionKey], [self getQuizVersion]);
        LogWarn(@"This could be an issue with the comparison algorithm. When versioning keep in mind: '1' < '1.0' < '1.0.0'");
    }  
}

- (void)quizLoad:(QuizLoad *)aQuizLoad didFailWithError:(NSString *)aErrorStr {
    LogError(aErrorStr);
    [self displayAlert:@"Quiz Update Failure"
               message:[NSString stringWithFormat:@"Using local quiz v%@ instead.", [self getQuizVersion]]];
}

- (BOOL)validateJsonQuiz:(NSDictionary *)aQuiz {
    LogDebug(@"TODO: Should check for the existance of every vital key here. Then we can reject the quiz if it doesn't have all values populated. At least this will prevent access errors.");
    return YES;
}

- (void)processQuizObject:(NSDictionary *)aQuiz {
    quizManager = [[QuizManager alloc] init:self quiz:aQuiz];
    motionManager.deviceMotionUpdateInterval = [quizManager getMotionSampleRate];

    [self setQuizVersion:[aQuiz valueForKey:kQuizVersionKey]];
}

#pragma mark -
#pragma mark Session Maintenance

- (BOOL)sessionMaintenence {
    NSError *error;
    
    // Create the Sessions folder and mark it not to be backed up.
    NSString *sessionsPath = [[DataManager getDocPath] stringByAppendingPathComponent:kSessionsFolderKey];
    
    [DataManager logDirContentsAtPath:sessionsPath];
    
    if (![DataManager directoryExistsAtAbsolutePath:sessionsPath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:sessionsPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            errorMsg = [NSString stringWithFormat:@"Failed to create session directory < %@ >: %@", sessionsPath, [error localizedDescription]];
            LogError(errorMsg);
            return NO;
        } else {
            if ([DataManager addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:sessionsPath]] == NO) {
                LogWarn(@"Failed to set skip backup attribute on directory: %@", sessionsPath);
            }
        }
    } else {
        //LogDebug(@"Sessions directory exists at: %@", sessionsPath);
    }
    
    // See if there is a partial session and clean it up.
    if ([self getSessionInProgress] != nil) {
        LogWarn(@"An incomplete session was found: %@", [self getSessionInProgress]);
        [self clearSessionInProgress];
    }
    
    // See if there are any saved sessions that don't have entries (uploaded, failed to delete),
    // or entries that don't have saved sessions.
    NSDictionary *savedSessions = [self getSavedSessions];
    if (savedSessions != nil) {
        // Find session entries without files.
        for (NSString *uuid in savedSessions) {
            if (![DataManager fileExistsAtAbsolutePath:[savedSessions objectForKey:uuid]]) {
                LogWarn(@"Found saved session entry without data file, removing entry: %@", uuid);
                [self removeSavedSessionWithUuid:uuid];
            }
        }
        // Refresh sessions since we may have removed some.
        savedSessions = [self getSavedSessions];
        // Get the contents of the sessions directory.
        NSMutableArray *dirContents = [[NSMutableArray alloc] init];
        NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sessionsPath error:nil];
        if (dirContents) {
            [dirContents addObjectsFromArray:items];
        }
        for (NSString *file in dirContents) {
            NSString *fileUuid = [[file lastPathComponent] stringByDeletingPathExtension];
            NSString *filepath = [sessionsPath stringByAppendingPathComponent:file];
            if ([savedSessions objectForKey:fileUuid] == nil) {
                LogWarn(@"Found session file without corresponding session entry, removing file: %@", filepath);
                if (![[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]) {
                    LogWarn(@"Failed to remove session data at: %@", filepath);
                }
            }
        }
    }
    
    return YES;
}

- (void)uploadSavedSessions {
    NSDictionary *savedSessions = [self getSavedSessions];

    if (savedSessions && ([savedSessions count] > 0)) {
        if (reachableState == kReachableState) {
            NSArray *keys = [savedSessions allKeys];
            SessionUpload *sessionUp = [[SessionUpload alloc] init];
            [sessionUp setDelegate:self];
            [sessionUp uploadSessionAtPath:[savedSessions objectForKey:[keys objectAtIndex:0]] withUuid:[keys objectAtIndex:0]];
            return;
        }
    }
    NSDictionary *uploadData = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kSessionsUploadedKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionsUploadedNotif object:self userInfo:uploadData];
}

- (void)sessionDidFinishUpload:(SessionUpload *)aSessionUpload withUuid:(NSString *)aUuid {
    LogInfo(@"Successfully uploaded session data for: %@", aUuid);
    [self removeSavedSessionWithUuid:aUuid];
    [self uploadSavedSessions];
}

- (void)session:(SessionUpload *)aSessionUpload withUuid:(NSString *)aUuid didFailWithError:(NSString *)aMessage andCode:(ServerErrorCode)aCode {
    if (aMessage) {
        LogError(@"%@", aMessage);
    }
    NSDictionary *uploadData = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kSessionsUploadedKey];
    if (aCode == kECTempNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionsUploadedNotif object:self userInfo:uploadData];
    } else if (aCode == kECFileExists) {
        // File already exists, clean up the one on our end and continue.
        [self removeSavedSessionWithUuid:aUuid];
        [self uploadSavedSessions];
    } else if (aCode == kECCantMoveFile) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionsUploadedNotif object:self userInfo:uploadData];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionsUploadedNotif object:self userInfo:uploadData];
    }
}

#pragma mark -
#pragma mark Helper Methods

- (void)displayAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark Static Methods

+ (void)logDirContentsAtPath:(NSString *)path {
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];

    LogInfo(@"Content of path: %@", path);
    for (NSString *item in dirContents) {
        LogInfo(@" - %@", item);
        NSString *newPath = [path stringByAppendingPathComponent:item];
        if ([DataManager directoryExistsAtAbsolutePath:newPath]) {
            [DataManager logDirContentsAtPath:newPath];
        }
    }
}

+ (NSString *)getDocPath {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [dirPaths objectAtIndex:0];
}

+ (BOOL)fileExistsAtAbsolutePath:(NSString *)filepath {
    BOOL isDirectory;
    BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDirectory];
    
    return fileExistsAtPath && !isDirectory;
}

+ (BOOL)directoryExistsAtAbsolutePath:(NSString *)path {
    BOOL isDirectory;
    BOOL fileExistsAtPath = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    return fileExistsAtPath && isDirectory;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    NSString *reqSysVer = @"5.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    // iOS 5.1 or higher required to use new backup exclusion technique.
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedDescending) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
            
            NSError *error;
            BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                          forKey: NSURLIsExcludedFromBackupKey error: &error];
            if (!success) {
                LogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
                
            }
            return success;
        }
    } else { // For iOS less than 5.1
        if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
            
            const char *filePath = [[URL path] fileSystemRepresentation];
            const char *attrName = "com.apple.MobileBackup";
            
            u_int8_t attrValue = 1;
            
            int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
            return result == 0;
        }
    }
    return NO;
}

@end
