//
//  SessionUpload.m
//  Two Eyes 3D
//
//  Created by Jerry Belich on 7/13/12.
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

#import "SessionUpload.h"
#import "Base64.h"
#import "NSData+MD5.h"

@implementation SessionUpload
@synthesize delegate;

/*- (id <SessionUploadDelegate>)delegate {
    return delegate_;
}

- (void)setDelegate:(id <SessionUploadDelegate>)aDelegate {
    delegate_ = aDelegate;
}*/

- (void)uploadSessionAtPath:(NSString *)path withUuid:(NSString *)uuid {
    uuid_ = uuid;
    
    NSData *sessionData = [NSData dataWithContentsOfFile:path];  
    if (!sessionData) {
        LogError(@"Session data file contains no data: %@", path);
        return;
    }
    
    NSURL *uploadURL;
    if (kUseDebugRemote) {
        LogWarn(@"***Turn off kUseDebugRemote before production!***");
        uploadURL = [NSURL URLWithString:kDebugUploadUrl];
    } else {
        uploadURL = [NSURL URLWithString:kRemoteUploadUrl];
    }
    
    // Create a request.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setURL:uploadURL];
    
    // Set Content-Type in HTTP header.
    NSString *boundary = @"---------------------------7da24f2e50042";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // Create post body.
    NSMutableData *postBody = [NSMutableData data];
    
    // Add parameters.
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", kUploadChecksum] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", [sessionData MD5]] dataUsingEncoding:NSUTF8StringEncoding]];

    // Add data payload.
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", kUploadResult, [path lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:sessionData];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
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

/*- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    LogD();
}*/

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!result_) {
        result_ = [NSMutableData dataWithData:data];
    } else {
        [result_ appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self delegate] session:self withUuid:uuid_ didFailWithError:[NSString stringWithFormat:@"Session %@: Connection failed - %@", uuid_, [error localizedDescription]] andCode:kECUnknown];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (result_) {
        // Parse the JSON data.
        NSError *error;
        jsonData_ = [NSJSONSerialization JSONObjectWithData:result_
                                                    options:kNilOptions
                                                      error:&error];
        if (jsonData_) {
            if ([jsonData_ objectForKey:kServerStatusKey]) {
                if ([[jsonData_ objectForKey:kServerStatusKey] isEqualToString:kServerStatusSuccess]) {
                    [[self delegate] sessionDidFinishUpload:self withUuid:uuid_];
                    return;
                } else if ([[jsonData_ objectForKey:kServerStatusKey] isEqualToString:kServerStatusError]) {
                    NSNumber *codeNum = [jsonData_ objectForKey:kServerErrorCodeKey];
                    ServerErrorCode ec;
                    if (codeNum) {
                        ec = [codeNum intValue];
                    } else {
                        ec = kECUnknown;
                    }
                    [[self delegate] session:self withUuid:uuid_ didFailWithError:[NSString stringWithFormat:@"Session %@: Server error - %@", uuid_, [jsonData_ objectForKey:kServerErrorMsgKey]] andCode:ec];
                    return;
                }
            }
        } else {
            LogError(@"Failed to parse JSON response: %@", [error localizedDescription]);
            [[self delegate] session:self withUuid:uuid_ didFailWithError:@"Upload response received was not valid JSON data." andCode:kECUnknown];
            return;
        }
    }
    LogWarn(@"Valid response not received.");
    [[self delegate] session:self withUuid:uuid_ didFailWithError:[NSString stringWithFormat:@"Session %@: Valid response not received.", uuid_] andCode:kECUnknown];
}

@end
