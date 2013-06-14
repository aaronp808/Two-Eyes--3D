//
//  DrawOptions.h
//  Two Eyes 3D
//
//  Created by Jerry Belich on 7/12/12.
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

@interface DrawOptions : NSObject {
    // An optional background image to draw over.
    UIImage *backImage;
    // Color of lines while drawing.
    UIColor *penDrawingColor;
    // Color of lines when drawing action is complete.
    UIColor *penColor;
    // Color of the label text.
    UIColor *labelTextColor;
    // Color of the label background.
    UIColor *labelBackColor;
    // Radius of the pen tool.
    CGFloat penRadius;
    // Radius of the eraser tool.
    CGFloat eraserRadius;
    // Origin of the Drawing component.
    CGPoint origin;
}

@property (nonatomic, retain) UIImage *backImage;
@property (nonatomic, retain) UIColor *penDrawingColor;
@property (nonatomic, retain) UIColor *penColor;
@property (nonatomic, retain) UIColor *labelTextColor;
@property (nonatomic, retain) UIColor *labelBackColor;
@property (nonatomic, assign) CGFloat penRadius;
@property (nonatomic, assign) CGFloat eraserRadius;
@property (nonatomic, assign) CGPoint origin;

// Static Methods
+ (UIColor *)getColorFromHex:(NSString *)aHexColor;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
