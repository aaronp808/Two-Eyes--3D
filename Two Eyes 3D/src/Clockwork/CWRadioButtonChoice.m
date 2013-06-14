//
//  CWRadioButtonChoice.m
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

#import "CWRadioButtonChoice.h"
#import "Logger.h"

@implementation CWRadioButtonChoice
@synthesize choiceType;

- (id)initWithOptions:(CWRadioButtonOptions *)aOptions imageName:(NSString *)aImageName caption:(NSString *)aCaption {
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self) {
        selected = NO;
        choiceType = imageChoice;
        options = aOptions;
        CGRect frame = self.frame;
        
        // Setup the choice items image.
        UIImage *itemImage = [UIImage imageNamed:aImageName];
        if (itemImage == nil) {
            LogError(@"Failed to load radio item image: %@", aImageName);
            return self;
        }
        imageView = [[UIImageView alloc] initWithImage:itemImage];
        frame.size.width = itemImage.size.width;
        
        if ([self createRadioStateViews] == NO) {
            LogWarn(@"Failed to load radio state images, generating stand-in images.");
        }
        [radioOnView setHidden:YES];
        
        if ((aCaption == NULL) || ([aCaption isEqualToString:@""])) {
            hasCaption = NO;
            frame.size.height = itemImage.size.height;
        } else {
            hasCaption = YES;
            
            // Fill in the caption text view.
            captionView = [[UITextView alloc] init];
            captionView.text = aCaption;
            captionView.font = [UIFont fontWithName:[options fontName] size:[options fontSize]];
            captionView.textColor = [CWRadioButtonChoice getColorFromHex:[options textColor]];
            captionView.editable = NO;
            captionView.scrollEnabled = NO;
            captionView.showsHorizontalScrollIndicator = NO;
            captionView.showsVerticalScrollIndicator = NO;
            [captionView sizeToFit];
            // Get size for layout.
            CGSize maxSize = CGSizeMake(itemImage.size.width, options.itemMaxDimension.height - itemImage.size.height);
            CGSize captionSize = [aCaption sizeWithFont:captionView.font constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
            [captionView setFrame:CGRectMake(0, itemImage.size.height, captionSize.width, captionSize.height + 25)];
            [self addSubview:captionView];
            
            frame.size.height = itemImage.size.height + captionView.frame.size.height;
        }
        
        if (([options radioPosition] == positionLeft) || ([options radioPosition] == positionRight)) {
            frame.size.width += radioOnView.image.size.width + [options radioDistance];
            
            if ([options radioPosition] == positionLeft) {
                [radioOnView setFrame:CGRectMake(0, (frame.size.height - radioOnView.image.size.height) / 2, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            } else {
                [radioOnView setFrame:CGRectMake(frame.size.width - radioOnView.image.size.width, (frame.size.height - radioOnView.image.size.height) / 2, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            }
        } else if (([options radioPosition] == positionTop) || ([options radioPosition] == positionBottom)) {
            frame.size.height += radioOnView.image.size.height + [options radioDistance];
            
            if ([options radioPosition] == positionTop) {
                [radioOnView setFrame:CGRectMake((frame.size.width - radioOnView.image.size.width) / 2, 0, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            } else {
                // TODO: Have the CWRadioButtonGroup dynamically position all the radio button images to the same level if
                // they are positioned under the caption text. For now, cheat a bit.
                if (hasCaption) {
                    [radioOnView setFrame:CGRectMake((frame.size.width - radioOnView.image.size.width) / 2, options.itemMaxDimension.height + 10, radioOnView.image.size.width, radioOnView.image.size.height)];
                } else {
                    [radioOnView setFrame:CGRectMake((frame.size.width - radioOnView.image.size.width) / 2, frame.size.height - radioOnView.image.size.height, radioOnView.image.size.width, radioOnView.image.size.height)];
                }
                [radioOffView setFrame:radioOnView.frame];
            }
        }
        [self addSubview:imageView];
        [self addSubview:radioOnView];
        [self addSubview:radioOffView];
        [self setFrame:frame];
    }
    
    return self;
}

- (id)initWithOptions:(CWRadioButtonOptions *)aOptions text:(NSString *)aText {
    
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self) {
        options = aOptions;
        choiceType = textChoice;
        if ([self createRadioStateViews] == NO) {
            LogWarn(@"Failed to load radio state images, generating stand-in images.");
        }
        [radioOnView setHidden:YES];
        
        // Fill in text view.
        textView = [[UITextView alloc] init];
        textView.text = aText;
        textView.editable = NO;
        textView.font = [UIFont fontWithName:[options fontName] size:[options fontSize]];
        textView.textColor = [CWRadioButtonChoice getColorFromHex:[options textColor]];
        //[textView setLineBreakMode:NSLineBreakByWordWrapping];
        [textView sizeToFit];
        CGSize textSize = [aText sizeWithFont:textView.font constrainedToSize:options.itemMaxDimension lineBreakMode:UILineBreakModeWordWrap];
        [textView setFrame:CGRectMake(0, 0, textSize.width + 25, textSize.height + 25)];
        // Get size for layout.
        CGSize labelSize = [aText sizeWithFont:[UIFont fontWithName:[options fontName] size:[options fontSize]] constrainedToSize:[options itemMaxDimension] lineBreakMode:UILineBreakModeTailTruncation];
        
        CGRect frame = self.frame;
        frame.size.width = labelSize.width;
        frame.size.height = labelSize.height;
        
        if (([options radioPosition] == positionLeft) || ([options radioPosition] == positionRight)) {
            frame.size.width += radioOnView.image.size.width + [options radioDistance];
            
            if (frame.size.height < radioOnView.image.size.height) {
                frame.size.height = radioOnView.image.size.height;
            }
            
            if ([options radioPosition] == positionLeft) {
                // Adjust the text view to right of the radio button.
                CGRect tFrame = textView.frame;
                tFrame.origin = CGPointMake(radioOnView.image.size.width + [options radioDistance], 4);
                [textView setFrame:tFrame];
                
                // Set the origin and size for the radio button.
                [radioOnView setFrame:CGRectMake(0, (textView.frame.size.height - radioOnView.image.size.height) / 2, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            } else {
                // Set the origin and size for the radio button.
                [radioOnView setFrame:CGRectMake(frame.size.width - radioOnView.image.size.width, (textView.frame.size.height - radioOnView.image.size.height) / 2, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            }
        } else if (([options radioPosition] == positionTop) || ([options radioPosition] == positionBottom)) {
            frame.size.height += radioOnView.image.size.height + [options radioDistance];
            
            if (frame.size.width < radioOnView.image.size.width) {
                frame.size.width = radioOnView.image.size.width;
            }

            if ([options radioPosition] == positionTop) {
                // Adjust the text view to below the radio button.
                CGRect tFrame = textView.frame;
                tFrame.origin = CGPointMake(0, radioOnView.image.size.height + [options radioDistance]);
                [textView setFrame:tFrame];
                
                // Set the origin and size for the radio button.
                [radioOnView setFrame:CGRectMake((frame.size.width - radioOnView.image.size.width) / 2, 0, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            } else {
                // Set the origin and size for the radio button.
                [radioOnView setFrame:CGRectMake((frame.size.width - radioOnView.image.size.width) / 2, frame.size.height - radioOnView.image.size.height, radioOnView.image.size.width, radioOnView.image.size.height)];
                [radioOffView setFrame:radioOnView.frame];
            }
        }
        [self addSubview:textView];
        [self addSubview:radioOnView];
        [self addSubview:radioOffView];
        [self setFrame:frame];
    }
    
    return self;
}

- (CWRadioButtonOptions *)getOptions {
    return options;
}

- (void)setSelected:(BOOL)aSelected {
    selected = aSelected;
    
    radioOnView.hidden = !selected;
    radioOffView.hidden = selected;
}

- (BOOL)isSelected {
    return selected;
}

- (BOOL)createRadioStateViews {
    BOOL error = NO;
    
    UIImage *radioOnImage = [UIImage imageNamed:[options radioOnName]];
    UIImage *radioOffImage = [UIImage imageNamed:[options radioOffName]];

    if ((radioOnImage == nil) || (radioOffImage == nil)) { 
        if (radioOnImage == nil) {
            LogWarn(@"Unable to load radio button on state image: %@", [options radioOnName]);
        }
        if (radioOffImage == nil) {
            LogWarn(@"Unable to load radio button off state image: %@", [options radioOffName]);
        }
        radioOnImage = [CWRadioButtonChoice createCircleWithColor:[UIColor blueColor] size:CGSizeMake(44.0f, 44.0f)];
        radioOffImage = [CWRadioButtonChoice createCircleWithColor:[UIColor whiteColor] size:CGSizeMake(44.0f, 44.0f)];
        error = YES;
    }
    radioOnView = [[UIImageView alloc] initWithImage:radioOnImage];
    radioOffView = [[UIImageView alloc] initWithImage:radioOffImage];
    return !error;
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

+ (UIImage *)createCircleWithColor:(UIColor *)aColor size:(CGSize)aSize {
	// Begin a graphics context of sufficient size.
	UIGraphicsBeginImageContext(aSize);
    
	// Get the context for CoreGraphics.
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Set stroking width, alpha, and color.
    CGContextSetLineWidth(context, 2.0);
    CGContextSetAlpha(context, 0.5);
	[[UIColor grayColor] setStroke];
    
    // Set the fill color.
    [aColor setFill];
    
	// Make circle rect 5 px from border.
	CGRect circleRect = CGRectMake(0, 0, aSize.width, aSize.height);
	circleRect = CGRectInset(circleRect, 5, 5);
    
	// Draw the circle.
    CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
	// Make image out of the bitmap context.
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// Free the context.
	UIGraphicsEndImageContext();
    
	return retImage;
}

@end
