//
//  DynamicTileOverlay.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/8/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "DynamicTileOverlay.h"

@interface DynamicTileOverlay ()

@property UIImage *emptyTile;

@end

@implementation DynamicTileOverlay

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    if (path.z <= 5) {
        [super loadTileAtPath:path result:result];
    }
    else {
        if (self.emptyTile) {
            result(UIImagePNGRepresentation(self.emptyTile), nil);
        }
        else {
            CGSize tileSize =CGSizeMake(256, 256);
            UIGraphicsBeginImageContext(tileSize);
            [[UIColor greenColor] set];
            UIRectFill(CGRectMake(0, 0, tileSize.width, tileSize.height));
            self.emptyTile = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            result(UIImagePNGRepresentation(self.emptyTile), nil);
        }
    }
}

@end
