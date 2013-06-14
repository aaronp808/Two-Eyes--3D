//
//  SessionData.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 6/1/12.
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

#import "SessionData.h"
#import "DataManager.h"
#import "SpatialResultVO.h"
#import "QuizResultVO.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"
#import "FileInZipInfo.h"
#import "zlib.h"
#import "NSValue+JSON.h"

@implementation SessionData

// Session Info Key
NSString *const kSessionInfoKey = @"session_info";
NSString *const kStartTimeKey = @"start_time";
NSString *const kEndTimeKey = @"end_time";
NSString *const kDateFormat = @"MM-dd-yy HH:mm:ss zzz";
NSString *const kMotionSampleRateKey = @"sample_rate";
// Survey Keys
NSString *const kMovieIdKey = @"movie_index";
NSString *const kQuizKey = @"quiz_key";
NSString *const kTypeIdKey = @"type_index";
// Demographic Keys
NSString *const kUUIDKey = @"uuid";
NSString *const kNameKey = @"name";
NSString *const kEmailKey = @"email";
NSString *const kAgeKey = @"age";
NSString *const kGenderIdKey = @"gender_index";
NSString *const kDifficultyIdKey = @"difficulty_index";
NSString *const kKnowledgeIdKey = @"knowledge_index";
// Spatial Keys
NSString *const kSpatialSessionKey = @"spatial_session";
NSString *const kSpatialQuestionsKey = @"spatial_questions";

// Knowledge Quiz Keys
NSString *const kQuizSessionsKey = @"quiz_sessions";
NSString *const kQuizQuestionsKey = @"quiz_questions";
NSString *const kRoundKey = @"round";
NSString *const kImageFileKey = @"image_file";
NSString *const kDrawingDataKey = @"drawing_data";

// Quiz Keys
NSString *const kTypeKey = @"type";
NSString *const kQuestionIdKey = @"question_index";
NSString *const kAnswerIdKey = @"answer_index";
NSString *const kTotalDurationKey = @"total_duration";
NSString *const kDurationKey = @"duration";
NSString *const kHasExplanationKey = @"has_explanation";
NSString *const kExplanationKey = @"explanation";
NSString *const kAttitudeDataKey = @"attitude_data";
NSString *const kAccelerationDataKey = @"acceleration_data";


+ (NSString *)GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

- (id)init:(DataManager *)dataManager {
    self = [super init];
    
    if (self) {
        manager = dataManager;
        session = [[NSMutableDictionary alloc] init];
        dataFiles = [[NSMutableDictionary alloc] init];
        [session setObject:[[NSMutableDictionary alloc] init] forKey:kSessionInfoKey];
        [session setObject:[[NSMutableDictionary alloc] init] forKey:kSpatialSessionKey];
        [[session objectForKey:kSpatialSessionKey] setObject:[[NSMutableArray alloc] init] forKey:kSpatialQuestionsKey];
        
        [session setObject:[[NSMutableArray alloc] init] forKey:kQuizSessionsKey];
        
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kDateFormat];
        
        uuid = [SessionData GetUUID];
    }
    
    return self;
}

- (void)startAppSession {
    appSessionStart = [NSDate date];
}

- (void)endAppSession {
    NSMutableDictionary *sessionInfo = [session objectForKey:kSessionInfoKey];
    // Generate end time and duration for this session.
    NSDate *endtime = [NSDate date];
    NSString *datetime = [dateFormat stringFromDate:endtime];
    [sessionInfo setObject:datetime forKey:kEndTimeKey];
    NSNumber *duration = [NSNumber numberWithDouble:[endtime timeIntervalSinceDate:appSessionStart]];
    [sessionInfo setObject:duration forKey:kTotalDurationKey];
    [session setObject:sessionInfo forKey:kSessionInfoKey];
    
    NSError *error;
    NSString *dataPath = [NSString stringWithFormat:@"%@/data.json", uuid];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:session options:NSJSONWritingPrettyPrinted error:&error];
    [dataFiles setObject:jsonData forKey:dataPath];
}

- (BOOL)writeSessionZip {
    LogDebug(@"Zipping session data for: %@", uuid);
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip", kSessionsFolderKey, uuid];
    zipPath = [[DataManager getDocPath] stringByAppendingPathComponent:zipPath];
    ZipFile *zipFile = [[ZipFile alloc] initWithFileName:zipPath mode:ZipFileModeCreate];
    
    NSError *error;
    for (NSString *filename in dataFiles) {
        NSData *fileData = [dataFiles objectForKey:filename];
        
        ZipWriteStream *stream;
        if ([kZipPassword length] > 0) {
            uLong theCRC = crc32(0L, NULL, 0L);
			theCRC = crc32(theCRC, (const Bytef *)[fileData bytes], [fileData length] );
            
            stream = [zipFile writeFileInZipWithName:filename fileDate:[NSDate date] compressionLevel:ZipCompressionLevelBest password:kZipPassword crc32:theCRC error:&error];
        } else {
            LogWarn(@"Session data zipfile password not set!");
            stream = [zipFile writeFileInZipWithName:filename fileDate:[NSDate date] compressionLevel:ZipCompressionLevelBest error:&error];
        }
        
        if (![stream writeData:fileData error:&error]) {
            LogError(@"Error writing %@ to session zip: %@", filename, [error localizedDescription]);
        }
        
        [stream finishedWritingWithError:&error];
    }
    [zipFile close];
    
    if (![DataManager fileExistsAtAbsolutePath:zipPath]) {
        LogError(@"Failed to save session data: %@", zipPath);
        return NO;
    } else {
        [manager clearSessionInProgress];
        [manager addSavedSession:zipPath withUuid:uuid];
    }
    
    [self listZipFile:zipPath];
    
    return YES;
}

- (void)listZipFile:(NSString *)filepath {
    ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:filepath mode:ZipFileModeUnzip];
    NSArray *infos = [unzipFile containedFiles];
    for (FileInZipInfo *info in infos) {
        LogInfo(@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level);
    }
}

- (void)saveSurvey:(NSNumber *)movieId typeId:(NSNumber *)typeId {
    NSMutableDictionary *sessionInfo = [session objectForKey:kSessionInfoKey];
    [sessionInfo setObject:movieId forKey:kMovieIdKey];
    [sessionInfo setObject:[[manager quizManager] getQuizKeyAtIndex:[movieId intValue]] forKey:kQuizKey];
    [sessionInfo setObject:typeId forKey:kTypeIdKey];
    [session setObject:sessionInfo forKey:kSessionInfoKey];
}

- (void)saveDemographic:(NSString *)name email:(NSString *)email age:(NSNumber *)age genderId:(NSNumber *)genderId diffId:(NSNumber *)diffId knowledgeId:(NSNumber *)knowledgeId {
    NSMutableDictionary *sessionInfo = [session objectForKey:kSessionInfoKey];
    
    // Generate start time for this session.
    NSString *datetime = [dateFormat stringFromDate:[NSDate date]];

    NSNumber *sample = [[NSNumber alloc] initWithFloat:[[manager quizManager] getMotionSampleRate]];
    [sessionInfo setObject:sample forKey:kMotionSampleRateKey];
    [sessionInfo setObject:uuid forKey:kUUIDKey];
    [sessionInfo setObject:datetime forKey:kStartTimeKey];
    [sessionInfo setObject:name forKey:kNameKey];
    [sessionInfo setObject:email forKey:kEmailKey];
    [sessionInfo setObject:age forKey:kAgeKey];
    [sessionInfo setObject:genderId forKey:kGenderIdKey];
    [sessionInfo setObject:diffId forKey:kDifficultyIdKey];
    [sessionInfo setObject:knowledgeId forKey:kKnowledgeIdKey];
    [sessionInfo setObject:[manager getQuizVersion] forKey:kQuizVersionKey];
    [session setObject:sessionInfo forKey:kSessionInfoKey];
}

- (void)startSpatialSession {
    spatialSessionStart = [NSDate date];
}

- (void)endSpatialSession {
    NSNumber *duration = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:spatialSessionStart]];
    [[session objectForKey:kSpatialSessionKey] setObject:duration forKey:kTotalDurationKey];
}

- (BOOL)saveSpatialResult:(SpatialResultVO *)result {
    if (result.type == kRadioImage) {
        NSMutableDictionary *sq = [[NSMutableDictionary alloc] init];
        [sq setObject:[QuizManager questionTypeToString:result.type] forKey:kTypeKey];
        [sq setObject:result.questionId forKey:kQuestionIdKey];
        [sq setObject:result.answerId forKey:kAnswerIdKey];
        [sq setObject:[dateFormat stringFromDate:result.startTime] forKey:kStartTimeKey];
        [sq setObject:[dateFormat stringFromDate:result.endTime] forKey:kEndTimeKey];
        [sq setObject:result.duration forKey:kDurationKey];
        [sq setObject:result.hasExplanation forKey:kHasExplanationKey];
        if (result.hasExplanation.boolValue) {
            [sq setObject:result.explanation forKey:kExplanationKey];
        }
        [sq setObject:result.attitudeData forKey:kAttitudeDataKey];
        [sq setObject:result.accelData forKey:kAccelerationDataKey];
        [[[session objectForKey:kSpatialSessionKey] objectForKey:kSpatialQuestionsKey] addObject:sq];
        return YES;
    } else {
        LogWarn(@"Can only save a spatial question result with radio_image type.");
    }
    return NO;
}

- (void)startQuizSession {
    NSMutableDictionary *quizSession = [[NSMutableDictionary alloc] init];
    [quizSession setObject:[[NSMutableArray alloc] init] forKey:kQuizQuestionsKey];
    [[session objectForKey:kQuizSessionsKey] addObject:quizSession];
    quizSessionStart = [NSDate date];
}

- (void)endQuizSession {
    NSNumber *duration = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:quizSessionStart]];
    int index = [[session objectForKey:kQuizSessionsKey] count];
    [[[session objectForKey:kQuizSessionsKey] objectAtIndex:index-1] setObject:duration forKey:kTotalDurationKey];
}

- (BOOL)saveQuizResult:(QuizResultVO *)result {
    if (result.type != kInvalid) {
        NSMutableDictionary *kq = [[NSMutableDictionary alloc] init];
        [kq setObject:[QuizManager questionTypeToString:result.type] forKey:kTypeKey];
        [kq setObject:result.questionId forKey:kQuestionIdKey];
        if ((result.type == kRadioImage) || (result.type == kRadioText)) { 
            [kq setObject:result.answerId forKey:kAnswerIdKey];
        }
        if (result.type == kDrawing) {
            if (result.drawingImage != nil) {
                [kq setObject:result.drawingData forKey:kDrawingDataKey];
                
                NSString *filename = [NSString stringWithFormat:@"r%d_q%d.png", [result.round intValue], [result.questionId intValue]];
                if ([dataFiles objectForKey:filename] == nil) {
                    [kq setObject:filename forKey:kImageFileKey];
                    NSString *filepath = [uuid stringByAppendingPathComponent:filename];
                    [dataFiles setObject:UIImagePNGRepresentation(result.drawingImage) forKey:filepath];
                } else {
                    LogWarn(@"Image data already saved in session for filename: %@", filename);
                }
            } else {
                LogError(@"Image for question index %d is nil!", [result.questionId intValue]);
            }
        }
        [kq setObject:result.round forKey:kRoundKey];
        [kq setObject:[dateFormat stringFromDate:result.startTime] forKey:kStartTimeKey];
        [kq setObject:[dateFormat stringFromDate:result.endTime] forKey:kEndTimeKey];
        [kq setObject:result.duration forKey:kDurationKey];
        [kq setObject:result.hasExplanation forKey:kHasExplanationKey];
        if (result.hasExplanation.boolValue) {
            [kq setObject:result.explanation forKey:kExplanationKey];
        }
        [kq setObject:result.attitudeData forKey:kAttitudeDataKey];
        [kq setObject:result.accelData forKey:kAccelerationDataKey];
        [[[[session objectForKey:kQuizSessionsKey] objectAtIndex:result.round.intValue-1] objectForKey:kQuizQuestionsKey] addObject:kq];
        return YES;
    } else {
        LogWarn(@"Invalid type provided in quiz result.");
    }
    return NO;
}

@end
