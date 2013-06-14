//
//  CWRadioButtonGroup.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/16/12.
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

#import "CWRadioButtonGroup.h"
#import "CWRadioButtonOptions.h"
#import "CWRadioButtonChoice.h"
#import "Logger.h"

@implementation CWRadioButtonGroup
@synthesize radioButtons;
@synthesize radioOnState;
@synthesize radioOffState;

NSString *const kCWRadioButtonTapped = @"cw_radio_button_tapped";
NSString *const kCWRadioIndexKey = @"cw_radio_index";

- (id)initWithOptions:(CWRadioButtonOptions *)aOptions {

    self = [super initWithFrame:CGRectMake(aOptions.radioOrigin.x, aOptions.radioOrigin.y, 0, 0)];
    if (self) {
        [self setUserInteractionEnabled:YES];
        options = aOptions;
        radioButtons = [[NSMutableArray alloc] init];
        nextPosition = CGPointMake(0, 0);
    }
    
    return self;
}

- (BOOL)addChoice:(CWRadioButtonChoice *)aChoice {
    return [self formatButton:aChoice];
}

- (BOOL)addImageButton:(NSString *)aImageName {
    return [self addImageButton:aImageName caption:@""];
}

- (BOOL)addImageButton:(NSString *)aImageName caption:(NSString *)aCaption {
    if ([options radioType] == imageType) {
        CWRadioButtonChoice *choice = [[CWRadioButtonChoice alloc] initWithOptions:options imageName:aImageName caption:aCaption];
        return [self formatButton:choice];
    }
    LogWarn(@"Unable to add image radio button to text radio control.");
    return NO;
}

- (BOOL)addTextButton:(NSString *)aText {
    if ([options radioType] == textType) {
        CWRadioButtonChoice *choice = [[CWRadioButtonChoice alloc] initWithOptions:options text:aText];
        return [self formatButton:choice];
    }
    LogWarn(@"Unable to add text radio button to image radio control.");
    return NO;
}

- (BOOL)formatButton:(CWRadioButtonChoice *)aChoice {
    [self.radioButtons addObject:aChoice];
    CGRect cFrame = aChoice.frame;
    cFrame.origin = nextPosition;
    aChoice.frame = cFrame;
    if (([options itemsUntilWrap] == 0) || ([self.radioButtons count] % [options itemsUntilWrap]) != 0) {
        if ([options itemLayout] == layoutVertical) {
            nextPosition.y += cFrame.size.height + [options itemBuffer];
        } else { // layoutHorizontal
            nextPosition.x += cFrame.size.width + [options itemBuffer];
        }
    } else {
        if ([options itemLayout] == layoutVertical) {
            LogDebug(@"Wrapping not yet implemented. Need to calculate widest item to keep columns in line.");
        } else { // layoutHorizontal
            LogDebug(@"Wrapping not yet implemented. Need to calculate tallest item to keep rows in line.");
        }
    }
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [aChoice addGestureRecognizer:tapRecognizer];
    [self addSubview:aChoice];
    [self resizeToFitSubviews];
    
    return YES;
}

/*- (void)removeButtonAtIndex:(int)aIndex {
    if ((aIndex >= 0) && (aIndex < [self.radioButtons count])) {
        [[self.radioButtons objectAtIndex:aIndex] removeFromSuperview];
        [self.radioButtons removeObjectAtIndex:aIndex];
    } else {
        NSLog(@"[WARN] Index provided to CWRadioButtonGroup is invalid: %d", aIndex);
    }
}*/

- (BOOL)enabled {
    return enabled;
}

- (void)setEnabled:(BOOL)value {
    enabled = value;
    [self setUserInteractionEnabled:enabled];
}

- (void)setOrigin:(CGPoint)aOrigin {
    options.radioOrigin = aOrigin;
    CGRect frame = self.frame;
    frame.origin = options.radioOrigin;
    self.frame = frame;
}

- (void)setSelected:(int)aIndex {
    if ((aIndex >= 0) && (aIndex < [self.radioButtons count])) {
        CWRadioButtonChoice *choice;
        for (int i = 0; i < [self.radioButtons count]; i++) {
            if (i != aIndex) {
                choice = [self.radioButtons objectAtIndex:i];
                [choice setSelected:NO];
            }
        }
        choice = [self.radioButtons objectAtIndex:aIndex];
        [choice setSelected:YES];
    } else {
        LogWarn(@"Index provided to CWRadioButtonGroup is invalid: %d", aIndex);
    }
}

- (int)getSelected {
    for (int i = 0; i < [self.radioButtons count]; i++) {
        CWRadioButtonChoice *choice = [self.radioButtons objectAtIndex:i];
        if (choice.isSelected) {
            return i;
        }
    }
    return -1;
}

- (void)clearAll {
    for (int i = 0; i < [self.radioButtons count]; i++) {
        CWRadioButtonChoice *choice = [self.radioButtons objectAtIndex:i];
        [choice setSelected:NO];
    }
}

- (CWRadioButtonOptions *)getOptions {
    return options;
}

- (void)resizeToFitSubviews {
    CGRect tmpFrame = CGRectNull;
    
    for (UIView *v in [self subviews]) {
        tmpFrame = CGRectUnion(tmpFrame, v.frame);
    }
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, tmpFrame.size.width, tmpFrame.size.height)];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        for (int i = 0; i < [self.radioButtons count]; i++) {
            CWRadioButtonChoice *choice = [self.radioButtons objectAtIndex:i];
            if (recognizer.view == choice) {
                [self setSelected:i];
                NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:i] forKey:kCWRadioIndexKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCWRadioButtonTapped object:self userInfo:dict];
            }
        }
    }
}

@end
