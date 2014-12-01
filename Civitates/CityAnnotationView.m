//
//  CityAnnotationView.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/28/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityAnnotationView.h"
#import "KSLabel.h"

@implementation CityAnnotationView

static double MARKER_DIAMETER_4 = 10.0;
static double MARKER_DIAMETER_3 = 11.0;
static double MARKER_DIAMETER_2 = 12.0;
static double MARKER_DIAMETER_1 = 13.0;
static double MARKER_DIAMETER_0 = 15.0;

static double LABEL_OFFSET = 2.0;

static double FONT_SIZE_4 = 14.0;
static double FONT_SIZE_3 = 15.0;
static double FONT_SIZE_2 = 16.0;
static double FONT_SIZE_1 = 17.0;
static double FONT_SIZE_0 = 18.0;

static double TOUCH_DIAMETER = 30.0;

+ (CityAnnotationView *)viewForAnnotation:(CityAnnotation *)annotation usingMapView:(MKMapView *)mapView {
    NSString *identifier = [NSString stringWithFormat:@"%ld", (long)annotation.category];
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    CityAnnotationView * cityAnnotationView = nil;
    if (annotationView) {
        cityAnnotationView = (CityAnnotationView *)annotationView;
    }
    else {
        cityAnnotationView = [[CityAnnotationView alloc] initWithCityAnnotation:annotation];
    }

    [cityAnnotationView setLabel];
    annotationView.alpha = 0.0;
    
    return cityAnnotationView;
}

- (id)initWithCityAnnotation:(CityAnnotation *)cityAnnotation
{
    self.cityAnnotation = cityAnnotation;
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    self = [super initWithFrame:frame];
    if (self) {
        double markerDiameter;
        double fontSize;
        
        if (cityAnnotation.category == 4) {
            markerDiameter = MARKER_DIAMETER_4;
            fontSize = FONT_SIZE_4;
        }
        else if (cityAnnotation.category == 3) {
            markerDiameter = MARKER_DIAMETER_3;
            fontSize = FONT_SIZE_3;
        }
        else if (cityAnnotation.category == 2) {
            markerDiameter = MARKER_DIAMETER_2;
            fontSize = FONT_SIZE_2;
        }
        else if (cityAnnotation.category == 1) {
            markerDiameter = MARKER_DIAMETER_1;
            fontSize = FONT_SIZE_1;
        }
        else {
            markerDiameter = MARKER_DIAMETER_0;
            fontSize = FONT_SIZE_0;
        }

        // Set up the graphics context
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(markerDiameter, markerDiameter), NO, 0.0f);
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TOUCH_DIAMETER, TOUCH_DIAMETER), NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        
        // Draw a transparent touch area
        CGRect touchRect = CGRectMake(0.0, 0.0, TOUCH_DIAMETER, TOUCH_DIAMETER);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillEllipseInRect(context, touchRect);
        
        // Draw the filled circle
        double fillOffset = (TOUCH_DIAMETER / 2.0) - (markerDiameter / 2.0);
        CGRect rectangle = CGRectMake(fillOffset, fillOffset, markerDiameter, markerDiameter);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, rectangle);
        
        // Draw the outline
        double outlineOffset = (TOUCH_DIAMETER / 2.0) - (markerDiameter / 2.0) + 1;
        CGRect outlineRect = CGRectMake(outlineOffset, outlineOffset, markerDiameter - 2.0, markerDiameter - 2.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextAddEllipseInRect(context, outlineRect);
        CGContextStrokePath(context);
        
        CGContextRestoreGState(context);
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return self;
}

- (void)setLabel {
    // Remove old label (if any)
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Calculate sizes
    double markerDiameter;
    double fontSize;
    
    if (self.cityAnnotation.category == 4) {
        markerDiameter = MARKER_DIAMETER_4;
        fontSize = FONT_SIZE_4;
    }
    else if (self.cityAnnotation.category == 3) {
        markerDiameter = MARKER_DIAMETER_3;
        fontSize = FONT_SIZE_3;
    }
    else if (self.cityAnnotation.category == 2) {
        markerDiameter = MARKER_DIAMETER_2;
        fontSize = FONT_SIZE_2;
    }
    else if (self.cityAnnotation.category == 1) {
        markerDiameter = MARKER_DIAMETER_1;
        fontSize = FONT_SIZE_1;
    }
    else {
        markerDiameter = MARKER_DIAMETER_0;
        fontSize = FONT_SIZE_0;
    }
    
    double markerLeft = TOUCH_DIAMETER / 2.0 - markerDiameter / 2.0;
    double markerRight = TOUCH_DIAMETER / 2.0 + markerDiameter / 2.0;
    double markerCenter = TOUCH_DIAMETER / 2.0;
    double markerTop = TOUCH_DIAMETER / 2.0 - markerDiameter / 2.0;
    double markerBottom = TOUCH_DIAMETER / 2.0 + markerDiameter / 2.0;

    // Draw the label
    UIColor *fontOutlineColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CGSize maxSixe = CGSizeMake(200.0, 40.0);
    
    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    CGRect labelRect = [self.cityAnnotation.label boundingRectWithSize:maxSixe options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:drawingContext];
    KSLabel *label;
    if (self.cityAnnotation.labelPosition == 0) {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerRight, markerTop - labelRect.size.height + LABEL_OFFSET, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    else if (self.cityAnnotation.labelPosition == 1) {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerRight, markerBottom - LABEL_OFFSET, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    else if (self.cityAnnotation.labelPosition == 2) {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerLeft - (labelRect.size.width + LABEL_OFFSET), markerTop - labelRect.size.height + LABEL_OFFSET, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    else if (self.cityAnnotation.labelPosition == 3) {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerLeft - (labelRect.size.width + LABEL_OFFSET), markerBottom - LABEL_OFFSET, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    else if (self.cityAnnotation.labelPosition == 4) {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerCenter - labelRect.size.width / 2.0, markerTop - labelRect.size.height, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    else {
        label = [[KSLabel alloc] initWithFrame:CGRectMake(markerCenter - labelRect.size.width / 2.0, markerBottom + LABEL_OFFSET, labelRect.size.width + LABEL_OFFSET, labelRect.size.height)];
    }
    label.text = self.cityAnnotation.label;
    label.font =[UIFont systemFontOfSize:fontSize];
    label.drawOutline = YES;
    label.outlineColor = fontOutlineColor;
    label.drawGradient = NO;
//    label.backgroundColor = [UIColor redColor];
    
    // Add the new label
    [self addSubview:label];

}

@end
