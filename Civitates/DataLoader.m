//
//  DataLoader.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/16/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "DataLoader.h"
#import "City.h"
#import "CityPeriod.h"
#import "AlternateName.h"
#import "CityAnnotation.h"

@implementation DataLoader

+ (NSArray *)readCityData {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"City" ofType:@"json" inDirectory:@"CityData"];
    if (!filePath) {
        return tempArray.copy;
    }
    
    NSError *parseError = nil;
    id citiesObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:kNilOptions error:&parseError];
    if (!citiesObject) {
        NSLog(@"Error parsing City.json: %@", [parseError localizedDescription]);
        return tempArray.copy;
    }
    
    //    NSLog(@"City data to load: %@", cities);
    
    // Get the top level object
    NSArray* cityObjects = [citiesObject objectForKey:@"cities"];
    
    for (id cityObject in cityObjects) {
        City *city = [[City alloc] init];
        city.identifier = [cityObject objectForKey:@"identifier"];
        double latitude = [[cityObject objectForKey:@"latitude"] doubleValue];
        double longitude = [[cityObject objectForKey:@"longitude"] doubleValue];
        city.location = CLLocationCoordinate2DMake(latitude, longitude);
        
        // Add the periods
        NSArray *periodObjects = [cityObject objectForKey:@"periods"];
        NSMutableArray *tempPeriodArray = [[NSMutableArray alloc] init];
        for (id periodObject in periodObjects) {
            CityPeriod *cityPeriod = [[CityPeriod alloc] init];
            cityPeriod.startDate = [[periodObject objectForKey:@"startDate"] integerValue];
            cityPeriod.endDate = [[periodObject objectForKey:@"endDate"] integerValue];
            cityPeriod.preferredName = [periodObject objectForKey:@"preferredName"];
            cityPeriod.category = [[periodObject objectForKey:@"size"] integerValue];
            cityPeriod.labelPosition = [[periodObject objectForKey:@"tagPosition"] integerValue];
            cityPeriod.annotation = [CityAnnotation cityAnnotationWithCity:city inPeriod:cityPeriod];
//            cityPeriod.annotation = [CityAnnotation cityAnnotationWithIdentifier:city.identifier label:cityPeriod.preferredName coordinate:city.location category:cityPeriod.category labelPosition:cityPeriod.labelPosition];
            [tempPeriodArray addObject:cityPeriod];
        }
        city.periods = tempPeriodArray.copy;
        
        // Add the alternate names
        NSArray *alternateNameObjects = [cityObject objectForKey:@"altNames"];
        NSMutableArray *tempAlternateNameArray = [[NSMutableArray alloc] init];
        for (id alternateNameObject in alternateNameObjects) {
            AlternateName *alternateName = [[AlternateName alloc] init];
            alternateName.name = [alternateNameObject objectForKey:@"name"];
            alternateName.culture = [alternateNameObject objectForKey:@"language"];
            [tempAlternateNameArray addObject:alternateName];
//            NSLog(@"alternate name: %@ for culture %@", alternateName.name, alternateName.culture);
        }
        city.alternateNames = tempAlternateNameArray.copy;

        // Save the city
        [tempArray addObject:city];
    }
    
    return tempArray.copy;
}

@end
