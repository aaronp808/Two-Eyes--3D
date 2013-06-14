//
//  DrawOptions.m
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

#import "DrawOptions.h"

@implementation DrawOptions

@synthesize backImage;
@synthesize penDrawingColor;
@synthesize penColor;
@synthesize labelTextColor;
@synthesize labelBackColor;
@synthesize penRadius;
@synthesize eraserRadius;
@synthesize origin;

- (id)init {
    
    if (self = [super init]) {
        // Initialization Code
        backImage = [DrawOptions imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(10, 10)];
        penDrawingColor = [UIColor redColor];
        penColor = [UIColor blackColor];
        labelTextColor = [UIColor blackColor];
        labelBackColor = [UIColor whiteColor];
        penRadius = 3.0f;
        eraserRadius = 6.0f;
        origin = CGPointMake(0, 0);
    }
    
    return self;
}

#pragma mark -
#pragma mark Static Methods

+ (UIColor *)getColorFromHex:(NSString *)aHexColor {
    NSScanner *scanner = [NSScanner scannerWithString:aHexColor];
    uint baseColor;
    [scanner scanHexInt:&baseColor];
    CGFloat red   = ((baseColor & 0xFF000000) >> 24) / 255.0f;
    CGFloat green = ((baseColor & 0x00FF0000) >> 16) / 255.0f;
    CGFloat blue  = ((baseColor & 0x0000FF00) >>  8) / 255.0f;
    CGFloat alpha =  (baseColor & 0x000000FF) / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    // Create a context of the appropriate size
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Build a rect of appropriate size at origin 0,0
    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    
    // Set the fill color
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    
    // Fill the color
    CGContextFillRect(currentContext, fillRect);
    
    // Snap the picture and close the context
    UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retval;
}


@end
