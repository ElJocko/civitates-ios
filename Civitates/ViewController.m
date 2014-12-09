//
//  ViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/6/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "ViewController.h"
#import "DynamicTileOverlay.h"
#import "CityAnnotation.h"
#import "CityAnnotationView.h"
#import "TSQuadTree.h"
#import "DataLoader.h"
#import "City.h"
#import "CityPeriod.h"
#import "AlternateName.h"
#import "CityDataViewController.h"
#import "FileCacheTileOverlay.h"
#import "SearchTableViewController.h"
#import "AppUserDefaults.h"
#import "MapUtilities.h"
#import "UIImage+Sizing.h"

BOOL LocationInRegion2(CLLocationCoordinate2D location, MKCoordinateRegion region)
{
    // Note that this does not correctly handle regions that cross from +180 degrees longitude to -180 degrees longitude
    
    CLLocationDegrees maxLatitude = region.center.latitude  + (region.span.latitudeDelta  / 2.0);
    CLLocationDegrees minLatitude = region.center.latitude  - (region.span.latitudeDelta  / 2.0);
    CLLocationDegrees maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0);
    CLLocationDegrees minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
    
    if (location.latitude  <= maxLatitude && location.latitude  >= minLatitude && location.longitude <= maxLongitude && location.longitude >= minLongitude) {
        return YES;
    }
    else {
        return NO;
    }
}

@interface ViewController ()

@property NSInteger displayYear;
@property NSTimer *sliderTimer;
//@property NSTimeInterval lastChangeTime;
//@property NSInteger lastChangeValue;
//@property NSTimeInterval lastRefreshTime;
//@property BOOL slidingUp;

@property ZoomLevel preChangeZoomLevel;
@property MKZoomScale preChangeZoomScale;

@property NSArray *cities;

@property NSArray *zoomThreshold;
@property UILabel *zoomLabel;

@property NSMutableSet *annotationsQueuedForRemoval;

@property NSString *preZeroEra;
@property NSString *postZeroEra;

@property NSArray *allAlternateNames;

@property City *cityToSelectAfterRefresh;

@end

@implementation ViewController

static ZoomLevel MAX_ZOOM_LEVEL = 10.0;
static ZoomLevel SELECT_CITY_ZOOM_LEVEL = 8.1;
static BOOL USE_COMMON_ERA = NO;

static NSString *MAP_ATTRIBUTION = @"Map tiles courtesy of the Ancient World Mapping Center";

- (void)viewDidLoad
{
    // Load the appropriately sized splash image
    [self loadSplashImage];
    
    // Load the city data
    self.cities = [DataLoader readCityData];

    [self prepareAlternateNames];
    
    // Get the last year the user selected
    self.displayYear = [AppUserDefaults displayYear];
    self.yearSlider.value = self.displayYear;
    
    // Set the era designation
    if (USE_COMMON_ERA) {
        self.preZeroEra = @"BCE";
        self.postZeroEra = @"CE";
    }
    else {
        self.preZeroEra = @"BC";
        self.postZeroEra = @"AD";
    }
    
    // Set the label parameters to draw a white outline around the year
    self.yearLabel.drawOutline = YES;
    UIColor *fontOutlineColor = [UIColor whiteColor];
    self.yearLabel.outlineColor = fontOutlineColor;
    self.yearLabel.drawGradient = NO;

    // And show the current year
    [self updateYearLabel];
    
    // Initilizer the search button
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Artwork/antiqueSearch2" ofType:@"png"];
    UIImage *searchImage = [UIImage imageWithContentsOfFile:filePath];
    searchImage = [searchImage imageWithSize:CGSizeMake(52.0, 52.0)];
    [self.searchButton setBackgroundImage:searchImage forState:UIControlStateNormal];
//    NSLog(@"%f %f %f %f", searchImage.size.width, searchImage.size.height, self.searchButton.frame.size.width, self.searchButton.frame.size.height);
    
    // Initialize slider
    [self.yearSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.yearSlider addTarget:self action:@selector(sliderDidFinish:) forControlEvents:UIControlEventTouchUpInside];
    [self.yearSlider addTarget:self action:@selector(sliderDidFinish:) forControlEvents:UIControlEventTouchUpOutside];
//    self.lastChangeTime = 0.0;
    
    // Set the map attribution
    self.mapAttributionLabel.text = MAP_ATTRIBUTION;
    
    // Set the zoom levels that trigger changes in the display
    self.zoomThreshold = [[NSArray alloc] initWithObjects:@0.0, @5.0, @6.0, @7.0, @8.0, nil];
    self.preChangeZoomLevel = 0.0;
    
    // Temporary label to display the current zoom level
    self.zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 200.0, 200.0)];
    self.zoomLabel.font = [UIFont systemFontOfSize:14.0];
//    [self.view addSubview:self.zoomLabel];
    
    // Initialize the map
    self.mapView.delegate = self;
    
    // Create a cached tile overlay with AWMC map tiles
    NSString *awmcUrlTemplate = @"http://c.tiles.mapbox.com/v3/isawnyu.map-knmctlkh/{z}/{x}/{y}.png";
    FileCacheTileOverlay *cachedTileOverlay = [[FileCacheTileOverlay alloc] initWithURLTemplate:awmcUrlTemplate];
    cachedTileOverlay.canReplaceMapContent = YES;
    cachedTileOverlay.geometryFlipped = NO;
    [self.mapView addOverlay:cachedTileOverlay];
    
    // Slew the map to the initial span
    MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 10.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(41.9, 12.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    
    // Initialize annotations structures
    self.annotationsQueuedForRemoval = [[NSMutableSet alloc] init];
    
    // Display cities according to their category
    self.cityToSelectAfterRefresh = nil;
    [self initializeAnnotationDisplay];
    
    // Hide the splash image after giving time for the map to draw
    NSTimer *splashTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(hideSplashImage) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:splashTimer forMode:NSDefaultRunLoopMode];
}

- (void)hideControls {
    // This method hides all the controls. It is used to generate a launch screen image.
    self.yearLabel.hidden = YES;
    self.yearSlider.hidden = YES;
    self.searchButton.hidden = YES;
    self.zoomLabel.hidden = YES;
    self.mapAttributionLabel.hidden = YES;
}

- (void)loadSplashImage {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    // Pull the image from the image set.
    // (Inserting the image an image into the LaunchImage set modifies it from the original.
    // We need to get an equivilant image so that we match.)
    if (width > height) {
        self.splashImageView.image = [UIImage imageNamed:@"SplashImageLandscape"];
    }
    else {
        self.splashImageView.image = [UIImage imageNamed:@"SplashImagePortrait"];
    }
    
    if (self.splashImageView.image == nil) {
        self.splashImageView.backgroundColor = [UIColor grayColor];
    }
 
    /*
    if (width == 768 && height == 1024) {
        self.splashImageView.image = [UIImage imageNamed:@"Artwork/launch-768_1024_bw.png"];
    }
    else if (width == 1024 && height == 768) {
        self.splashImageView.image = [UIImage imageNamed:@"Artwork/launch-1024_768_bw.png"];
    }
    else if (width == 1536 && height == 2048) {
        self.splashImageView.image = [UIImage imageNamed:@"Artwork/launch-1536_2048_bw.png"];
    }
    else if (width == 2048 && height == 1536) {
        self.splashImageView.image = [UIImage imageNamed:@"Artwork/launch-2048_1536_bw.png"];
    }
    else {
        self.splashImageView.backgroundColor = [UIColor grayColor];
    }
     */
}

- (void)hideSplashImage {
    [self.activityIndicator stopAnimating];
    
    // Fade out the splash image
    [UIView animateWithDuration:1.0f
                     animations:^(void) {
        self.splashImageView.alpha = 0.0;
    }
                     completion:^(BOOL finished) {
        [self.splashImageView removeFromSuperview];
    }];
    
//    [self hideControls];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // Dismiss any popovers that are currently displayed
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)sliderDidChange:(id)sender
{
    // Get the selected value
    UISlider *slider = (UISlider *)sender;
    NSInteger value = slider.value;

//    BOOL nowSlidingUp = (value > self.lastChangeValue);
//
//    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
//    BOOL refresh = NO;
//    if (self.lastChangeTime != 0.0) {
//        CGFloat timeDiff = ABS(now - self.lastChangeTime) * 1000;
//        NSInteger valueDiff = ABS(value - self.lastChangeValue);
//        CGFloat rate = valueDiff / timeDiff;
//        CGFloat refreshDiff = ABS(now - self.lastRefreshTime) * 1000;
//        
//        if (refreshDiff > 200 && timeDiff < 20.0 && rate < 0.4 && nowSlidingUp == self.slidingUp) {
//            refresh = YES;
//            self.lastRefreshTime = now;
//            NSLog(@"Refresh");
//        }
//    }
//    self.lastChangeTime = now;
//    self.lastChangeValue = value;
//    self.slidingUp = nowSlidingUp;

//    NSInteger gap = self.displayYear - value;
//    NSLog(@"%ld (%ld)", (long)gap, (long)value);
    
    // Set the display year. There is no year 0, so make it year 1.
    if (value == 0) {
        self.displayYear = 1;
    }
    else {
        self.displayYear = value;
    }
    
    // Save the selection
    [AppUserDefaults setDisplayYear:self.displayYear];
    
    // Display the year.
    [self updateYearLabel];
    
    // Update the cities shown on the map
//    if (refresh) {
//        [self refreshAnnotationDisplay];
//    }
    [self startSliderTimer];
}

- (IBAction)sliderDidFinish:(id)sender
{
    [self stopSliderTimer];
    
    // Get the selected value
    UISlider *slider = (UISlider *)sender;
    NSInteger value = slider.value;
    
    // Set the display year. There is no year 0, so make it year 1.
    if (value == 0) {
        self.displayYear = 1;
    }
    else {
        self.displayYear = value;
    }
    
    // Save the selection
    [AppUserDefaults setDisplayYear:self.displayYear];
    
    // Display the year.
    [self updateYearLabel];
    
    // Update the cities shown on the map
    [self refreshAnnotationDisplay];
}

- (void)startSliderTimer {
    if (self.sliderTimer && self.sliderTimer.valid) {
        // Already started
//        NSLog(@"Slider timer restarted");
        [self.sliderTimer invalidate];
    }
    else {
//        NSLog(@"Slider Timer started");
    }
    self.sliderTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(sliderDidPause:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.sliderTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopSliderTimer {
//    NSLog(@"Slider Timer stopped");
    if (self.sliderTimer) {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }
}

- (void)sliderDidPause:(NSTimer *)timer {
    NSLog(@"Slider Timer fired");
    [self stopSliderTimer];
    [self refreshAnnotationDisplay];
}

- (IBAction)searchButtonTapped:(id)sender
{
    UIButton *button = sender;
    
    // Configure the content view
    SearchTableViewController *contentViewController = [[UIStoryboard storyboardWithName:@"SearchPopover" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchPopoverViewController"];
    contentViewController.modalPresentationStyle = UIModalPresentationPopover;
    contentViewController.preferredContentSize = CGSizeMake(300.0, 50.0 * 10.0 + 58.0);
    contentViewController.cityNames = self.allAlternateNames;
    contentViewController.searchDelegate = self;
    
    // Present the popover
    [self presentViewController:contentViewController animated:YES completion:nil];
    
    // And configure the popover
    UIPopoverPresentationController *presentationController = contentViewController.popoverPresentationController;
    presentationController.sourceView = self.view;
    presentationController.sourceRect = button.frame;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
}

- (void)didSelectAlternateName:(AlternateName *)alternateName {
    
    City *city = alternateName.city;
    self.cityToSelectAfterRefresh = city;
    
    // Is the city visible at the current year?
    // If not, pick the closest year where it is visible.
    bool shouldWarpYear = true;
    bool isWarpYearSet = false;
    NSInteger warpYear;
    
    for (CityPeriod *period in city.periods) {
        if (self.displayYear >= period.startDate && self.displayYear <= period.endDate) {
            shouldWarpYear = false;
            break;
        }
        else {
            NSInteger deltaStart = ABS(self.displayYear - period.startDate);
            NSInteger deltaEnd = ABS(self.displayYear - period.endDate);
            
            if (isWarpYearSet) {
                NSInteger deltaWarp = ABS(self.displayYear - warpYear);
                if (deltaStart < deltaWarp) {
                    warpYear = period.startDate;
                }
                
                if (deltaEnd < deltaWarp && deltaEnd < deltaStart) {
                    warpYear = period.endDate;
                }
            }
            else {
                if (deltaStart < deltaEnd) {
                    warpYear = period.startDate;
                }
                else {
                    warpYear = period.endDate;
                }
                isWarpYearSet = true;
            }
            
            // Can't have a year 0
            if (warpYear == 0) {
                warpYear = 1;
            }
        }
    }

    if (shouldWarpYear) {
        NSLog(@"Warp to year %ld", (long)warpYear);
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^ {
            // Warp to the year
            [UIView animateWithDuration:0.7
                             animations:^{
                                 // Animate the slider
                                 [self.yearSlider setValue:warpYear animated:YES];
                             }
                             completion:^(BOOL finished) {
                                 // Update the label
                                 self.displayYear = warpYear;
                                 [self updateYearLabel];
                                 
                                 // Slew the map to the city
                                 MKZoomScale resetZoomScale = [MapUtilities zoomScaleForZoomLevel:SELECT_CITY_ZOOM_LEVEL];
                                 MKMapRect mapRect = [MapUtilities mapRectOfMapView:self.mapView withZoomScale:resetZoomScale atCenterCoordinate:city.location];
                                 MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
                                 MKCoordinateRegion startingRegion = self.mapView.region;
                                 MKZoomScale startingZoomScale = [MapUtilities zoomScaleOfMapView:self.mapView];
                                 
                                 [MKMapView animateWithDuration:1.0f
                                                     animations:^{
                                                         [self.mapView setRegion:region animated:YES];
                                                     }
                                                     completion:^(BOOL finished) {
                                                         if ([MapUtilities mapRegion:self.mapView.region equalsMapRegion:startingRegion]) {
                                                             // The map didn't move. Force a refresh since we changed the year.
                                                             [self refreshAnnotationDisplay];
                                                             [self selectCityAfterRefresh];
                                                         }
                                                         else if ([MapUtilities zoomScaleOfMapView:self.mapView] == startingZoomScale) {
                                                             // The map moved but didn't zoom. Force a refresh, but don't select the city. That will happen
                                                             // in response to the map move.
                                                             [self refreshAnnotationDisplay];
                                                         }
                                                     }];
                             }];
        }];
    }
    else {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^ {
            // Slew the map to the city
            MKZoomScale resetZoomScale = [MapUtilities zoomScaleForZoomLevel:SELECT_CITY_ZOOM_LEVEL];
            MKMapRect mapRect = [MapUtilities mapRectOfMapView:self.mapView withZoomScale:resetZoomScale atCenterCoordinate:city.location];
            MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
            MKCoordinateRegion startingRegion = self.mapView.region;
            
            [MKMapView animateWithDuration:1.0f
                                animations:^{
                                    [self.mapView setRegion:region animated:YES];
                                }
                                completion:^(BOOL finished) {
                                    if ([MapUtilities mapRegion:self.mapView.region equalsMapRegion:startingRegion]) {
                                        // The map didn't move. Just select the city.
                                        [self selectCityAfterRefresh];
                                    }
                                }];
        }];
    }
}

- (void)updateYearLabel
{
    // Display the current year with the selected era designation
    if (self.displayYear < 0) {
        self.yearLabel.text = [NSString stringWithFormat:@"%d %@", (self.displayYear * -1), self.preZeroEra];
    }
    else {
        self.yearLabel.text = [NSString stringWithFormat:@"%ld %@", (long)self.displayYear, self.postZeroEra];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithOverlay:overlay];
        return renderer;
    }
    else {
        return nil;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    CityAnnotationView *annotationView = [CityAnnotationView viewForAnnotation:annotation usingMapView:mapView];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *annotationView in views) {
        annotationView.alpha = 0.0;
    }
    [UIView animateWithDuration:0.7f
                    animations:^(void) {
                        for (UIView *annotationView in views) {
                            annotationView.alpha = 1.0;
                        }
                    }];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.preChangeZoomScale = [MapUtilities zoomScaleOfMapView:mapView];
    self.preChangeZoomLevel = [MapUtilities zoomLevelForZoomScale:self.preChangeZoomScale];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKZoomScale postChangeZoomScale = [MapUtilities zoomScaleOfMapView:mapView];
    ZoomLevel postChangeZoomLevel = [MapUtilities zoomLevelForZoomScale:postChangeZoomScale];
    CGFloat latSpan = mapView.region.span.latitudeDelta;
    CGFloat longSpan = mapView.region.span.longitudeDelta;

    self.zoomLabel.text = [NSString stringWithFormat:@"%f (%f/%f)", postChangeZoomLevel, latSpan, longSpan];
    
    if (self.preChangeZoomLevel == postChangeZoomLevel) {
        [self selectCityAfterRefresh];
        return;
    }
    
    // Limit how far the user can zoom in
    if (postChangeZoomLevel > MAX_ZOOM_LEVEL) {
        MKZoomScale resetZoomScale = [MapUtilities zoomScaleForZoomLevel:MAX_ZOOM_LEVEL];
        MKMapRect resetMapRect = [MapUtilities mapRectOfMapView:mapView withZoomScale:resetZoomScale atCenterCoordinate:mapView.region.center];
        [mapView setVisibleMapRect:resetMapRect animated:YES];
        
        return;
    }

    [self refreshAnnotationDisplay];
    [self selectCityAfterRefresh];
}

- (void)initializeAnnotationDisplay
{
    NSArray *annotations = [self annotationsForCurrentZoomAndRegion];
    NSSet *onscreenAnnotations = annotations[0];
    NSSet *offscreenAnnotations = annotations[1];
    
    for (CityAnnotation *annotation in onscreenAnnotations) {
        [self.mapView addAnnotation:annotation];
    }
    
    for (CityAnnotation *annotation in offscreenAnnotations) {
        [self.mapView addAnnotation:annotation];
    }
}

- (void)refreshAnnotationDisplay
{
    // Note use of the annotationsQueuedForRemoval set. This holds annotations that are being "faded out" but that
    // have not been actually removed from the map view yet. We don't want to try to remove these annotations again
    // while they're being faded out.
    
//    NSLog(@"** 01 ** %d", self.displayYear);

    // Get the annotations that are currently on the map
    NSSet *preRefreshAnnotations = [NSSet setWithArray:self.mapView.annotations];
    NSSet *preRefreshOnscreenAnnotations = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    
//    NSLog(@"** 02 ** %d", self.displayYear);
    
    // Get the annotations that we want to have on the map
    NSArray *postRefreshAnnotations = [self annotationsForCurrentZoomAndRegion];
    NSSet *postRefreshOnscreenAnnotations = postRefreshAnnotations[0];
    NSSet *postRefreshOffscreenAnnotations = postRefreshAnnotations[1];
    
//    NSLog(@"** 03 ** %d", self.displayYear);
    
    // Determine which annotations need to be added or removed
    NSMutableSet *onscreenAnnotationsToAdd = [[NSMutableSet alloc] initWithSet:postRefreshOnscreenAnnotations];
    [onscreenAnnotationsToAdd minusSet:preRefreshOnscreenAnnotations];
    
//    NSLog(@"** 04 ** %d", self.displayYear);
    
    NSMutableSet *onscreenAnnotationsToRemove = [[NSMutableSet alloc] initWithSet:preRefreshOnscreenAnnotations];
    [onscreenAnnotationsToRemove minusSet:postRefreshOnscreenAnnotations];
    [onscreenAnnotationsToRemove minusSet:self.annotationsQueuedForRemoval];
    
//    NSLog(@"** 05 ** %d", self.displayYear);
    
    NSMutableSet *offscreenAnnotationsToAdd = [[NSMutableSet alloc] initWithSet:postRefreshOffscreenAnnotations];
    [offscreenAnnotationsToAdd minusSet:preRefreshAnnotations];
    
//    NSLog(@"** 06 ** %d", self.displayYear);
    
    NSMutableSet *offscreenAnnotationsToRemove = [[NSMutableSet alloc] initWithSet:preRefreshAnnotations];
    [offscreenAnnotationsToRemove minusSet:postRefreshOnscreenAnnotations];
    [offscreenAnnotationsToRemove minusSet:postRefreshOffscreenAnnotations];
    [offscreenAnnotationsToRemove minusSet:onscreenAnnotationsToRemove];
    [offscreenAnnotationsToRemove minusSet:self.annotationsQueuedForRemoval];

//    NSLog(@"** 07 ** %d", self.displayYear);
    
//    NSLog(@"%d %d %d %d", onscreenAnnotationsToAdd.count, offscreenAnnotationsToAdd.count, onscreenAnnotationsToRemove.count, offscreenAnnotationsToRemove.count);
    
    // Remove onscreen annotations
    // This is a two step process:
    // 1. Fade the annotations out (animate to transparent)
    // 2. Remove them from the map view
    if (onscreenAnnotationsToRemove.count > 0) {
        [UIView animateWithDuration:0.7f
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void) {
                             for (CityAnnotation *annotation in onscreenAnnotationsToRemove) {
                                 UIView *viewForAnnotation = [self.mapView viewForAnnotation:annotation];
                                 if (viewForAnnotation) {
                                     viewForAnnotation.alpha = 0.0;
                                 }
                                 [self.annotationsQueuedForRemoval addObject:annotation];
                             }
                         }
                         completion:^(BOOL finished) {
                             [self.mapView removeAnnotations:[onscreenAnnotationsToRemove allObjects]];
                             for (CityAnnotation *annotation in onscreenAnnotationsToRemove) {
//                                 [self.mapView removeAnnotation:annotation];
                                 [self.annotationsQueuedForRemoval removeObject:annotation];
                             }
                         }];
    }
    
    // Add onscreen annotations
//    for (CityAnnotation *annotation in onscreenAnnotationsToAdd) {
//        [self.mapView addAnnotation:annotation];
//    }
//    NSLog(@"** 08 ** %d", self.displayYear);
    
    [self.mapView addAnnotations:[onscreenAnnotationsToAdd allObjects]];
    
    // Add offscreen annotations
//    for (CityAnnotation *annotation in offscreenAnnotationsToAdd) {
//        [self.mapView addAnnotation:annotation];
//    }
//    NSLog(@"** 09 ** %d", self.displayYear);
    
    [self.mapView addAnnotations:[offscreenAnnotationsToAdd allObjects]];
    
    // Remove offscreen annotations
//    for (CityAnnotation *annotation in offscreenAnnotationsToRemove) {
//        [self.mapView removeAnnotation:annotation];
//    }
//    NSLog(@"** 10 ** %d", self.displayYear);
    
    [self.mapView removeAnnotations:[offscreenAnnotationsToRemove allObjects]];

//    NSLog(@"remove %d", offscreenAnnotationsToRemove.count);
//    NSLog(@"** 11 ** %d", self.displayYear);
    
}

- (void)selectCityAfterRefresh {
    if (self.cityToSelectAfterRefresh) {
        CityAnnotation *annotationToSelect = nil;
        for (CityAnnotation *cityAnnotation in self.mapView.annotations) {
            if (cityAnnotation.city == self.cityToSelectAfterRefresh) {
                annotationToSelect = cityAnnotation;
                break;
            }
        }
        [self.mapView selectAnnotation:annotationToSelect animated:YES];
        self.cityToSelectAfterRefresh = nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // Configure the content view
    [self.mapView deselectAnnotation:view.annotation animated:NO];
    CityAnnotationView *cityAnnotationView = (CityAnnotationView *)view;
    CityDataViewController *contentViewController = [[UIStoryboard storyboardWithName:@"CityPopover" bundle:nil] instantiateViewControllerWithIdentifier:@"CityPopoverViewController"];
    contentViewController.modalPresentationStyle = UIModalPresentationPopover;
    contentViewController.preferredContentSize = CGSizeMake(300.0, 50.0 * 3.0 + 54.0 * 3.0);
    contentViewController.city = cityAnnotationView.cityAnnotation.city;
    
    // Present the popover
    [self presentViewController:contentViewController animated:YES completion:nil];
    
    // And configure the popover
    UIPopoverPresentationController *presentationController = contentViewController.popoverPresentationController;
    presentationController.sourceView = self.mapView;
    presentationController.sourceRect = view.frame;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
}

- (NSArray *)annotationsForCurrentZoomAndRegion {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    MKZoomScale zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
    double zoomLevel = 20.0 + log2(zoomScale);
    
    MKCoordinateRegion visibleRegion = self.mapView.region;
    
    NSMutableSet *onscreenAnnotations = [[NSMutableSet alloc] init];
    NSMutableSet *offscreenAnnotations = [[NSMutableSet alloc] init];
    
    // See if we're over the threshold
    for (int i = 0; i < 5; ++i) {
        if (zoomLevel >= [[self.zoomThreshold objectAtIndex:i] doubleValue]) {
//            NSLog(@"Over threshold for category %d", i);
            for (City *city in self.cities) {
                CityPeriod *cityPeriod = [city periodForYear:self.displayYear];
                if (cityPeriod != nil && cityPeriod.category == i) {
                    if (LocationInRegion2(city.location, visibleRegion)) {
                        [onscreenAnnotations addObject:cityPeriod.annotation];
                    }
                    else {
                        [offscreenAnnotations addObject:cityPeriod.annotation];
                    }
                }
            }
        }
    }
 
    [tempArray addObject:onscreenAnnotations.copy];
    [tempArray addObject:offscreenAnnotations.copy];
    
    return tempArray.copy;
}

- (void)prepareAlternateNames {
    // Get the alternate name objects
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (City *city in self.cities) {
        for (AlternateName *name in city.alternateNames) {
            [tempArray addObject:name];
        }
    }
    
    // Sort them by name
    self.allAlternateNames = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AlternateName *name1 = obj1;
        AlternateName *name2 = obj2;
        
        return [name1.name caseInsensitiveCompare:name2.name];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
