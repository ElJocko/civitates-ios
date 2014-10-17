//
//  AppUserDefaults.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 10/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "AppUserDefaults.h"

@implementation AppUserDefaults

NSString *DISPLAY_YEAR = @"displayYear";
NSInteger initialYear = 900;

+ (void)setDisplayYear:(NSInteger)year {
    [[NSUserDefaults standardUserDefaults] setInteger:year forKey:DISPLAY_YEAR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)displayYear {
    NSInteger year = [[NSUserDefaults standardUserDefaults] integerForKey:DISPLAY_YEAR];
    if (year == 0) {
        return initialYear;
    }
    else {
        return year;
    }
}

@end
