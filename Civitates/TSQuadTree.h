//
//  TSQuadTree.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/3/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TSQuadTree : NSObject

- (instancetype)initWithBoundingBox:(MKCoordinateRegion)boundingBox bucketSize:(int)bucketSize;
- (void)addObject:(id)object atLocation:(CLLocationCoordinate2D)location;
- (NSSet *)objectsWithinRegion:(MKCoordinateRegion)region;

@end
