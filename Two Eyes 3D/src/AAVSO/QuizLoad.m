//
//  QuizLoad.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/23/12.
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

#import "QuizLoad.h"
#import "Base64.h"

@implementation QuizLoad
@synthesize delegate = delegate_;

- (void)requestLatestQuiz:(NSString *)aCurrentVersion {
    NSURL *quizURL;
    if (kUseDebugRemote) {
        LogWarn(@"***Turn off kUseDebugRemote before production!***");
        quizURL = [NSURL URLWithString:kDebugQuizUrl];
    } else {
        quizURL = [NSURL URLWithString:kRemoteQuizUrl];
    }
    
    // Create a request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    [request setURL:quizURL];
    
    // Set Content-Type in HTTP header.
    NSString *boundary = @"---------------------------7da24f2e50042";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // Create post body.
    NSMutableData *postBody = [NSMutableData data];
    
    // Add parameters.
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", kRequestVersion] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", aCurrentVersion] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Close off the body.
    [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    // Set the Content-Length.
    NSString *postLength = [NSString stringWithFormat:@"%d", [postBody length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // Generate our Authorization Header. Skips need for credentials request and second response.
    NSData *authData = [[NSString stringWithFormat:@"%@:%@", kServerUsername, kServerPassword] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authHeaderData = [NSString stringWithFormat:@"Basic %@", [Base64 encode:authData]];
    [request setValue:authHeaderData forHTTPHeaderField:@"Authorization"];
    
    if ([NSURLConnection connectionWithRequest:request delegate:self]) {
        //LogDebug(@"Successfully initiated connection with upload server.");
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:kServerUsername
                                                   password:kServerPassword
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        LogWarn(@"Server credentials are incorrect.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSString *log = [NSString stringWithUTF8String:[data bytes]];
    //LogDebug(@"%@", log);
    
    if (!result_) {
        result_ = [NSMutableData dataWithData:data];
    } else {
        [result_ appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self delegate] quizLoad:self didFailWithError:[NSString stringWithFormat:@"Quiz request connection failed: %@", [error localizedDescription]]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (result_) {
        // Parse the JSON data.
        NSError *error;
        jsonData_ = [NSJSONSerialization JSONObjectWithData:result_
                                                  options:kNilOptions
                                                    error:&error];
        LogDebug(@"%@", jsonData_);
        if (jsonData_) {
            if ([jsonData_ objectForKey:kServerStatusKey]) {
                if ([[jsonData_ objectForKey:kServerStatusKey] isEqualToString:kServerStatusSuccess]) {
                    if ([[jsonData_ valueForKey:kQuizVersionKey] isKindOfClass:[NSString class]] == NO) {
                        [[self delegate] quizLoad:self didFailWithError:@"Bad version data received"];
                        return;
                    } else {
                        [[self delegate] quizLoadFinished:self withQuiz:jsonData_];
                        return;
                    }
                } else if ([[jsonData_ objectForKey:kServerStatusKey] isEqualToString:kServerStatusError]) {
                    [[self delegate] quizLoad:self didFailWithError:[NSString stringWithFormat:@"Quiz request server error: %@", [jsonData_ objectForKey:kServerErrorMsgKey]]];
                    return;
                }
            }
        } else {
            LogError(@"Failed to parse JSON response: %@", [error localizedDescription]);
            [[self delegate] quizLoad:self didFailWithError:@"Quiz received was not valid JSON data."];
            return;
        }
    }
    LogWarn(@"Valid response not received.");
    [[self delegate] quizLoad:self didFailWithError:@"Quiz request valid response not received."];
}

@end
