//
//  CityDataTableViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 5/22/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import <UIKit/UIKit.h>

@class City;

@interface CityDataTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *wikipediaButton;

@property City *city;

@end
