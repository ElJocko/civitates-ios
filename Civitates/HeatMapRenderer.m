//
//  HeatMapRenderer.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/7/15.
//  Copyright (c) 2015 Sheriff III, Jack B. All rights reserved.
//

#import "HeatMapRenderer.h"
#import "SHGeoUtils.h"
#import "HeatMapTileOverlay.h"
#import <CoreLocation/CoreLocation.h>

@implementation HeatMapRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    /*
    HeatMapTileOverlay *overlay = self.overlay;
    MKMapRect theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:mapRect];
    
    NSArray *locations = [overlay.delegate locationsToRenderInMapRect:theMapRect];
    
    NSLog(@"will draw %d locations in MapRect %f %f %f %f", locations.count, theMapRect.origin.x, theMapRect.origin.y, theMapRect.size.width, theMapRect.size.height);
    
//    CGRect rect = [self rectForMapRect:theMapRect];
    
    NSMutableArray *points = [NSMutableArray array];
    for (CLLocation *location in locations) {
        MKMapRect visibleMapRect = [overlay.mapView visibleMapRect];
        CGPoint point = [overlay.mapView convertCoordinate:location.coordinate toPointToView:overlay.mapView];
        MKMapPoint mapPoint = MKMapPointForCoordinate(location.coordinate);
        CGPoint point = [self pointForMapPoint:mapPoint];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
//    UIImage *image = [SHGeoUtils heatMapForMapView:overlay.mapView boost:20.0 locations:locations weights:nil];
    UIImage *image = [SHGeoUtils heatMapWithRect:rect boost:20.0 points:points.copy weights:nil];
//    UIImage *image = [SHGeoUtils heatMapWithRect:theRect boost:0.75 points:pts weights:nil];
    CGImageRef imageReference = image.CGImage;
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -rect.size.height);
    
    CGContextDrawImage(context, rect, imageReference);
     */
}

@end
