//
// Created by Marcelo Schroeder on 7/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface IADirectionsManager : NSObject

- (void)m_directionsFrom:(MKMapItem *)a_fromMapItem to:(MKMapItem *)a_toMapItem
 requestsAlternateRoutes:(BOOL)a_shouldRequestAlternateRoutes
         completionBlock:(MKDirectionsHandler)a_completionBlock;

- (void)      m_etaFrom:(MKMapItem *)a_fromMapItem to:(MKMapItem *)a_toMapItem
requestsAlternateRoutes:(BOOL)a_shouldRequestAlternateRoutes completionBlock:(MKETAHandler)a_completionBlock;

+ (IADirectionsManager *)m_instance;
@end