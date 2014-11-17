//
//  CityPhysicalViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/14/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityPhysicalViewController.h"
#import "City.h"

@interface CityPhysicalViewController ()

@end

@implementation CityPhysicalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.city) {
        NSNumber *latitude = [self.city.physicalData valueForKey:@"latitude"];
        NSNumber *longitude = [self.city.physicalData valueForKey:@"longitude"];
        NSNumber *elevation = [self.city.physicalData valueForKey:@"elevation"];

        if (latitude) {
            self.latitudeLabel.text = [NSString stringWithFormat:@"%.6f", [latitude doubleValue]];
        }
        
        if (longitude) {
            self.longitudeLabel.text = [NSString stringWithFormat:@"%.6f", [longitude doubleValue]];
        }
        
        if (elevation) {
            self.elevationLabel.text = [NSString stringWithFormat:@"%ld meters", (long)[elevation integerValue]];
        }
        else {
            self.elevationLabel.text = @"";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
