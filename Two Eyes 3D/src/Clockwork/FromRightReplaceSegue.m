//
//  FromRightReplaceSegue.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 6/20/12.
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

#import "FromRightReplaceSegue.h"

@implementation FromRightReplaceSegue

- (void)perform {
    __block UIViewController *sourceVC = (UIViewController *)[self sourceViewController];
    __block UIViewController *destinationVC = (UIViewController *)[self destinationViewController];
    
    [sourceVC.view.superview addSubview:destinationVC.view];
    sourceVC.view.frame = CGRectMake(0, sourceVC.view.frame.origin.x, sourceVC.view.frame.size.width, sourceVC.view.frame.size.height);
    destinationVC.view.frame = CGRectMake(destinationVC.view.frame.size.width, destinationVC.view.frame.origin.y, destinationVC.view.frame.size.width, destinationVC.view.frame.size.height);
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         sourceVC.view.frame = CGRectMake(-sourceVC.view.frame.size.width, sourceVC.view.frame.origin.x, sourceVC.view.frame.size.width, sourceVC.view.frame.size.height);
                         destinationVC.view.frame = CGRectMake(0, destinationVC.view.frame.origin.y, destinationVC.view.frame.size.width, destinationVC.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [sourceVC.navigationController setViewControllers:[NSArray arrayWithObject:destinationVC] animated:NO];
                     }];
}

@end