//
//  AlternateName.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;

@interface AlternateName : NSObject

@property NSString *name;
@property NSString *culture;
@property City *city;

@end
