//
//  SearchTableViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 10/15/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "SearchTableViewController.h"
#import "AlternateName.h"
#import "CityNameTableViewCell2.h"
#import "CultureTheme.h"

@interface SearchTableViewController ()

@property NSArray *filteredCityNames;
@property UISearchController *searchController;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CityNameTableViewCell2" bundle:nil] forCellReuseIdentifier:@"cityNameCell"];
    
    // Initialize the search controller--use the existing table view for results
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    // Use the current view controller to update the search results
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    
    // Install the search bar as the table header
    [self.searchController.searchBar sizeToFit];
    [self.searchBarContainerView addSubview:self.searchController.searchBar];
    self.searchController.searchBar.placeholder = @"city name";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchController.searchBar.showsCancelButton = NO;
//    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // Set the presentation context.
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    // Initilize the search results with the entire array of cities
    self.filteredCityNames = [NSMutableArray arrayWithArray:self.cityNames];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1; // There's always a names section
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (!self.searchController.active)
    {
        if (index > 0)
        {
            // The index is offset by one to allow for the extra search icon inserted at the front
            // of the index
            
            return 0;
        }
        else
        {
            // The first entry in the index is for the search icon so we return section not found
            // and force the table to scroll to the top.
            
            CGRect searchBarFrame = self.searchController.searchBar.frame;
            [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
            return NSNotFound;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // Section 0 is always names
        return self.filteredCityNames.count;
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cityNameCell";
    CityNameTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        AlternateName *name = [self.filteredCityNames objectAtIndex:indexPath.item];
        
        CultureTheme *theme = [CultureTheme themeWithName:name.culture];
        cell.cultureImage.backgroundColor = theme.color;
        
        cell.cultureAbbreviationLabel.text = theme.abbreviation;
        
        cell.nameLabel.text = name.name;
        cell.cultureLabel.text = theme.display;
    }
    
    return cell;
}

-(void)filterContentForSearchText:(NSString*)searchText {
    // Update the filtered array based on the search text.

    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name BEGINSWITH[c] %@", searchText];
    self.filteredCityNames = [NSArray arrayWithArray:[self.cityNames filteredArrayUsingPredicate:predicate]];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    if (searchText.length > 0) {
        [self filterContentForSearchText:searchText];
    }
    else {
        // No search string, use the full array
        self.filteredCityNames = [NSMutableArray arrayWithArray:self.cityNames];
    }
    
    // We've updated the search results, reload the table
    [self.tableView reloadData];
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar resignFirstResponder];
//}

/*
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlternateName *name = [self.filteredCityNames objectAtIndex:indexPath.item];

    if (self.searchDelegate) {
        [self.searchDelegate didSelectAlternateName:name];
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
