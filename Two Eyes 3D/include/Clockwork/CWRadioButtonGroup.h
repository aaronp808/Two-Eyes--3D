//
//  CWRadioButtonGroup.h
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

#ifndef CWRadioButtonGroup_h
#define CWRadioButtonGroup_h

#import <UIKit/UIKit.h>

@class CWRadioButtonOptions;
@class CWRadioButtonChoice;

extern NSString *const kCWRadioButtonTapped;
extern NSString *const kCWRadioIndexKey;

@interface CWRadioButtonGroup : UIView {
    CWRadioButtonOptions *options;
    NSMutableArray *radioButtons;
    UIImage *radioOnState;
    UIImage *radioOffState;
    CGPoint nextPosition;
    int maxItemHeight;
    int maxItemWidth;
    BOOL enabled;
}

@property (nonatomic, retain) NSMutableArray *radioButtons;
@property (nonatomic, retain) UIImage *radioOnState;
@property (nonatomic, retain) UIImage *radioOffState;
@property (nonatomic, assign) BOOL enabled;

- (id)initWithOptions:(CWRadioButtonOptions *)options;

- (BOOL)addChoice:(CWRadioButtonChoice *)aChoice;
- (BOOL)addImageButton:(NSString *)aImageName;
- (BOOL)addImageButton:(NSString *)aImageName caption:(NSString *)aCaption;
- (BOOL)addTextButton:(NSString *)aText;
- (BOOL)formatButton:(CWRadioButtonChoice *)aChoice;
//- (void)removeButtonAtIndex:(int)aIndex;
- (void)setOrigin:(CGPoint)aOrigin;
- (void)setSelected:(int)aIndex;
- (int)getSelected;
- (void)clearAll;

- (void)resizeToFitSubviews;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (CWRadioButtonOptions *)getOptions;

@end

#endif