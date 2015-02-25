//
//  City.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "City.h"
#import "CityPeriod.h"

@implementation City

- (CityAnnotation *)annotationForYear:(NSInteger)year
{
    for (CityPeriod *period in self.periods) {
        if (period.startDate <= year && year <= period.endDate) {
            return period.annotation;
        }
    }
    
    return nil;
}

- (CityPeriod *)periodForYear:(NSInteger)year
{
    for (CityPeriod *period in self.periods) {
        if (period.startDate <= year && year <= period.endDate) {
            return period;
        }
    }
    
    return nil;
}

@end
