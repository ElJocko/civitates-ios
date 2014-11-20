//
//  MapUtilities.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/19/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef CGFloat ZoomLevel;

@interface MapUtilities : NSObject

+ (MKZoomScale)zoomScaleForZoomLevel:(ZoomLevel)zoomLevel;
+ (ZoomLevel)zoomLevelForZoomScale:(MKZoomScale)zoomScale;

+ (MKZoomScale)zoomScaleOfMapView:(MKMapView *)mapView;

+ (MKMapRect)mapRectOfMapView:(MKMapView *)mapView withZoomScale:(MKZoomScale)zoomScale atCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate;
+ (MKCoordinateRegion)regionOfMapView:(MKMapView *)mapView withZoomScale:(MKZoomScale)zoomScale atCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate;

+ (BOOL)mapRegion:(MKCoordinateRegion)mapRegion1 equalsMapRegion:(MKCoordinateRegion)mapRegion2;

@end
