//
//  MapImageUtilities.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/13/15.
//  Copyright (c) 2015 Sheriff III, Jack B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapImageUtilities : NSObject

+ (UIImage *)maskFromImage:(UIImage *)image;
+ (UIImage*)applyMask:(UIImage *)mask toImage:(UIImage *)image;
+ (UIImage *)cropImage:(UIImage *)image withBoundingMapRect:(MKMapRect)boundingMapRect toMapRect:(MKMapRect)croppingMapRect;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize inRect:(CGRect)rect;

@end
