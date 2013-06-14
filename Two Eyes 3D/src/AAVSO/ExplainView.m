//
//  ExplainView.m
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

#import "ExplainView.h"

@implementation ExplainView

@synthesize editing;

static int const kInputFieldHeight = 54;
static int const kInputFieldWidth = 790;
NSString *const kExplainStartedEditing = @"explain_started_editing";
NSString *const kExplainStoppedEditing = @"explain_stopped_editing";
NSString *const kExplainTextChanged = @"explain_text_changed";
NSString *const kExplainTextKey = @"explain_text";

- (id)initWithOrigin:(CGPoint)origin
{
    CGRect newFrame = CGRectMake(origin.x, origin.y, 848.0f, 122.0f);
    self = [super initWithFrame:newFrame];
    if (self) {
        [self setupComponent];
    }
    return self;
}

- (void)setupComponent {
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ExplainTextArea.png"]];
    [self addSubview:background];
    
    explainInput = [[UITextView alloc] initWithFrame:CGRectMake(17, 40, 811, 67)];
    explainInput.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    explainInput.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    explainInput.backgroundColor = [UIColor clearColor];
    explainInput.scrollEnabled = NO;
    explainInput.showsVerticalScrollIndicator = NO;
    explainInput.showsHorizontalScrollIndicator = NO;
    explainInput.bounces = NO;
    explainInput.bouncesZoom = NO;
    explainInput.returnKeyType = UIReturnKeyDone;
    explainInput.autocorrectionType = UITextAutocorrectionTypeYes;
    explainInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    explainInput.userInteractionEnabled = YES;
    explainInput.delegate = self;
    [self addSubview:explainInput];

    explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 10, 277, 22)];
    explainLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22.0f];
    explainLabel.textColor = [UIColor colorWithRed:0.29f green:0.29f blue:0.29f alpha:1.0f];
    explainLabel.backgroundColor = [UIColor clearColor];
    explainLabel.userInteractionEnabled = NO;
    [self addSubview:explainLabel];
    
    // Initialize Values
    editing = NO;
    firstEdit = NO;

    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.window];

    self.userInteractionEnabled = YES;
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

#pragma mark -
#pragma mark Methods

- (void)setLabel:(NSString *)label {
    explainLabel.text = label;
}

- (NSString *)explainText {
    return explainInput.text;
}

- (BOOL)editing {
    return editing;
}

- (void)stopEditing {
    if (explainInput.isFirstResponder) {
        [explainInput resignFirstResponder];
    }
}

#pragma mark -
#pragma mark TextView Delegate 

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString *)aText {
    
    if ([aText isEqualToString:@"\n"]) {
        [aTextView resignFirstResponder];
    }
    
    if (firstEdit == NO) {
        explainInput.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.9f];
        explainInput.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        firstEdit = YES;
    }
    
    if ((aRange.location + aRange.length) > aTextView.text.length) {
        LogWarn(@"Range provided is invalid, text length: %d, location: %d, length: %d", aTextView.text.length, aRange.location, aRange.length);
        return NO;
    }
    NSString *newText = [aTextView.text stringByReplacingCharactersInRange:aRange withString:aText];
    CGSize strSize = [newText sizeWithFont:aTextView.font constrainedToSize:CGSizeMake(kInputFieldWidth, 1000) lineBreakMode:UILineBreakModeWordWrap];
    
    if (strSize.height > kInputFieldHeight) { // Can't enter more text.
        return NO;
    } else if (strSize.width > kInputFieldWidth) {
        return NO; // Can't enter more text.
    } else {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:explainInput.text forKey:kExplainTextKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExplainTextChanged object:self userInfo:dict];
        return YES; // Handle more text.
    }
}

- (void)setViewMovedUp:(BOOL)movedUp byAmount:(CGFloat)height overDuration:(CGFloat)duration {
    CGRect rect = self.superview.frame;
    
    if (movedUp) {
        editing = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kExplainStartedEditing object:self];
        // Move the view's origin up so that the text field that will be hidden moves above the keyboard.
        // Increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= height;
        rect.size.height += height;
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
                             [[NSNotificationCenter defaultCenter] postNotificationName:kExplainStoppedEditing object:self];
                         }
                     }];
}

#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([explainInput isFirstResponder] && self.superview.frame.origin.y >= 0) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [self setViewMovedUp:YES byAmount:kbSize.width overDuration:animationDuration];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    if ([explainInput isFirstResponder] && self.superview.frame.origin.y < 0) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [self setViewMovedUp:NO byAmount:kbSize.width overDuration:animationDuration];
    }
}

@end
