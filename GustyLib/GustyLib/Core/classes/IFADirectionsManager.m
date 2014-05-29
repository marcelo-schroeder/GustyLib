//
// Created by Marcelo Schroeder on 7/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "IFADirectionsManager.h"


@implementation IFADirectionsManager {

}

#pragma mark - Public

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (void)directionsFrom:(MKMapItem *)a_fromMapItem
                     to:(MKMapItem *)a_toMapItem
requestsAlternateRoutes:(BOOL)a_shouldRequestAlternateRoutes
        completionBlock:(MKDirectionsHandler)a_completionBlock {

    MKDirectionsRequest *l_request = [[MKDirectionsRequest alloc] init];
    l_request.source = a_fromMapItem;
    l_request.destination = a_toMapItem;
    l_request.requestsAlternateRoutes = a_shouldRequestAlternateRoutes;

    MKDirections *l_directions = [[MKDirections alloc] initWithRequest:l_request];
    [l_directions calculateDirectionsWithCompletionHandler:a_completionBlock];

}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (void)etaFrom:(MKMapItem *)a_fromMapItem
                     to:(MKMapItem *)a_toMapItem
requestsAlternateRoutes:(BOOL)a_shouldRequestAlternateRoutes
        completionBlock:(MKETAHandler)a_completionBlock {

    MKDirectionsRequest *l_request = [[MKDirectionsRequest alloc] init];
    l_request.source = a_fromMapItem;
    l_request.destination = a_toMapItem;
    l_request.requestsAlternateRoutes = a_shouldRequestAlternateRoutes;

    MKDirections *l_directions = [[MKDirections alloc] initWithRequest:l_request];
    [l_directions calculateETAWithCompletionHandler:a_completionBlock];

}
#pragma clang diagnostic pop

+ (IFADirectionsManager *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFADirectionsManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

@end