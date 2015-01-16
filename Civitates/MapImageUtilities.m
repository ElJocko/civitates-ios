//
//  MapImageUtilities.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/13/15.
//  Copyright (c) 2015 Sheriff III, Jack B. All rights reserved.
//

#import "MapImageUtilities.h"

@implementation MapImageUtilities

+ (UIImage *)maskFromImage:(UIImage *)image {
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    if (!context) {
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        NSLog(@"no context");

        return nil;
    }
    CGContextDrawImage(context, imageRect, [image CGImage]);

    // Reverse the colors
    unsigned char *buffer = CGBitmapContextGetData(context);
    if (buffer != NULL)
    {
        for (int i = 0; i < image.size.height * image.size.width; ++i) {
            if (buffer[i] < 100) {
                buffer[i] = 0;
            }
            else {
                buffer[i] = 255;
            }
        }
    }

    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

+ (UIImage*)applyMask:(UIImage *)mask toImage:(UIImage *)image
{
    CGImageRef maskImage = mask.CGImage;
    
    CGImageRef generatedMask = CGImageMaskCreate(
                                           CGImageGetWidth(maskImage),
                                           CGImageGetHeight(maskImage),
                                           CGImageGetBitsPerComponent(maskImage),
                                           CGImageGetBitsPerPixel(maskImage),
                                           CGImageGetBytesPerRow(maskImage),
                                           CGImageGetDataProvider(maskImage),
                                           NULL, // Decode is null
                                           NO // Should interpolate
                                           );
    
    NSLog(@"mask image %zu %zu %zu %zu %zu %zu", CGImageGetWidth(generatedMask),
          CGImageGetHeight(generatedMask),
          CGImageGetBitsPerComponent(generatedMask),
          CGImageGetBitsPerPixel(generatedMask),
          CGImageGetBytesPerRow(generatedMask),
          CGImageGetDataProvider(generatedMask));
    
    CGImageRef imageWithMaskApplied = CGImageCreateWithMask(image.CGImage, generatedMask);
    CGImageRelease(generatedMask);
    
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 CGImageGetWidth(imageWithMaskApplied),
                                                 CGImageGetHeight(imageWithMaskApplied),
                                                 CGImageGetBitsPerComponent(imageWithMaskApplied),
                                                 CGImageGetBytesPerRow(imageWithMaskApplied),
                                                 CGImageGetColorSpace(imageWithMaskApplied),
                                                 CGImageGetBitmapInfo(imageWithMaskApplied));
    
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(imageWithMaskApplied), CGImageGetHeight(imageWithMaskApplied));
    CGContextDrawImage(context, imageRect, imageWithMaskApplied);
    CGImageRef drawnImage = CGBitmapContextCreateImage(context);

    NSLog(@"drawn image %zu %zu %zu %zu %zu %zu", CGImageGetWidth(drawnImage),
          CGImageGetHeight(drawnImage),
          CGImageGetBitsPerComponent(drawnImage),
          CGImageGetBitsPerPixel(drawnImage),
          CGImageGetBytesPerRow(drawnImage),
          CGImageGetDataProvider(drawnImage));
    
    UIImage *maskedImage = [UIImage imageWithCGImage:drawnImage];
    
    CGImageRelease(imageWithMaskApplied);
    CFRelease(drawnImage);
    CGContextRelease(context);
    
    return maskedImage;
}

+ (UIImage *)cropImage:(UIImage *)image withBoundingMapRect:(MKMapRect)boundingMapRect toMapRect:(MKMapRect)croppingMapRect
{
    // Calculate the size and position of the crop rect
    CGFloat scale = image.size.width / boundingMapRect.size.width;
    CGFloat horizontalOffset = boundingMapRect.origin.x;
    CGFloat verticalOffset = boundingMapRect.origin.y;
    
    CGFloat x = (croppingMapRect.origin.x - horizontalOffset) * scale;
    CGFloat y = (croppingMapRect.origin.y - verticalOffset) * scale;
    CGFloat width = croppingMapRect.size.width * scale;
    CGFloat height = croppingMapRect.size.height * scale;
    
    CGRect cropRect = CGRectMake(x, y, width, height);
    CGImageRef cgImage = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:cgImage];
    
//    NSLog(@"image %f %f, bnd map rect %f %f, crop map rect %f %f", image.size.width, image.size.height, boundingMapRect.size.width, boundingMapRect.size.height, croppingMapRect.size.width, croppingMapRect.size.height);
    
    return croppedImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize inRect:(CGRect)rect
{
    //Determine whether the screen is retina
//    if ([[UIScreen mainScreen] scale] == 2.0) {
//        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
//    }
//    else
//    {
        UIGraphicsBeginImageContext(newSize);
//    }
    
    //Draw image in provided rect
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Pop this context
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
