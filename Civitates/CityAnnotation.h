//
//  City.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/27/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class City;
@class CityPeriod;

@interface CityAnnotation : NSObject <MKAnnotation>

+ (CityAnnotation *)cityAnnotationWithIdentifier:(NSString *)identifier label:(NSString *)label coordinate:(CLLocationCoordinate2D)coordinate category:(NSInteger)category labelPosition:(NSInteger)labelPosition;
+ (CityAnnotation *)cityAnnotationWithCity:(City *)city inPeriod:(CityPeriod *)cityPeriod;

@property City *city;
@property CityPeriod *cityPeriod;

@property NSString *identifier;
@property NSString *label;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property NSInteger category;
@property NSInteger labelPosition;

@end
