//
//  QuizManager.h
//  Two Eyes 3D
//
//  Created by Jerry Belich on 6/19/12.
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

@class DataManager;
@class CWRadioButtonChoice;
@class CWRadioButtonOptions;
@class DrawOptions;

typedef enum {
    kRadioImage,
    kRadioText,
    kDrawing,
    kInvalid
} QuestionType;

@interface QuizManager : NSObject {
    DataManager *manager;
    NSDictionary *quiz;
    int movieIndex;
    float motionSampleRate;
    int movieLengthSecs;
    NSString *quizKey;
    BOOL takingSpatialQuiz;
    int spatialSecondsLeft;
    BOOL takingQuiz;
    int quizNum;
    int roundNum;
}

- (id)init:(DataManager *)dataManager quiz:(NSDictionary *)quizObj;
- (NSDictionary *)getQuiz;

// Setup Methods
- (float)getMotionSampleRate;

// Movie Setup Methods
- (void)setMovieIndex:(int)index;
- (int)getMovieIndex;
- (void)setQuizKey:(NSString *)aKey;
- (NSString *)getQuizKey;
- (void)setMovieLength:(int)length;
- (int)getMovieTotal;
- (NSString *)getMovieTitleAtIndex:(int)index;
- (int)getMovieLengthAtIndex:(int)index;
- (NSString *)getQuizKeyAtIndex:(int)index;
- (int)getMovieTypeTotal;
- (NSString *)getMovieTypeAtIndex:(int)index;

// Spatial Quiz Methods
// Sets up for the spatial quiz.
- (void)startSpatialQuiz;
// Returns true if there are more questions, and prepares for next question.
// False if no more questions remain. 
- (BOOL)nextSpatialQuestion:(int)secondsRemaining;
- (void)endSpatialQuiz;
- (int)getSpatialTimeLimitSeconds;
- (UIImageView *)getSpatialQuestionImage;

// Quiz Methods
- (void)startQuizWithKey:(NSString *)aQuizKey;
- (BOOL)nextQuestion;
- (void)endQuiz;
- (void)resetQuiz;
- (int)getQuizTotal;
- (int)getRound;
- (NSNumber *)getQuestionId;
- (NSString *)getQuestionText;
- (NSString *)getQuestionAttribution;
- (BOOL)hasQuestionExplain;
- (QuestionType)getQuestionType;
- (DrawOptions *)getDrawingOptions;
// Automatically implants the radio options object.
- (NSArray *)getRadioChoicesWithOptions:(CWRadioButtonOptions *)options;
- (CWRadioButtonOptions *)getRadioOptions;

// Intermission
- (int)getIntermissionTime;

// Private Methods
- (NSArray *)getChoiceArray:(CWRadioButtonOptions *)radioOptions radioType:(QuestionType)radioType items:(NSArray *)items;

//
+ (QuestionType)stringToQuestionType:(NSString *)strType;
+ (NSString *)questionTypeToString:(QuestionType)type;

@end
