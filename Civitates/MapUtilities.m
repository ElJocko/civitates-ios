//
//  MapUtilities.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/19/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "MapUtilities.h"

@implementation MapUtilities

+ (MKZoomScale)zoomScaleForZoomLevel:(ZoomLevel)zoomLevel {
    return pow(2.0, (zoomLevel - 20.0));
}
+ (ZoomLevel)zoomLevelForZoomScale:(MKZoomScale)zoomScale {
    return 20.0 + log2(zoomScale);
}

+ (MKZoomScale)zoomScaleOfMapView:(MKMapView *)mapView {
    return mapView.bounds.size.width / mapView.visibleMapRect.size.width;
}

+ (MKMapRect)mapRectOfMapView:(MKMapView *)mapView withZoomScale:(MKZoomScale)zoomScale atCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    CGFloat mapWidth = mapView.bounds.size.width / zoomScale;
    CGFloat mapHeight = mapView.bounds.size.height / zoomScale;
    MKMapPoint centerPoint = MKMapPointForCoordinate(centerCoordinate);
    MKMapPoint origin = MKMapPointMake(centerPoint.x - (mapWidth / 2.0), centerPoint.y - (mapHeight / 2.0));
    MKMapRect mapRect = MKMapRectMake(origin.x, origin.y, mapWidth, mapHeight);

    return mapRect;
}

+ (MKCoordinateRegion)regionOfMapView:(MKMapView *)mapView withZoomScale:(MKZoomScale)zoomScale atCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    MKMapRect mapRect = [self mapRectOfMapView:mapView withZoomScale:zoomScale atCenterCoordinate:centerCoordinate];
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    return region;
}

+ (BOOL)mapRegion:(MKCoordinateRegion)mapRegion1 equalsMapRegion:(MKCoordinateRegion)mapRegion2 {
    CLLocationDegrees latitude1 = mapRegion1.center.latitude;
    CLLocationDegrees longitude1 = mapRegion1.center.longitude;
    CLLocationDegrees latitudeSpan1 = mapRegion1.span.latitudeDelta;
    CLLocationDegrees longitudeSpan1 = mapRegion1.span.longitudeDelta;
    
    CLLocationDegrees latitude2 = mapRegion2.center.latitude;
    CLLocationDegrees longitude2 = mapRegion2.center.longitude;
    CLLocationDegrees latitudeSpan2 = mapRegion2.span.latitudeDelta;
    CLLocationDegrees longitudeSpan2 = mapRegion2.span.longitudeDelta;
    
    return (latitude1 == latitude2 && longitude1 == longitude2 && latitudeSpan1 == latitudeSpan2 && longitudeSpan1 == longitudeSpan2);
}

+ (MKMapPoint)mapPointForTileAtPath:(MKTileOverlayPath)path {
    // Calculate the NW corner of the tile
    CGFloat n = pow(2.0, path.z);
    CGFloat longitude = ((path.x / n) * 360.0) - 180.0;
    CGFloat latRadians = atan(sinh(M_PI * (1 - 2 * path.y / n)));
    CGFloat latitude = (latRadians * 180.0) / M_PI;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    return mapPoint;
}

+ (MKMapRect)mapRectForTileAtPath:(MKTileOverlayPath)path {
    MKMapPoint nwCorner = [self mapPointForTileAtPath:path];
    
    MKTileOverlayPath seTilePath;
    seTilePath.x = path.x + 1;
    seTilePath.y = path.y + 1;
    seTilePath.z = path.z;
    seTilePath.contentScaleFactor = path.contentScaleFactor;
    MKMapPoint seCorner = [self mapPointForTileAtPath:seTilePath];
    
    MKMapRect mapRect = MKMapRectMake(nwCorner.x, nwCorner.y, seCorner.x - nwCorner.x, seCorner.y - nwCorner.y);
    return mapRect;
}


@end
