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
#import "CityDataTableViewController.h"
#import "FileCacheTileOverlay.h"

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

@property int displayYear;

@property double preChangeZoomLevel;
@property double preChangeZoomScale;
@property NSArray *cities;
@property NSArray *zoomThreshold;
@property UILabel *zoomLabel;
@property NSMutableSet *annotationsQueuedForRemoval;

@property NSString *preZeroEra;
@property NSString *postZeroEra;

@property UIPopoverController *cityDataPopoverController;

@end

@implementation ViewController

static double MAX_ZOOM_LEVEL = 10.0;
static BOOL USE_COMMON_ERA = NO;

- (void)viewDidLoad
{
    // Load the city data
    self.cities = [DataLoader readCityData];
    
    // Arbitrary year to start
    // TBD: Make this a user default so it sticks
    self.displayYear = 900;
    
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
    
    // Initialize slider
    [self.yearSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    // Set the zoom levels that trigger changes in the display
    self.zoomThreshold = [[NSArray alloc] initWithObjects:@0.0, @5.0, @6.0, @7.0, @8.0, nil];
    self.preChangeZoomLevel = 0.0;
    
    // Temporary label to display the current zoom level
    self.zoomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 200.0, 200.0)];
    self.zoomLabel.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:self.zoomLabel];
    
    // Initialize the map
    self.mapView.delegate = self;
    
    // Create a cached tile overlay with AWMC map tiles
    NSString *awmcUrlTemplate = @"http://c.tiles.mapbox.com/v3/isawnyu.map-knmctlkh/{z}/{x}/{y}.png";
    FileCacheTileOverlay *cachedTileOverlay = [[FileCacheTileOverlay alloc] initWithURLTemplate:awmcUrlTemplate];
    cachedTileOverlay.canReplaceMapContent = YES;
    cachedTileOverlay.geometryFlipped = NO;
    [self.mapView addOverlay:cachedTileOverlay];
    
    // Slew the map to the initial span
    MKCoordinateSpan span = MKCoordinateSpanMake(4.0, 4.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(41.9, 12.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:region animated:YES];
    
    // Initialize annotations structures
    self.annotationsQueuedForRemoval = [[NSMutableSet alloc] init];
    
    // Display cities according to their category
    [self initializeAnnotationDisplay];
}

- (IBAction)sliderDidChange:(id)sender
{
    // Get the selected value
    UISlider *slider = (UISlider *)sender;
    int value = slider.value;
    
    // Set the display year. There is no year 0, so make it year 1.
    if (value == 0) {
        self.displayYear = 1;
    }
    else {
        self.displayYear = value;
    }
    
    // Display the year.
    [self updateYearLabel];
    
    // Update the cities shown on the map
    [self refreshAnnotationDisplay];
}

- (void)updateYearLabel
{
    // Display the current year with the selected era designation
    if (self.displayYear < 0) {
        self.yearLabel.text = [NSString stringWithFormat:@"%d %@", (self.displayYear * -1), self.preZeroEra];
    }
    else {
        self.yearLabel.text = [NSString stringWithFormat:@"%d %@", self.displayYear, self.postZeroEra];
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
    self.preChangeZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    self.preChangeZoomLevel = 20.0 + log2(self.preChangeZoomScale);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKZoomScale postChangeZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    double postChangeZoomLevel = 20.0 + log2(postChangeZoomScale);

    self.zoomLabel.text = [NSString stringWithFormat:@"%f", postChangeZoomLevel];
    
    if (self.preChangeZoomLevel == postChangeZoomLevel) {
        return;
    }
    
    if (postChangeZoomLevel > MAX_ZOOM_LEVEL) {
        MKZoomScale resetZoomScale = pow(2.0, (MAX_ZOOM_LEVEL - 20));
        MKMapPoint mapCenterPoint = MKMapPointForCoordinate(mapView.region.center);
        double resetMapWidth = mapView.bounds.size.width / resetZoomScale;
        double resetMapHeight = mapView.bounds.size.height / resetZoomScale;
        MKMapPoint resetOrigin = MKMapPointMake(mapCenterPoint.x - (resetMapWidth / 2.0), mapCenterPoint.y - (resetMapHeight / 2.0));
        MKMapRect resetMapRect = MKMapRectMake(resetOrigin.x, resetOrigin.y, resetMapWidth, resetMapHeight);
        [mapView setVisibleMapRect:resetMapRect animated:YES];
        
        return;
    }

    [self refreshAnnotationDisplay];
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

    // Get the annotations that are currently on the map
    NSSet *preRefreshAnnotations = [NSSet setWithArray:self.mapView.annotations];
    NSSet *preRefreshOnscreenAnnotations = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    
    // Get the annotations that we want to have on the map
    NSArray *postRefreshAnnotations = [self annotationsForCurrentZoomAndRegion];
    NSSet *postRefreshOnscreenAnnotations = postRefreshAnnotations[0];
    NSSet *postRefreshOffscreenAnnotations = postRefreshAnnotations[1];
    
    // Determine which annotations need to be added or removed
    NSMutableSet *onscreenAnnotationsToAdd = [[NSMutableSet alloc] initWithSet:postRefreshOnscreenAnnotations];
    [onscreenAnnotationsToAdd minusSet:preRefreshOnscreenAnnotations];
    
    NSMutableSet *onscreenAnnotationsToRemove = [[NSMutableSet alloc] initWithSet:preRefreshOnscreenAnnotations];
    [onscreenAnnotationsToRemove minusSet:postRefreshOnscreenAnnotations];
    [onscreenAnnotationsToRemove minusSet:self.annotationsQueuedForRemoval];
    
    NSMutableSet *offscreenAnnotationsToAdd = [[NSMutableSet alloc] initWithSet:postRefreshOffscreenAnnotations];
    [offscreenAnnotationsToAdd minusSet:preRefreshAnnotations];
    
    NSMutableSet *offscreenAnnotationsToRemove = [[NSMutableSet alloc] initWithSet:preRefreshAnnotations];
    [offscreenAnnotationsToRemove minusSet:postRefreshOnscreenAnnotations];
    [offscreenAnnotationsToRemove minusSet:postRefreshOffscreenAnnotations];
    [offscreenAnnotationsToRemove minusSet:onscreenAnnotationsToRemove];
    [offscreenAnnotationsToRemove minusSet:self.annotationsQueuedForRemoval];

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
                             for (CityAnnotation *annotation in onscreenAnnotationsToRemove) {
                                 [self.mapView removeAnnotation:annotation];
                                 [self.annotationsQueuedForRemoval removeObject:annotation];
                             }
                         }];
    }
    
    // Add onscreen annotations
    for (CityAnnotation *annotation in onscreenAnnotationsToAdd) {
        [self.mapView addAnnotation:annotation];
    }
    
    // Add offscreen annotations
    for (CityAnnotation *annotation in offscreenAnnotationsToAdd) {
        [self.mapView addAnnotation:annotation];
    }

    // Remove offscreen annotations
    for (CityAnnotation *annotation in offscreenAnnotationsToRemove) {
        [self.mapView removeAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Selected city.");
    [self.mapView deselectAnnotation:view.annotation animated:NO];
    CityAnnotationView *cityAnnotationView = (CityAnnotationView *)view;
    CityDataTableViewController *contentViewController = [[UIStoryboard storyboardWithName:@"CityPopover" bundle:nil] instantiateViewControllerWithIdentifier:@"CityPopoverViewController"];
    contentViewController.modalPresentationStyle = UIModalPresentationPopover;
    contentViewController.preferredContentSize = CGSizeMake(300.0, 50.0 * 3.0 + 60.0 * 2.0);
    
    UIPopoverPresentationController *presentationController = contentViewController.popoverPresentationController;
    presentationController.sourceView = self.mapView;
    presentationController.sourceRect = view.frame;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:contentViewController animated:YES completion:nil];
    
//    CityDataTableViewController *contentViewController = [[CityDataTableViewController alloc] init];
    contentViewController.city = cityAnnotationView.cityAnnotation.city;
//    contentViewController.preferredContentSize = CGSizeMake(300.0, 50.0 * 3.0);
    
//    self.cityDataPopoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
//    self.cityDataPopoverController.delegate = self;
//    [self.cityDataPopoverController presentPopoverFromRect:(view.frame) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"Dismissed.");
}

/*
- (void)loadCities
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    // Initialize an NSSet for each category of city
//    MKCoordinateRegion worldBox = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0), MKCoordinateSpanMake(180.0, 360.0));
//    for (int i = 0; i < 4; ++i) {
//        TSQuadTree *cityQuadTree = [[TSQuadTree alloc] initWithBoundingBox:worldBox bucketSize:4];
//        [tempArray addObject:cityQuadTree];
//    }
    for (int i = 0; i < 4; ++i) {
        NSMutableArray *cityArray = [[NSMutableArray alloc] init];
        [tempArray addObject:cityArray];
    }
    
    //Category 0 cities
    CityAnnotation *city1 = [CityAnnotation cityWithIdentifier:@"Rome" label:@"Rome" coordinate:CLLocationCoordinate2DMake(41.9, 12.5) category:0];
    [tempArray[0] addObject:city1];

    // Category 1 cities
    CityAnnotation *city2 = [CityAnnotation cityWithIdentifier:@"Syracuse" label:@"Syracuse" coordinate:CLLocationCoordinate2DMake(37.08333, 15.28333) category:1];
    [tempArray[1] addObject:city2];

    // Category 2 cities
    CityAnnotation *city3 = [CityAnnotation cityWithIdentifier:@"Velzna" label:@"Velzna" coordinate:CLLocationCoordinate2DMake(42.71667, 12.1) category:2];
    CityAnnotation *city4 = [CityAnnotation cityWithIdentifier:@"Tarentum" label:@"Tarentum" coordinate:CLLocationCoordinate2DMake(40.46667, 17.23333) category:2];
    CityAnnotation *city5 = [CityAnnotation cityWithIdentifier:@"Naples" label:@"Neapolis" coordinate:CLLocationCoordinate2DMake(40.83333, 14.25) category:2];
    CityAnnotation *city6 = [CityAnnotation cityWithIdentifier:@"Milan" label:@"Mediolanum" coordinate:CLLocationCoordinate2DMake(45.46667, 9.18333) category:2];
    CityAnnotation *city7 = [CityAnnotation cityWithIdentifier:@"Cumae" label:@"Cumae" coordinate:CLLocationCoordinate2DMake(40.84861, 14.05361) category:2];
    CityAnnotation *city8 = [CityAnnotation cityWithIdentifier:@"Regium" label:@"Regium" coordinate:CLLocationCoordinate2DMake(38.11139, 15.66194) category:2];
    CityAnnotation *city9 = [CityAnnotation cityWithIdentifier:@"Velia" label:@"Velia" coordinate:CLLocationCoordinate2DMake(40.16083, 15.155) category:2];
    CityAnnotation *city10 = [CityAnnotation cityWithIdentifier:@"Alalia" label:@"Arretium" coordinate:CLLocationCoordinate2DMake(42.1036, 9.5128) category:2];
    CityAnnotation *city11 = [CityAnnotation cityWithIdentifier:@"Cerveteri" label:@"Caisra" coordinate:CLLocationCoordinate2DMake(42.0, 12.1) category:2];
    CityAnnotation *city12 = [CityAnnotation cityWithIdentifier:@"Terracina" label:@"Tarchna" coordinate:CLLocationCoordinate2DMake(41.2833, 13.25) category:2];
    CityAnnotation *city13 = [CityAnnotation cityWithIdentifier:@"Cortona" label:@"Curtun" coordinate:CLLocationCoordinate2DMake(43.2756, 11.9881) category:2];
    [tempArray[2] addObject:city3];
    [tempArray[2] addObject:city4];
    [tempArray[2] addObject:city5];
    [tempArray[2] addObject:city6];
    [tempArray[2] addObject:city7];
    [tempArray[2] addObject:city8];
    [tempArray[2] addObject:city9];
    [tempArray[2] addObject:city10];
    [tempArray[2] addObject:city11];
    [tempArray[2] addObject:city12];
    [tempArray[2] addObject:city13];

    // Category 3 cities
    CityAnnotation *city14 = [CityAnnotation cityWithIdentifier:@"Chiusi" label:@"Clevsin" coordinate:CLLocationCoordinate2DMake(43.01677, 11.95) category:3];
    CityAnnotation *city15 = [CityAnnotation cityWithIdentifier:@"Naxos" label:@"Naxos" coordinate:CLLocationCoordinate2DMake(37.83333, 15.28333) category:3];
    [tempArray[3] addObject:city14];
    [tempArray[3] addObject:city15];
    
    self.cities = tempArray.copy;
}
*/

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
