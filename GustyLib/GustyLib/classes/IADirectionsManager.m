//
// Created by Marcelo Schroeder on 7/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IADirectionsManager.h"


@implementation IADirectionsManager {

}

#pragma mark - Public

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (void)m_directionsFrom:(MKMapItem *)a_fromMapItem
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
- (void)m_etaFrom:(MKMapItem *)a_fromMapItem
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

+ (IADirectionsManager*)m_instance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IADirectionsManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

@end