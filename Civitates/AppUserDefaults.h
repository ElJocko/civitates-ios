//
//  AppUserDefaults.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 10/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUserDefaults : NSObject

+ (void)setDisplayYear:(NSInteger)year;
+ (NSInteger)displayYear;

@end
