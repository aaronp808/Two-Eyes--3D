//
//  DrawView.m
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

#import "DrawView.h"
#import "DrawOptions.h"

@implementation DrawView
@synthesize drawRecording;
@synthesize view;
@synthesize backgroundImage;
@synthesize drawingView;
@synthesize drawingImage;

// Notification Keys
NSString *const kDrawingChangedNotif = @"drawing_changed";

// Draw Recording Keys
NSString *const kDrawnKey = @"drawn";
NSString *const kErasedKey = @"erased";
NSString *const kLabelKey = @"label";
NSString *const kLabelTextKey = @"text";
NSString *const kLabelOriginKey = @"origin";

- (id)initWithOptions:(DrawOptions *)aOptions {

    self = [super initWithFrame:CGRectMake(aOptions.origin.x, aOptions.origin.y, 849.0f, 332.0f)];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"DrawView" owner:self options:nil];
        _options = aOptions;
        [self setupComponent];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupComponent];
}

- (void)setupComponent {
    // Register Tap gesture for labels.
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.enabled = NO;
    [drawingView addGestureRecognizer:tapRecognizer];
    
    // Setup Label
    cleanLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 25, 30)];
    cleanLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25.0f];
    cleanLabel.backgroundColor = _options.labelBackColor;
    cleanLabel.textColor = _options.labelTextColor;
    cleanLabel.scrollEnabled = NO;
    cleanLabel.showsVerticalScrollIndicator = NO;
    cleanLabel.showsHorizontalScrollIndicator = NO;
    cleanLabel.bounces = NO;
    cleanLabel.bouncesZoom = NO;
    cleanLabel.returnKeyType = UIReturnKeyDone;
    cleanLabel.autocorrectionType = UITextAutocorrectionTypeNo;
    cleanLabel.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cleanLabel.delegate = self;
    
    drawRecording = [[NSMutableArray alloc] init];
    
    [self addSubview:self.view];
    CGRect frame = self.frame;
    frame.origin.x = self.frame.origin.x;
    frame.origin.y = self.frame.origin.y;
    self.frame = frame;
    
    backgroundImage.image = _options.backImage;

    drawnPoints = [NSMutableArray array];
    drawButton.selected = YES;
    toolState = kDrawState;
    editing = NO;
    
    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

- (UIImage *)getDrawing {
    return drawingImage.image;
}

#pragma mark -
#pragma mark Button Handlers

- (IBAction)drawTapped:(id)sender {
    if (toolState == kDrawState) {
        return;
    }
    eraseButton.selected = NO;
    labelButton.selected = NO;
    tapRecognizer.enabled = NO;
    drawButton.selected = YES;
    toolState = kDrawState;
}

- (IBAction)eraseTapped:(id)sender {
    if (toolState == kEraseState) {
        return;
    }
    drawButton.selected = NO;
    labelButton.selected = NO;
    tapRecognizer.enabled = NO;
    eraseButton.selected = YES;
    toolState = kEraseState;
}

- (IBAction)labelTapped:(id)sender {
    if (toolState == kLabelState) {
        return;
    }
    eraseButton.selected = NO;
    drawButton.selected = NO;
    labelButton.selected = YES;
    tapRecognizer.enabled = YES;
    toolState = kLabelState;
}


- (UIImage *)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint image:(UIImage *)image {
    CGSize screenSize = drawingImage.frame.size;
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(screenSize);
    }
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (toolState == kDrawState) {
        CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
        CGContextSetLineWidth(currentContext, _options.penRadius);
        CGContextSetStrokeColorWithColor(currentContext, _options.penDrawingColor.CGColor);
    } else if (toolState == kEraseState) {
        CGContextSetBlendMode(currentContext, kCGBlendModeClear);
        CGContextSetLineWidth(currentContext, _options.eraserRadius);
        CGContextSetRGBStrokeColor(currentContext, 0, 0, 0, 1);
    }
    CGContextSetShouldAntialias(currentContext, YES);
    CGContextSetLineCap(currentContext, kCGLineCapRound);
    
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, fromPoint.x, fromPoint.y);
	CGContextAddLineToPoint(currentContext, toPoint.x, toPoint.y);
	CGContextStrokePath(currentContext);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return ret;
}

- (UIImage *)drawPathWithPoints:(NSArray *)points image:(UIImage *)image {
    CGSize screenSize = drawingImage.frame.size;
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(screenSize);
    }
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    if (toolState == kDrawState) {
        CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
        CGContextSetLineWidth(currentContext, _options.penRadius);
        CGContextSetStrokeColorWithColor(currentContext, _options.penColor.CGColor);
    } else if (toolState == kEraseState) {
        CGContextSetBlendMode(currentContext, kCGBlendModeClear);
        CGContextSetLineWidth(currentContext, _options.eraserRadius);
        CGContextSetRGBStrokeColor(currentContext, 0, 0, 0, 1);
    }
    CGContextSetShouldAntialias(currentContext, YES);
    CGContextSetLineCap(currentContext, kCGLineCapRound);
    
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
	CGContextBeginPath(currentContext);
    
    int count = [points count];
    CGPoint point = [[points objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(currentContext, point.x, point.y);
    for(int i = 1; i < count; i++) {
        point = [[points objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(currentContext, point.x, point.y);
    }
    CGContextStrokePath(currentContext);
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return ret;
}

- (NSArray *)douglasPeucker:(NSArray *)points epsilon:(float)epsilon {
    int count = [points count];
    if(count < 3) {
        return points;
    }
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    //If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)] epsilon:epsilon];
        
        NSArray *recResults2 = [self douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)] epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } else {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

- (float)perpendicularDistance:(CGPoint)point lineA:(CGPoint)lineA lineB:(CGPoint)lineB {
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    return sin(angle) * lenV2;
}

- (NSArray *)catmullRomSpline:(NSArray *)points segments:(int)segments {
    int count = [points count];
    if (count < 4) {
        return points;
    }
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count-2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        int i = count-2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]]; 
    
    return resultArray;
}

- (void)createLabelAt:(CGPoint)aPoint {
    cleanImage = drawingImage.image;
    
    CGRect frame = cleanLabel.frame;
    frame.origin = aPoint;
    cleanLabel.frame = frame;
    cleanLabel.alpha = 1;

    [drawingView addSubview:cleanLabel];
    [cleanLabel becomeFirstResponder];
}

#pragma mark -
#pragma mark TextView Delegate

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString *)aText {
    if ([aText isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
        return NO;
    }
    CGSize size = [[NSString stringWithFormat:@"%@%@O", aTextView.text, aText] sizeWithFont:aTextView.font];
    if (size.width > (drawingView.frame.size.width - aTextView.frame.origin.x)) {
        return NO;
    }
    aTextView.frame = CGRectMake(aTextView.frame.origin.x, aTextView.frame.origin.y, size.width, aTextView.frame.size.height);
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView {

}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    if (([aTextView.text length] > 0) && aTextView.isFirstResponder) {
        CGSize screenSize = drawingImage.frame.size;
        if (UIGraphicsBeginImageContextWithOptions != NULL) {
            UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.0);
        } else {
            UIGraphicsBeginImageContext(screenSize);
        }
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
        CGContextSetShouldAntialias(currentContext, YES);
        
        [cleanImage drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        CGContextSetFillColorWithColor(currentContext, _options.labelBackColor.CGColor);
        CGContextFillRect(currentContext, aTextView.frame);
        CGContextSetFillColorWithColor(currentContext, _options.labelTextColor.CGColor);
        
        CGRect rect = aTextView.frame;
        rect.origin.x += 8.0f;
        rect.origin.y -= 1.5f;
        [aTextView.text drawInRect:rect withFont:aTextView.font];
        
        drawingImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Record the label we set.
        NSMutableDictionary *label = [[NSMutableDictionary alloc] init];
        NSArray *origin = [NSArray arrayWithObjects:[NSNumber numberWithFloat:aTextView.frame.origin.x], [NSNumber numberWithFloat:aTextView.frame.origin.y], nil];
        [label setObject:[NSDictionary dictionaryWithObjectsAndKeys:aTextView.text, kLabelTextKey, origin, kLabelOriginKey, nil] forKey:kLabelKey];
        [drawRecording addObject:label];
        
        aTextView.alpha = 0;
        aTextView.text = @"";
        aTextView.frame = CGRectMake(0, 0, 25, 30);
    }
    return YES;
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    if ([cleanLabel isFirstResponder] && self.superview.frame.origin.y >= 0) {
        NSDictionary *info = [notification userInfo];
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self setViewMovedUp:YES byAmount:_options.origin.y - 45 overDuration:animationDuration];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([cleanLabel isFirstResponder] && self.superview.frame.origin.y < 0) {
        NSDictionary *info = [notification userInfo];
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [self setViewMovedUp:NO byAmount:_options.origin.y - 45 overDuration:animationDuration];
    }
}

- (void)setViewMovedUp:(BOOL)movedUp byAmount:(CGFloat)height overDuration:(CGFloat)duration {
    CGRect rect = self.superview.frame;
    if (movedUp) {
        editing = YES;
        // Move the view's origin up so that the text field that will be hidden moves above the keyboard.
        // Increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= height;
        rect.size.height += height;
        drawButton.enabled = NO;
        eraseButton.enabled = NO;
        labelButton.enabled = NO;
    } else {
        // Revert back to the normal state.
        rect.origin.y += height;
        rect.size.height -= height;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.superview.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         if (!movedUp) {
                             editing = NO;
                             [cleanLabel removeFromSuperview];
                             drawButton.enabled = YES;
                             eraseButton.enabled = YES;
                             labelButton.enabled = YES;
                         }
                     }];
}

#pragma mark - Touch handlers

- (void)tapDetected:(UIGestureRecognizer *)sender {
    if (toolState == kLabelState && !editing) {
        CGPoint currentPoint = [sender locationInView:drawingView];
        [self createLabelAt:currentPoint];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDrawingChangedNotif object:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((toolState == kDrawState) || (toolState == kEraseState)) {
        // retrieve touch point
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:drawingView];
        
        // record touch points to use as input to our line smoothing algorithm
        [drawnPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
        
        previousPoint = currentPoint;
        
        // to be able to replace the jagged polylines with the smooth polylines, we
        // need to save the unmodified image
        cleanImage = drawingImage.image;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((toolState == kDrawState) || (toolState == kEraseState)) {
        // retrieve touch point
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:drawingView];
        
        // record touch points to use as input to our line smoothing algorithm
        [drawnPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
        
        // draw line from the current point to the previous point
        drawingImage.image = [self drawLineFromPoint:previousPoint toPoint:currentPoint image:drawingImage.image];
        
        previousPoint = currentPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((toolState == kDrawState) || (toolState == kEraseState)) {
        NSArray *generalizedPoints = [self douglasPeucker:drawnPoints epsilon:2];
        NSArray *splinePoints = [self catmullRomSpline:generalizedPoints segments:4];
        if ([drawnPoints count] > 1) {
            drawingImage.image = [self drawPathWithPoints:splinePoints image:cleanImage];
        } else {
            CGPoint point = [[drawnPoints objectAtIndex:0] CGPointValue];
            point.x += 0.1f;
            point.y += 0.1f;
            [drawnPoints addObject:[NSValue valueWithCGPoint:point]];
            drawingImage.image = [self drawPathWithPoints:drawnPoints image:cleanImage];
        }
        
        NSMutableDictionary *line = [[NSMutableDictionary alloc] init];
        if (toolState == kDrawState) {
            [line setObject:[self getJsonLine:splinePoints] forKey:kDrawnKey];
        } else {
            [line setObject:[self getJsonLine:splinePoints] forKey:kErasedKey];
        }
        [drawRecording addObject:line];
        [drawnPoints removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDrawingChangedNotif object:self];
    } else if (toolState == kLabelState && !editing) {
        // retrieve touch point
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:drawingView];
        
        [self createLabelAt:currentPoint];
    }
}

- (NSArray *)getJsonLine:(NSArray *)aPoints {
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    for (NSValue *val in aPoints) {
        CGPoint point = [val CGPointValue];
        [points addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat:point.y], nil]];
    }
    return (NSArray *)points;
}

@end
