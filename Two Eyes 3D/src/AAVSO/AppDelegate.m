//
//  AppDelegate.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/15/12.
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

#import "AppDelegate.h"
#import "FatalViewController.h"
#import "LoadViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Initialize the Data Manager
    manager = [[DataManager alloc] init];
    manager.delegate = self;
    [manager startDataManager];
    
    [(UINavigationController *)self.window.rootViewController setDelegate:self];
    
    return YES;
}

- (void)dataManagerDidFinishInitializing:(DataManager *)aDataManager {
    // Get an instance of the main storyboard.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    // Initialize an instance of our first view controller.
    LoadViewController *loadVC = [storyboard instantiateViewControllerWithIdentifier:@"LoadViewController"];
    
    // Pass in the manager.
    loadVC.manager = manager;
    
    // Set the initial view controller.
    [(UINavigationController *)self.window.rootViewController pushViewController:loadVC animated:NO];
}

- (void)dataManager:(DataManager *)aDataManager didFailWithFatalError:(NSString*)aErrorStr {
    // Get an instance of the main storyboard.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FatalViewController *fatalVC = [storyboard instantiateViewControllerWithIdentifier:@"FatalViewController"];
    fatalVC.manager = manager;
    [(UINavigationController *)self.window.rootViewController pushViewController:fatalVC animated:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Application Error" message:aErrorStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    /*UIViewController *vc = [navigationController.viewControllers objectAtIndex:0];
    LogDebug(viewController.nibName);
    LogDebug(@"Controller Count: %d", [navigationController.viewControllers count]);
    if (vc != viewController) {
        LogD();
        [vc removeFromParentViewController];
        vc = nil;
    }*/
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
