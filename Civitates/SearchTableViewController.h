//
//  SearchTableViewController.h
//  Civitates
//
//  Created by Sheriff III, Jack B on 10/15/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "SearchPopoverDelegate.h"
#import <UIKit/UIKit.h>

@interface SearchTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *citySearchBar;
@property (weak) id <SearchPopoverDelegate> searchDelegate;

@property NSArray *cityNames;

@end
