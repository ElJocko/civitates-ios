//
//  CityAnnotationView.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/28/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CityAnnotation.h"

@interface CityAnnotationView : MKAnnotationView

+ (CityAnnotationView *)viewForAnnotation:(CityAnnotation *)annotation usingMapView:(MKMapView *)mapView;

- (id)initWithCityAnnotation:(CityAnnotation *)cityAnnotation;

@property CityAnnotation *cityAnnotation;

@end
