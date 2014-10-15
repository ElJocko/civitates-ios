//
//  City.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/27/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityAnnotation.h"
#import "City.h"
#import "CityPeriod.h"

@interface CityAnnotation()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation CityAnnotation

+ (CityAnnotation *)cityAnnotationWithIdentifier:(NSString *)identifier label:(NSString *)label coordinate:(CLLocationCoordinate2D)coordinate category:(NSInteger)category labelPosition:(NSInteger)labelPosition
{
    CityAnnotation *cityAnnotation = [[CityAnnotation alloc] init];
    cityAnnotation.identifier = identifier;
    cityAnnotation.label = label;
    cityAnnotation.coordinate = coordinate;
    cityAnnotation.category = category;
    cityAnnotation.labelPosition = labelPosition;

    return cityAnnotation;
}

+ (CityAnnotation *)cityAnnotationWithCity:(City *)city inPeriod:(CityPeriod *)cityPeriod
{
    CityAnnotation *cityAnnotation = [[CityAnnotation alloc] init];
    cityAnnotation.identifier = city.identifier;
    cityAnnotation.label = cityPeriod.preferredName;
    cityAnnotation.coordinate = city.location;
    cityAnnotation.category = cityPeriod.category;
    cityAnnotation.labelPosition = cityPeriod.labelPosition;
    
    cityAnnotation.city = city;
    cityAnnotation.cityPeriod = cityPeriod;
    
    return cityAnnotation;
}


@end
