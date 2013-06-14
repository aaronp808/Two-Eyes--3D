//
//  CWPinEntry.m
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

#import "CWPinEntry.h"
#import "CWPinTextField.h"

@implementation CWPinEntry

NSString *const kCWPinEntryActiveNotif = @"cw_pin_entry_active";
NSString *const kCWPinEntryCompleteNotif = @"cw_pin_entry_complete";
NSString *const kCWPinEntryAuthorizedNotif = @"cw_pin_entry_authorized";
NSString *const kCWPinEntryUnauthorizedNotif = @"cw_pin_entry_unauthorized";

- (id)initWithOrigin:(CGPoint)origin {
    bigFrame = CGRectMake(origin.x - 16, origin.y - 133, 364.0f, 168.0f);
    origFrame = CGRectMake(origin.x, origin.y, 35.0f, 35.0f);
    self = [super initWithFrame:origFrame];
    if (self) {
        [self setupComponent];
    }
    return self;
}

- (void)setupComponent {
    pinNum = @"0000";
    enabled = YES;
    
    keyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyButton setImage:[UIImage imageNamed:@"PinKeyButton.png"] forState:UIControlStateNormal];
    [keyButton setImage:[UIImage imageNamed:@"PinKeyButtonSelected.png"] forState:UIControlStateSelected];
    keyButton.frame = CGRectMake(0, 0, 35, 35);
    [keyButton addTarget:self 
               action:@selector(keyButtonTapped:)
     forControlEvents:UIControlEventTouchDown];
    
    inputImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinEntry.png"]];
    
    keyOne = [[CWPinTextField alloc] initWithFrame:CGRectMake(14, 30, 74, 74)];
    //keyOne.userInteractionEnabled = NO;
    keyOne.borderStyle = UITextBorderStyleNone;
    keyOne.secureTextEntry = YES;
    keyOne.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    keyOne.font = [UIFont boldSystemFontOfSize:30];
    keyOne.placeholder = @"";
    keyOne.autocorrectionType = UITextAutocorrectionTypeNo;
    keyOne.spellCheckingType = UITextSpellCheckingTypeNo;
    keyOne.keyboardType = UIKeyboardTypeNumberPad;
    keyOne.returnKeyType = UIReturnKeyDone;
    keyOne.clearButtonMode = UITextFieldViewModeNever;
    keyOne.clearsOnBeginEditing = YES;
    keyOne.textAlignment = UITextAlignmentCenter;
    keyOne.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    keyOne.delegate = self;
    
    keyTwo = [[CWPinTextField alloc] initWithFrame:CGRectMake(102, 30, 74, 74)];
    //keyTwo.userInteractionEnabled = NO;
    keyTwo.borderStyle = UITextBorderStyleNone;
    keyTwo.secureTextEntry = YES;
    keyTwo.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    keyTwo.font = [UIFont boldSystemFontOfSize:30];
    keyTwo.placeholder = @"";
    keyTwo.autocorrectionType = UITextAutocorrectionTypeNo;
    keyTwo.spellCheckingType = UITextSpellCheckingTypeNo;
    keyTwo.keyboardType = UIKeyboardTypeNumberPad;
    keyTwo.returnKeyType = UIReturnKeyDone;
    keyTwo.clearButtonMode = UITextFieldViewModeNever;
    keyTwo.clearsOnBeginEditing = YES;
    keyTwo.textAlignment = UITextAlignmentCenter;
    keyTwo.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    keyTwo.delegate = self;
    
    keyThree = [[CWPinTextField alloc] initWithFrame:CGRectMake(190, 30, 74, 74)];
    //keyThree.userInteractionEnabled = NO;
    keyThree.borderStyle = UITextBorderStyleNone;
    keyThree.secureTextEntry = YES;
    keyThree.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    keyThree.font = [UIFont boldSystemFontOfSize:30];
    keyThree.placeholder = @"";
    keyThree.autocorrectionType = UITextAutocorrectionTypeNo;
    keyThree.spellCheckingType = UITextSpellCheckingTypeNo;
    keyThree.keyboardType = UIKeyboardTypeNumberPad;
    keyThree.returnKeyType = UIReturnKeyDone;
    keyThree.clearButtonMode = UITextFieldViewModeNever;
    keyThree.clearsOnBeginEditing = YES;
    keyThree.textAlignment = UITextAlignmentCenter;
    keyThree.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    keyThree.delegate = self;
    
    keyFour = [[CWPinTextField alloc] initWithFrame:CGRectMake(278, 30, 74, 74)];
    //keyFour.userInteractionEnabled = NO;
    keyFour.borderStyle = UITextBorderStyleNone;
    keyFour.secureTextEntry = YES;
    keyFour.textColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    keyFour.font = [UIFont boldSystemFontOfSize:30];
    keyFour.placeholder = @"";
    keyFour.autocorrectionType = UITextAutocorrectionTypeNo;
    keyFour.spellCheckingType = UITextSpellCheckingTypeNo;
    keyFour.keyboardType = UIKeyboardTypeNumberPad;
    keyFour.returnKeyType = UIReturnKeyDone;
    keyFour.clearButtonMode = UITextFieldViewModeNever;
    keyFour.clearsOnBeginEditing = YES;
    keyFour.textAlignment = UITextAlignmentCenter;
    keyFour.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    keyFour.delegate = self;
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 364, 128)];
    inputView.alpha = 0;
    [inputView addSubview:inputImage];
    [inputView addSubview:keyOne];
    [inputView addSubview:keyTwo];
    [inputView addSubview:keyThree];
    [inputView addSubview:keyFour];
    
    [self addSubview:keyButton];
    //[self addSubview:inputView];
    
    // Register for keyboard notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.window];
}

- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

- (void)resetFields {
    keyOne.text = @"";
    keyTwo.text = @"";
    keyThree.text = @"";
    keyFour.text = @"";
}

- (BOOL)setPinNum:(NSString *)value {
    if (value.length != 4) {
        return NO;
    }
    pinNum = value;
    return YES;
}

- (BOOL)enabled {
    return enabled;
}

- (void)setEnabled:(BOOL)value {
    enabled = value;
    [self setUserInteractionEnabled:enabled];
}

#pragma mark -
#pragma mark TextField Delegate

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ((string.length > 1) || (aTextField.text.length >= 1)) {
        return NO;
    }
    if (aTextField == keyOne) {
        keyOne.text = string;
        [keyTwo becomeFirstResponder];
    } else if (aTextField == keyTwo) {
        keyTwo.text = string;
        [keyThree becomeFirstResponder];
    } else if (aTextField == keyThree) {
        keyThree.text = string;
        [keyFour becomeFirstResponder];
    } else if (aTextField == keyFour) {
        keyFour.text = string;
        [keyFour resignFirstResponder];
    } else {
        [aTextField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField {
    if (aTextField.text.length == 1) {
        return NO;
    }
    if (aTextField == keyOne) {
        return YES;
    } else if (aTextField == keyTwo) {
        if (keyOne.text.length != 1) {
            [keyOne becomeFirstResponder];
        } else {
            return YES;
        }
    } else if (aTextField == keyThree) {
        if (keyOne.text.length != 1) {
            [keyOne becomeFirstResponder];
        } else if (keyTwo.text.length != 1) {
            [keyTwo becomeFirstResponder];
        } else {
            return YES;
        }
    } else if (aTextField == keyFour) {
        if (keyOne.text.length != 1) {
            [keyOne becomeFirstResponder];
        } else if (keyTwo.text.length != 1) {
            [keyTwo becomeFirstResponder];
        } else if (keyThree.text.length != 1) {
            [keyThree becomeFirstResponder];
        } else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    [aTextField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark Event Handlers

- (void)keyButtonTapped:(id)sender {
    if (editing == NO) {
        self.frame = bigFrame;
        keyButton.frame = CGRectMake(16, 133, 35, 35);
        [self addSubview:inputView];
        [keyOne becomeFirstResponder];
    } else {
        // This will search through subviews to find the current responder, and resign it.
        [self endEditing:YES];
    }
}

#pragma mark -
#pragma mark Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {

    if ([keyOne isFirstResponder]) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if (self.superview.frame.origin.y >= 0) {
            [self setViewMovedUp:YES byAmount:kbSize.width overDuration:animationDuration];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    if ([keyOne isFirstResponder] || [keyTwo isFirstResponder] || [keyThree isFirstResponder] || [keyFour isFirstResponder]) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if (self.superview.frame.origin.y < 0) {
            [self setViewMovedUp:NO byAmount:kbSize.width overDuration:animationDuration];
        }
    }
}

- (void)setViewMovedUp:(BOOL)movedUp byAmount:(CGFloat)height overDuration:(CGFloat)duration {
    CGRect rect = self.superview.frame;
    
    if (movedUp) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCWPinEntryActiveNotif object:self];
        editing = YES;
        keyButton.selected = YES;
        // Move the view's origin up so that the text field that will be hidden moves above the keyboard.
        // Increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= height;
        rect.size.height += height;
    } else {
        keyButton.selected = NO;
        // Revert back to the normal state.
        rect.origin.y += height;
        rect.size.height -= height;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.superview.frame = rect;
                         if (movedUp) {
                             inputView.alpha = 1;
                         } else {
                             inputView.alpha = 0;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (!movedUp) {
                             [self validateCode];
                             [self resetFields];
                             editing = NO;
                             [inputView removeFromSuperview];
                             self.frame = origFrame;
                             keyButton.frame = CGRectMake(0, 0, 35, 35);
                             [[NSNotificationCenter defaultCenter] postNotificationName:kCWPinEntryCompleteNotif object:self];
                         }
                     }];
}

#pragma mark -
#pragma mark Validation

- (void)validateCode {
    NSString *code = [NSString stringWithFormat:@"%@%@%@%@", keyOne.text, keyTwo.text, keyThree.text, keyFour.text];
    if ([pinNum isEqualToString:code]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCWPinEntryAuthorizedNotif object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCWPinEntryUnauthorizedNotif object:self];
    }
}

@end
