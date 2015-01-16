//
//  HeatMapOverlay.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/7/15.
//  Copyright (c) 2015 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol HeatMapDelegate <NSObject>

@required
- (NSArray *)locationsToRenderInMapRect:(MKMapRect)mapRect;

@end

@interface HeatMapTileOverlay : MKTileOverlay

@property MKMapView *mapView;
@property NSArray *locations;

@property id <HeatMapDelegate> delegate;

//- (instancetype)initWithMapView:(MKMapView *)mapView;

@end
