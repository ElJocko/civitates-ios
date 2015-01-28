//
//  CultureTheme.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/29/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CultureTheme.h"

@implementation CultureTheme

static NSDictionary *themeDictionary;

+ (CultureTheme *)themeWithName:(NSString *)name {
    if (themeDictionary == nil) {
        [self loadDictionary];
    }
    
    return [themeDictionary objectForKey:name];
}

+ (void)loadDictionary {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CultureTheme" ofType:@"json" inDirectory:@"CityData"];
    if (!filePath) {
        themeDictionary = tempDict.copy;
        return;
    }
    
    NSError *parseError = nil;
    id themesObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:&parseError];
    if (!themesObject) {
        NSLog(@"Error parsing CultureTheme.json: %@", [parseError localizedDescription]);
        themeDictionary = tempDict.copy;
        return;
    }
    
    // Get the top level object
    NSArray* themeObjects = [themesObject objectForKey:@"themes"];
    
    NSInteger i = 0;
    for (id themeObject in themeObjects) {
        CultureTheme *theme = [[CultureTheme alloc] init];
        theme.name = [themeObject objectForKey:@"name"];
        theme.display = [themeObject objectForKey:@"display"];
        theme.abbreviation = [themeObject objectForKey:@"abbreviation"];
        theme.order = i;
        ++i;

        id color = [themeObject objectForKey:@"color"];
        NSInteger r = [[color objectForKey:@"r"] integerValue];
        NSInteger g = [[color objectForKey:@"g"] integerValue];
        NSInteger b = [[color objectForKey:@"b"] integerValue];
        NSInteger a = [[color objectForKey:@"a"] integerValue];
        
        theme.color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:(a/255.0)];
        
        [tempDict setObject:theme forKey:theme.name];
    }
    
    themeDictionary = tempDict.copy;
}

@end
