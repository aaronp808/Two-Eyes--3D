//
//  CWRadioButtonOptions.m
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

#import "CWRadioButtonOptions.h"

@implementation CWRadioButtonOptions
@synthesize radioType;
@synthesize fontName;
@synthesize fontSize;
@synthesize textColor;
@synthesize radioPosition;
@synthesize itemLayout;
@synthesize radioDistance;
@synthesize itemBuffer;
@synthesize itemsUntilWrap;
@synthesize radioOrigin;
@synthesize itemMaxDimension;
@synthesize radioOnName;
@synthesize radioOffName;

- (id)init {
    
    if (self = [super init]) {
        // Initialization Code
        radioType = textType;
        fontName = @"HelveticaNeue";
        fontSize = 22;
        textColor = @"0x000000";
        radioPosition = positionLeft;
        itemLayout = layoutHorizontal;
        radioDistance = 20;
        itemBuffer = 20;
        itemsUntilWrap = 0;
        radioOrigin = CGPointMake(0, 0);
        itemMaxDimension = CGSizeMake(150, 150);
        radioOnName = @"";
        radioOffName = @"";
    }
    
    return self;
}

@end
