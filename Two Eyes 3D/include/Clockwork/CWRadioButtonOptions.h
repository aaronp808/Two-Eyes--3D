//
//  CWRadioButtonOptions.h
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/24/12.
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

#ifndef CWRadioButtonOptions_h
#define CWRadioButtonOptions_h

#import <Foundation/Foundation.h>

typedef enum {
    imageType,
    textType
} CWRadioType;

typedef enum {
    positionTop,
    positionBottom,
    positionLeft,
    positionRight
} CWRadioButtonPosition;

typedef enum {
    layoutHorizontal,
    layoutVertical
} CWRadioItemLayout;

@interface CWRadioButtonOptions : NSObject {
    // Whether it's an image or text based radio control.
    CWRadioType radioType;
    // Font to be used for text.
    NSString *fontName;
    // Font size of text.
    int fontSize;
    // Font color of the text.
    NSString *textColor;
    // On which side of each item it's radio button is.
    CWRadioButtonPosition radioPosition;
    // If items flow is across or down.
    CWRadioItemLayout itemLayout;
    // Pixels between radio button and item it's associated with.
    int radioDistance;
    // Pixels between radio items.
    int itemBuffer;
    // How many items across or down until it wraps to a new row or column.
    // 0 itemsUntilWrap means never wrap.
    int itemsUntilWrap;
    // The origin of the radio buttons view.
    CGPoint radioOrigin;
    // The maximum width and height of each item.
    CGSize itemMaxDimension;
    // The image name for the ON state.
    NSString *radioOnName;
    // The image name for the OFF state.
    NSString *radioOffName;
}

@property (nonatomic, assign) CWRadioType radioType;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) int fontSize;
@property (nonatomic, copy) NSString *textColor;
@property (nonatomic, assign) CWRadioButtonPosition radioPosition;
@property (nonatomic, assign) CWRadioItemLayout itemLayout;
@property (nonatomic, assign) int radioDistance;
@property (nonatomic, assign) int itemBuffer;
@property (nonatomic, assign) int itemsUntilWrap;
@property (nonatomic, assign) CGPoint radioOrigin;
@property (nonatomic, assign) CGSize itemMaxDimension;
@property (nonatomic, copy) NSString *radioOnName;
@property (nonatomic, copy) NSString *radioOffName;

@end

#endif
