//
//  ViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 1/6/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "KSLabel.h"
#import "SearchPopoverDelegate.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate, UIPopoverControllerDelegate, SearchPopoverDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet KSLabel *yearLabel;
@property (weak, nonatomic) IBOutlet UISlider *yearSlider;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *mapAttributionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *splashImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
