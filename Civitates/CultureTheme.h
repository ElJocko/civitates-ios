//
//  CultureTheme.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/29/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CultureTheme : NSObject

@property NSString *name;
@property NSString *display;
@property NSString *abbreviation;
@property UIColor *color;
@property NSInteger order;

+ (CultureTheme *)themeWithName:(NSString *)name;

@end
