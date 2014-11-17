//
//  CityPhysicalViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/14/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City;

@interface CityPhysicalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *elevationLabel;

@property City *city;

@end
