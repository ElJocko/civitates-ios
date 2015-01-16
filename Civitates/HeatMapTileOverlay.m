//
//  HeatMapOverlay.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/7/15.
//  Copyright (c) 2015 Sheriff III, Jack B. All rights reserved.
//

#import "HeatMapTileOverlay.h"
#import "PointThemeRenderer.h"
#import "MapUtilities.h"
#import "MapImageUtilities.h"

@implementation HeatMapTileOverlay

- (NSData *)generateTileAtPath:(MKTileOverlayPath)path {
    NSData *data = nil;
    
    NSInteger tileWidth = self.tileSize.width;
    NSInteger tileHeight = self.tileSize.height;
    
    // Get the mapRect for this tile
    MKMapRect mapRect = [MapUtilities mapRectForTileAtPath:path];
    
//    CLLocationCoordinate2D romeLocation = CLLocationCoordinate2DMake(41.9, 12.5);
//    MKMapPoint romeMapPoint = MKMapPointForCoordinate(romeLocation);
//    CGFloat x = ((romeMapPoint.x - mapRect.origin.x) / mapRect.size.width) * tileWidth;
//    CGFloat y = ((romeMapPoint.y - mapRect.origin.y) / mapRect.size.height) * tileHeight;
//    CGPoint romePoint = CGPointMake(x, y);
    
    CGRect imageRect = CGRectMake(0.0, 0.0, tileWidth, tileHeight);

    NSMutableArray *points = [NSMutableArray array];
    for (NSValue *value in self.locations) {
        CLLocationCoordinate2D coordinate;
        [value getValue:&coordinate];
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
        CGFloat x = ((mapPoint.x - mapRect.origin.x) / mapRect.size.width) * tileWidth;
        CGFloat y = ((mapPoint.y - mapRect.origin.y) / mapRect.size.height) * tileHeight;
        CGPoint point = CGPointMake(x, y);
        
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    
    // Mask the theme image--remove from areas over open water
    UIImage *worldMask = [UIImage imageNamed:@"OpenWaterMask.png"];
    UIImage *croppedWorldMask = [MapImageUtilities cropImage:worldMask withBoundingMapRect:MKMapRectWorld toMapRect:mapRect];
    
    UIImage *sizedMaskImage = [MapImageUtilities imageWithImage:croppedWorldMask scaledToSize:imageRect.size inRect:imageRect];
    
    UIImage *mask = [MapImageUtilities maskFromImage:sizedMaskImage];
    
//    UIImage *maskedImage = [MapImageUtilities applyMask:testImage toImage:image];

    // Create the theme image
    CGFloat zoomScale = [MapUtilities zoomScaleForZoomLevel:path.z];
    CGFloat boost = zoomScale * 30000.0;
    UIImage *image = [PointThemeRenderer themeMapWithRect:imageRect boost:boost points:points weights:nil weightsAdjustmentEnabled:NO groupingEnabled:NO mask:mask];
    
//    NSLog(@"image %f %f, worldMask %f %f, mask %f %f, maskedImage %f %f", image.size.width, image.size.height, worldMask.size.width, worldMask.size.height, mask.size.width, mask.size.height, maskedImage.size.width, maskedImage.size.height);
    
//    if (croppedWorldMask) {
//        data = UIImagePNGRepresentation(croppedWorldMask);
//    }

//    if (testImage) {
//        data = UIImagePNGRepresentation(testImage);
//        UIImage *pngImage = [UIImage imageWithData:data];
//        NSLog(@"pngImage %f %f", pngImage.size.width, pngImage.size.height);
//    }
    
    if (image) {
        data = UIImagePNGRepresentation(image);
    }
    
    return data;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result
{
    NSData *tile = [self generateTileAtPath:path];
    
    result(tile, nil);
}

@end
