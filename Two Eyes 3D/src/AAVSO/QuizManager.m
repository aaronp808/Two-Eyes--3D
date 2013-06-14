//
//  QuizManager.m
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

#import "QuizManager.h"
#import "DataManager.h"
#import "CWRadioButtonOptions.h"
#import "CWRadioButtonChoice.h"
#import "DrawOptions.h"

// Movie Setup Keys
NSString *const kSetupKey = @"setup";
NSString *const kSampleRateKey = @"sample_rate";
NSString *const kMoviesKey = @"movies";
NSString *const kMovieNameKey = @"name";
NSString *const kMovieLengthKey = @"length";
NSString *const kMovieTypesKey = @"types";

// Spatial Quiz Keys
NSString *const kSpatialQuizKey = @"spatial_quiz";
NSString *const kQuestionImageKey = @"question_image";
NSString *const kQuestionXKey = @"question_x";
NSString *const kQuestionYKey = @"question_y";
NSString *const kTimeLimitKey = @"time_limit";

// Spatial and Quiz Keys
NSString *const kQuestionsKey = @"questions";
NSString *const kQuestionTypeKey = @"question_type";
NSString *const kIncludeExplainKey = @"include_explain";
NSString *const kAttributionKey = @"attribution";

// Quiz Keys
NSString *const kKnowledgeQuizKey = @"quiz_key";
NSString *const kQuestionTextKey = @"question_text";

// Radio Setup Keys
NSString *const kRadioSetupKey = @"radio_setup";

NSString *const kFontNameKey = @"font_name";
NSString *const kFontSizeKey = @"font_size";
NSString *const kTextColorKey = @"text_color";

NSString *const kRadioTypeKey = @"type";
NSString *const kRadioPositionKey = @"radio_position";
NSString *const kRadioDistanceKey = @"radio_distance";
NSString *const kItemLayoutKey = @"item_layout";
NSString *const kItemBufferKey = @"item_buffer";
NSString *const kItemsUntilWrappingKey = @"items_until_wrapping";
NSString *const kMaxItemWidthKey = @"max_item_width";
NSString *const kMaxItemHeightKey = @"max_item_height";
NSString *const kRadioXKey = @"x";
NSString *const kRadioYKey = @"y";

NSString *const kRadioItemsKey = @"radio_items";
NSString *const kItemImageKey = @"image";
NSString *const kItemHasCaptionKey = @"has_caption";
NSString *const kItemCaption = @"caption";

// Drawing Setup Keys
NSString *const kDrawingSetupKey = @"drawing_setup";

NSString *const kBackgroundImageKey = @"background_image";
NSString *const kBackgroundColorKey = @"background_color";
NSString *const kPenColorKey = @"pen_color";
NSString *const kPenDrawingColorKey = @"pen_drawing_color";
NSString *const kLabelTextColorKey = @"label_text_color";
NSString *const kLabelBackColorKey = @"label_back_color";
NSString *const kPenRadiusKey = @"pen_radius";
NSString *const kEraserRadiusKey = @"eraser_radius";
NSString *const kOriginXKey = @"x";
NSString *const kOriginYKey = @"y";

@implementation QuizManager

- (id)init:(DataManager *)dataManager quiz:(NSDictionary *)quizObj {
    self = [super init];
    
    if (self) {
        manager = dataManager;
        quiz = quizObj;
        
        if ((motionSampleRate = [[[quiz objectForKey:kSetupKey] objectForKey:kSampleRateKey] floatValue]) <= 0) {
            motionSampleRate = 1.0f / 30.0f;
        }
        movieIndex = -1;
        movieLengthSecs = 0;
        quizKey = @"";
        takingSpatialQuiz = NO;
        spatialSecondsLeft = -1;
        takingQuiz = NO;
        quizNum = -1;
        roundNum = 0;
    }
    
    return self;
}

- (NSDictionary *)getQuiz {
    return quiz;
}

#pragma mark -
#pragma mar Setup Methods

- (float)getMotionSampleRate {
    return motionSampleRate;
}

#pragma mark -
#pragma mark Movie Setup Methods

- (void)setMovieIndex:(int)index {
    movieIndex = index;
}

- (int)getMovieIndex {
    return movieIndex;
}

- (void)setQuizKey:(NSString *)aKey {
    quizKey = aKey;
}

- (NSString *)getQuizKey {
    return quizKey;
}

- (void)setMovieLength:(int)seconds {
    LogDebug(@"Setting movie length: %d", seconds);
    movieLengthSecs = seconds;
}

- (int)getMovieTotal {
    return [[[quiz objectForKey:kSetupKey] objectForKey:kMoviesKey] count];
}

- (NSString *)getMovieTitleAtIndex:(int)index {
    return [[[[quiz objectForKey:kSetupKey] objectForKey:kMoviesKey] objectAtIndex:index] objectForKey:kMovieNameKey];
}

- (int)getMovieLengthAtIndex:(int)index {
    return [[[[[quiz objectForKey:kSetupKey] objectForKey:kMoviesKey] objectAtIndex:index] objectForKey:kMovieLengthKey] intValue];
}

- (NSString *)getQuizKeyAtIndex:(int)index {
    return [[[[quiz objectForKey:kSetupKey] objectForKey:kMoviesKey] objectAtIndex:index] objectForKey:kKnowledgeQuizKey];
}

- (int)getMovieTypeTotal {
    return [[[quiz objectForKey:kSetupKey] objectForKey:kMovieTypesKey] count];
}

- (NSString *)getMovieTypeAtIndex:(int)index {
    return [[[quiz objectForKey:kSetupKey] objectForKey:kMovieTypesKey] objectAtIndex:index];
}

#pragma mark -
#pragma mark Spatial Quiz Methods

- (void)startSpatialQuiz {
    if (!takingSpatialQuiz && !takingQuiz) {
        [[manager session] startSpatialSession];
        takingSpatialQuiz = YES;
        quizKey = kSpatialQuizKey;
        quizNum = 0;
        spatialSecondsLeft = [[[quiz objectForKey:kSpatialQuizKey] objectForKey:kTimeLimitKey] intValue];
    } else {
        if (takingQuiz) {
            LogWarn(@"Already taking the quiz, doing nothing.");
        } else {
            LogWarn(@"Already taking the spatial quiz, doing nothing.");
        }
    }
}

- (BOOL)nextSpatialQuestion:(int)secondsRemaining {
    spatialSecondsLeft = secondsRemaining;
    if (spatialSecondsLeft == 0) {
        LogDebug(@"Ran out of time, end spatial quiz early.");
        return NO;
    }
    
    quizNum++;
    if (quizNum >= [self getQuizTotal]) {
        return NO;
    }
    return YES;
}

- (void)endSpatialQuiz {
    if (takingSpatialQuiz) {
        [[manager session] endSpatialSession];
        takingSpatialQuiz = NO;
        quizKey = @"";
        quizNum = -1;
        spatialSecondsLeft = -1;
    } else {
        LogWarn(@"Not currently taking the Spatial Quiz, doing nothing.");
    }
}

- (UIImageView *)getSpatialQuestionImage {
    if (takingSpatialQuiz) {
        NSDictionary *question = [[[quiz objectForKey:kSpatialQuizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum];
        NSString *imageName = [question objectForKey:kQuestionImageKey];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image == nil) {
            LogError(@"Fail to load question image for question index: %d", quizNum);
            return nil;
        }
        int x = [[question objectForKey:kQuestionXKey] intValue];
        int y = [[question objectForKey:kQuestionYKey] intValue];
        if ((x < 0) || (x > 1024)) {
            LogWarn(@"Question Image X value seems too low or too high: %d", x);
        }
        if ((y < 0) || (y > 768)) {
            LogWarn(@"Question Image Y value seems too low or too high: %d", y);
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect frame = imageView.frame;
        frame.origin = CGPointMake(x, y);
        imageView.frame = frame;
        return imageView;
    }
    return nil;
}

// Returns time remaining to take the quiz in seconds.
- (int)getSpatialTimeLimitSeconds {
    return spatialSecondsLeft;
}

#pragma mark -
#pragma mark Quiz Methods

- (void)startQuizWithKey:(NSString *)aQuizKey {
    if (!takingQuiz && !takingSpatialQuiz) {
        [[manager session] startQuizSession];
        takingQuiz = YES;
        quizKey = aQuizKey;
        quizNum = 0;
        roundNum++;
    } else {
        if (takingQuiz) {
            LogWarn(@"Already taking the quiz, doing nothing.");
        } else {
            LogWarn(@"Already taking the spatial quiz, doing nothing.");
        }
    }
}

- (BOOL)nextQuestion {
    quizNum++;
    if (quizNum >= [self getQuizTotal]) {
        return NO;
    }
    return YES;
}

- (void)endQuiz {
    if (takingQuiz) {
        [[manager session] endQuizSession];
        takingQuiz = NO;
        quizKey = @"";
        quizNum = -1;
    } else {
        LogWarn(@"Not currently taking the Spatial Quiz, doing nothing.");
    }
}

- (void)resetQuiz {
    movieLengthSecs = 0;
    quizKey = @"";
    takingSpatialQuiz = NO;
    spatialSecondsLeft = -1;
    takingQuiz = NO;
    quizNum = -1;
    roundNum = 0;
}

- (int)getQuizTotal {
    return [[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] count];
}

- (int)getRound {
    return roundNum;
}

- (NSNumber *)getQuestionId {
    return [[NSNumber alloc] initWithInt:quizNum];
}

- (NSString *)getQuestionText {
    return [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kQuestionTextKey];
}

- (NSString *)getQuestionAttribution {
    if ((quizNum >= 0) && (quizNum < [self getQuizTotal])) {
        NSString *attr = [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kAttributionKey];
        if (!attr) {
            attr = @"";
        }
        return attr;
    } else {
        LogError(@"Invalid index for quiz question: %d", quizNum);
    }
    return nil;
}

- (BOOL)hasQuestionExplain {
    if ((quizNum >= 0) && (quizNum < [self getQuizTotal])) {
        return (BOOL)[[[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kIncludeExplainKey] intValue];
    } else {
        LogError(@"Invalid index for quiz question: %d", quizNum);
    }
    return NO;
}

- (QuestionType)getQuestionType {
    if ((quizNum >= 0) && (quizNum < [self getQuizTotal])) {
        NSString *type = [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kQuestionTypeKey];
        return [QuizManager stringToQuestionType:type];
    } else {
        LogError(@"Invalid index for quiz question: %d", quizNum);
    }
    return kInvalid;
}

- (DrawOptions *)getDrawingOptions {
    if ([self getQuestionType] == kDrawing) {
        NSDictionary *options = [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kDrawingSetupKey];
        
        if (options == nil) {
            return nil;
        }
        
        DrawOptions *drawOptions = [[DrawOptions alloc] init];
        if ([options objectForKey:kBackgroundColorKey]) {
            drawOptions.backImage = [DrawOptions imageWithColor:[DrawOptions getColorFromHex:[options objectForKey:kBackgroundColorKey]] andSize:CGSizeMake(10, 10)];
        }
        if ([options objectForKey:kBackgroundImageKey]) {
            UIImage *backImage = [UIImage imageNamed:[options objectForKey:kBackgroundImageKey]];
            if (backImage != nil) {
                drawOptions.backImage = backImage;
            } else {
                LogWarn(@"Unable to find specified background image for drawing component.");
            }
        }
        if ([options objectForKey:kPenDrawingColorKey]) {
            drawOptions.penDrawingColor = [DrawOptions getColorFromHex:[options objectForKey:kPenDrawingColorKey]];
        }
        if ([options objectForKey:kPenColorKey]) {
            drawOptions.penColor = [DrawOptions getColorFromHex:[options objectForKey:kPenColorKey]];
        }
        if ([options objectForKey:kLabelTextColorKey]) {
            drawOptions.labelTextColor = [DrawOptions getColorFromHex:[options objectForKey:kLabelTextColorKey]];
        }
        if ([options objectForKey:kLabelBackColorKey]) {
            drawOptions.labelBackColor = [DrawOptions getColorFromHex:[options objectForKey:kLabelBackColorKey]];
        }
        if ([options objectForKey:kPenRadiusKey]) {
            drawOptions.penRadius = [[options objectForKey:kPenRadiusKey] floatValue];
        }
        if ([options objectForKey:kEraserRadiusKey]) {
            drawOptions.eraserRadius = [[options objectForKey:kEraserRadiusKey] floatValue];
        }
        if ([options objectForKey:kOriginXKey] && [options objectForKey:kOriginYKey]) {
            drawOptions.origin = CGPointMake([[options objectForKey:kOriginXKey] intValue], [[options objectForKey:kOriginYKey] intValue]);
        }
        return drawOptions;
    }
    return nil;
}

// Requests the set of choices for the current spatial question.
- (NSArray *)getRadioChoicesWithOptions:(CWRadioButtonOptions *)options {
    QuestionType type = [self getQuestionType];
    if ((type == kRadioText) || (type == kRadioImage)) {
        NSArray *items = [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kRadioItemsKey];
        return [self getChoiceArray:options radioType:type items:items];
    }
    return nil;
}

- (CWRadioButtonOptions *)getRadioOptions {
    NSDictionary *options = [[[[quiz objectForKey:quizKey] objectForKey:kQuestionsKey] objectAtIndex:quizNum] objectForKey:kRadioSetupKey];

    if (options == nil) {
        return nil;
    }
    CWRadioButtonOptions *radioOptions = [[CWRadioButtonOptions alloc] init];
    if ([options objectForKey:kRadioTypeKey]) {
        if ([[options objectForKey:kRadioTypeKey] isEqualToString:@"image"]) {
            radioOptions.radioType = imageType;
        } else if ([[options objectForKey:kRadioTypeKey] isEqualToString:@"text"]) {
            radioOptions.radioType = textType;
        } else {
            LogWarn(@"Invalid radio component type.");
        }
    }
    if ([options objectForKey:kFontNameKey]) {
        radioOptions.fontName = [options objectForKey:kFontNameKey];
    }
    if ([options objectForKey:kFontSizeKey]) {
        radioOptions.fontSize = [[options objectForKey:kFontSizeKey] intValue];
    }
    if ([options objectForKey:kTextColorKey]) {
        radioOptions.textColor = [options objectForKey:kTextColorKey];
    }
    if ([options objectForKey:kRadioPositionKey]) {
        if ([[options objectForKey:kRadioPositionKey] isEqualToString:@"top"]) {
            radioOptions.radioPosition = positionTop;
        } else if ([[options objectForKey:kRadioPositionKey] isEqualToString:@"bottom"]) {
            radioOptions.radioPosition = positionBottom;
        } else if ([[options objectForKey:kRadioPositionKey] isEqualToString:@"left"]) {
            radioOptions.radioPosition = positionLeft;
        } else if ([[options objectForKey:kRadioPositionKey] isEqualToString:@"right"]) {
            radioOptions.radioPosition = positionRight;
        } else {
            LogWarn(@"Invalid position value provided, using default.");
        }
    }
    if ([options objectForKey:kRadioDistanceKey]) {
        radioOptions.radioDistance = [[options objectForKey:kRadioDistanceKey] intValue];
    }
    if ([options objectForKey:kItemLayoutKey]) {
        if ([[options objectForKey:kItemLayoutKey] isEqualToString:@"horizontal"]) {
            radioOptions.itemLayout = layoutHorizontal;
        } else if ([[options objectForKey:kItemLayoutKey] isEqualToString:@"vertical"]) {
            radioOptions.itemLayout = layoutVertical;
        } else {
            LogWarn(@"Invalid item layout value provided, using default.");
        }
    }
    if ([options objectForKey:kItemBufferKey]) {
        radioOptions.itemBuffer = [[options objectForKey:kItemBufferKey] intValue];
    }
    if ([options objectForKey:kItemsUntilWrappingKey]) {
        radioOptions.itemsUntilWrap = [[options objectForKey:kItemsUntilWrappingKey] intValue];
    }
    if ([options objectForKey:kMaxItemWidthKey] && [options objectForKey:kMaxItemHeightKey]) {
        radioOptions.itemMaxDimension = CGSizeMake([[options objectForKey:kMaxItemWidthKey] intValue], [[options objectForKey:kMaxItemHeightKey] intValue]);
    }
    if ([options objectForKey:kRadioXKey] && [options objectForKey:kRadioYKey]) {
        radioOptions.radioOrigin = CGPointMake([[options objectForKey:kRadioXKey] intValue], [[options objectForKey:kRadioYKey] intValue]);
    }
    radioOptions.radioOnName = kRadioStateOn;
    radioOptions.radioOffName = kRadioStateOff;
    
    return radioOptions;
}

#pragma mark -
#pragma mark Private Methods

- (int)getIntermissionTime {
    LogDebug(@"Intermission: %d", movieLengthSecs);
    return movieLengthSecs;
}

#pragma mark -
#pragma mark Private Methods

// Automatically generates the radio options, and builds an array of choices with it.
- (NSArray *)getChoiceArray:(CWRadioButtonOptions *)radioOptions radioType:(QuestionType)radioType items:(NSArray *)items {
    NSMutableArray *choices = [[NSMutableArray alloc] init];

    if (radioType == kRadioImage) {
        for (NSDictionary *item in items) {
            NSString *caption = @"";
            if ([[item objectForKey:kItemHasCaptionKey] intValue]) {
                caption = [item objectForKey:kItemCaption];
            }
            NSString *imageName = [item objectForKey:kItemImageKey];
            CWRadioButtonChoice *choice = [[CWRadioButtonChoice alloc] initWithOptions:radioOptions imageName:imageName caption:caption];
            [choices addObject:choice];
        }
    } else if (radioType == kRadioText) {
        for (NSString *text in items) {
            CWRadioButtonChoice *choice = [[CWRadioButtonChoice alloc] initWithOptions:radioOptions text:text];
            [choices addObject:choice];
        }
    } else {
        LogWarn(@"Invalid radio type provided for getChoiceArray.");
        return nil;
    }
    return choices;
}

+ (QuestionType)stringToQuestionType:(NSString *)strType {
    if ([strType isEqualToString:@"radio_image"]) {
        return kRadioImage;
    } else if ([strType isEqualToString:@"radio_text"]) {
        return kRadioText;
    } else if ([strType isEqualToString:@"drawing"]) {
        return kDrawing;
    }
    return kInvalid;
}

+ (NSString *)questionTypeToString:(QuestionType)type {
    if (type == kRadioImage) {
        return @"radio_image";
    } else if (type == kRadioText) {
        return @"radio_text";
    } else if (type == kDrawing) {
        return @"drawing";
    }
    return @"invalid";
}

@end
