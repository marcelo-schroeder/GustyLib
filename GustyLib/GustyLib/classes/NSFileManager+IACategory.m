//
//  NSFileManager+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 22/02/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSFileManager+IACategory.h"

@implementation NSFileManager (IACategory)

#pragma mark - Public

- (void)m_removeItemAtURL:(NSURL *)a_url{
    if (a_url.isFileURL) {
        [self m_removeItemAtPath:a_url.path];
    }
}

- (void)m_removeItemAtPath:(NSString *)a_path{
    if (a_path && [self fileExistsAtPath:a_path]) {
        NSError *l_error = nil;
        if (![self removeItemAtPath:a_path error:&l_error]) {
            @throw l_error;
        }
    }
}

- (NSURL *)m_temporaryDirectoryUrl {
    return [[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()];
}

- (NSURL *)m_urlForTemporaryFileNamed:(NSString *)a_fileName{
    return [NSURL URLWithString:a_fileName relativeToURL:[self m_temporaryDirectoryUrl]];
}

@end
