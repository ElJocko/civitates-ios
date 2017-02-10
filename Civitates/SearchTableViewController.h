//
//  SearchTableViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 10/15/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "SearchPopoverDelegate.h"
#import <UIKit/UIKit.h>

@interface SearchTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UIView *searchBarContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak) id <SearchPopoverDelegate> searchDelegate;

@property NSArray *cityNames;

@end
