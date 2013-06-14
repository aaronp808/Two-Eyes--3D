//
//  DrawView.h
//  Two Eyes 3D
//
//  Created by Jerry Belich on 6/4/12.
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

#import <UIKit/UIKit.h>

@class DrawOptions;

typedef enum {
    kDrawState,
    kEraseState,
    kLabelState,
    kInvalidTool
} ToolState;

// Notification Keys
extern NSString *const kDrawingChangedNotif;

@interface DrawView : UIView <UITextViewDelegate> {
    IBOutlet UIView *view;
    ToolState toolState;
    DrawOptions *_options;
    
    UITapGestureRecognizer *tapRecognizer;
    CGPoint previousPoint;
    NSMutableArray *drawnPoints;
    NSMutableArray *drawRecording;
    
    BOOL editing;
    UITextView *cleanLabel;
    UIImage *cleanImage;
    IBOutlet UIImageView *backgroundImage;
    IBOutlet UIView *drawingView;
    IBOutlet UIImageView *drawingImage;
    IBOutlet UIButton *drawButton;
    IBOutlet UIButton *eraseButton;
    IBOutlet UIButton *labelButton;
}

@property (nonatomic, retain) NSMutableArray *drawRecording;
@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIView *drawingView;
@property (nonatomic, readwrite, retain) IBOutlet UIImageView *drawingImage;

- (UIImage *)getDrawing;

/** Draws a line to an image and returns the resulting image */
- (UIImage *)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint image:(UIImage *)image;

/** Draws a path to an image and returns the resulting image */
- (UIImage *)drawPathWithPoints:(NSArray *)points image:(UIImage *)image;

/** Ramer–Douglas–Peucker algorithm */
- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon;

/** Returns the perpendicular distance from a point to a line */
- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB;

/** Returns an array of vertices that include interpolated positions. */
- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments;

- (id)initWithOptions:(DrawOptions *)aOptions;
- (void)setupComponent;
- (IBAction)drawTapped:(id)sender;
- (IBAction)eraseTapped:(id)sender;
- (IBAction)labelTapped:(id)sender;

- (NSArray *)getJsonLine:(NSArray *)aPoints;
- (void)createLabelAt:(CGPoint)aPoint;

@end
