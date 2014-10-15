//
//  City.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CityPeriod.h"
#import "CityAnnotation.h"

@interface City : NSObject

- (CityAnnotation *)annotationForYear:(int)year;
- (CityPeriod *)periodForYear:(int)year;

@property NSString *identifier;
@property CLLocationCoordinate2D location;
@property NSArray *periods;
@property NSArray *alternateNames;
@property NSDictionary *physicalData;

@end
