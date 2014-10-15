//
//  CityPeriod.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityAnnotation.h"

@interface CityPeriod : NSObject

@property NSInteger startDate;
@property NSInteger endDate;
@property NSString *preferredName;
@property NSInteger category;
@property NSInteger labelPosition;
@property CityAnnotation *annotation;

@end
