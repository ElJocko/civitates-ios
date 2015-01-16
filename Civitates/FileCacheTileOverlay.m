//
//  FileCacheTileOverlayRenderer.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 9/17/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "FileCacheTileOverlay.h"
#import "MapImageUtilities.h"

// This class performs the usual actions of the MKTileOverlay class, plus caches tiles in the /Library/caches directory.
// Note that there is no explicit management of the cache at this point. So tiles do not expire and no maximum size of the cache is set.
// The Apple documentaion on the cache directory isn't very specific, but it implies that the OS manages the cache directory and may delete files as needed.

// This class will also look in the bundle for tiles before looking in the caches directory.

@interface FileCacheTileOverlay()

//@property MKTileOverlay *overlay;
@property NSOperationQueue *operationQueue;

@end


@implementation FileCacheTileOverlay

- (void)storeTile:(NSData *)tile forPath:(MKTileOverlayPath)path {
    NSString *filePath = [self filePathForTileAtCachePath:path];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // Create the directory if it doesn't already exist
        NSString *directoryPath = [filePath stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // Create the file
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:tile attributes:nil];
    }
}

- (NSData *)retrieveTileFromBundleAtPath:(MKTileOverlayPath)path {
    NSString *filePath = [self filePathForTileAtBundlePath:path];
    NSData *data = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    }
    
    return data;
}

- (NSString *)filePathForTileAtBundlePath:(MKTileOverlayPath)path {
    NSString *tilePath = [NSString stringWithFormat:@"tiles/%ld/%ld/%ld", (long)path.z, (long)path.x, (long)path.y];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:tilePath ofType:@"png"];
    
    return filePath;
}



- (NSData *)retrieveTileFromCacheAtPath:(MKTileOverlayPath)path {
    NSString *filePath = [self filePathForTileAtCachePath:path];
    NSData *data = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    }
    
    return data;
}

- (NSString *)filePathForTileAtCachePath:(MKTileOverlayPath)path {
    NSString *tilePath = [NSString stringWithFormat:@"tiles/%ld/%ld/%ld.png", (long)path.z, (long)path.x, (long)path.y];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    
    NSString *filePath = [cachePath stringByAppendingPathComponent:tilePath];
    
    return filePath;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result
{
    NSData *tile = [self retrieveTileFromBundleAtPath:path];
    
    if (tile) {
//        NSLog(@"Tile in bundle (%ld/%ld/%ld)", (long)path.x, (long)path.y, (long)path.z);
        result(tile, nil);
    }
    else {
        tile = [self retrieveTileFromCacheAtPath:path];
        if (tile) {
//            NSLog(@"Tile in cache (%d/%d/%d)", path.x, path.y, path.z);
            result(tile, nil);
        }
        else {
//            NSLog(@"Tile not found in bundle or cache (%d/%d/%d)", path.x, path.y, path.z);
            if (!self.operationQueue) {
                self.operationQueue = [[NSOperationQueue alloc] init];
            }
            NSURL *tileURL = [self URLForTilePath:path];
            NSURLRequest *request = [NSURLRequest requestWithURL:tileURL];
            [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (!connectionError) {
                    UIImage *image = [UIImage imageWithData:data];
//                    image = [MapImageUtilities maskFromImage:image];
                    data = UIImagePNGRepresentation(image);
                    
                    [self storeTile:data forPath:path];
                }
                result(data, connectionError);
            }];
        }
    }
}

@end
