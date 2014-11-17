//
//  CityDataControllerViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/14/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City;

@interface CityDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataSelector;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameDescriptorLabel;
@property (weak, nonatomic) IBOutlet UIButton *wikipediaButton;

@property City *city;

@end
