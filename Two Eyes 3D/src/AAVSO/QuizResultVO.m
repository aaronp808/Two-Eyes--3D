//
//  QuizResultVO.m
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

#import <CoreMotion/CoreMotion.h>
#import "QuizResultVO.h"

@implementation QuizResultVO
@synthesize type;
@synthesize round;
@synthesize questionId;
@synthesize answerId;
@synthesize duration;
@synthesize attitudeData;
@synthesize accelData;
@synthesize drawingData;
@synthesize drawingImage;

- (id)init {
    self = [super init];
    
    if (self) {
        type = kInvalid;
        round = [[NSNumber alloc] initWithInt:-1];
        questionId = [[NSNumber alloc] initWithInt:-1];
        answerId = [[NSNumber alloc] initWithInt:-1];
        hasExplanation = [[NSNumber alloc] initWithBool:NO];;
        explanation = @"";
        startTime = [NSDate date];
        endTime = [NSDate date];
        duration = [[NSNumber alloc] initWithInt:-1];
        attitudeData = [[NSMutableArray alloc] init];
        accelData = [[NSMutableArray alloc] init];
        drawingData = [[NSMutableArray alloc] init];
        drawingImage = [[UIImage alloc] init];
    }
    
    return self;
}

- (NSNumber *)hasExplanation {
    return hasExplanation;
}

- (void)setExplanation:(NSString *)value {
    hasExplanation = [[NSNumber alloc] initWithBool:YES];
    explanation = value;
}

- (NSString *)explanation {
    return explanation;
}

- (void)setStartTime {
    startTime = [NSDate date];
}

- (NSDate *)startTime {
    return startTime;
}

- (void)setEndTime {
    endTime = [NSDate date];
    duration = [NSNumber numberWithDouble:[endTime timeIntervalSinceDate:startTime]];
}

- (NSDate *)endTime {
    return endTime;
}

- (void)saveAttitude:(CMAttitude *)data {
    NSArray *attitude = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.roll], [NSNumber numberWithDouble:data.pitch], [NSNumber numberWithDouble:data.yaw], nil];
    [attitudeData addObject:attitude];
}

- (void)saveUserAcceleration:(CMAcceleration)data {
    NSArray *acceleration = [NSArray arrayWithObjects:[NSNumber numberWithDouble:data.x], [NSNumber numberWithDouble:data.y], [NSNumber numberWithDouble:data.z], nil];
    [accelData addObject:acceleration];
}

@end
