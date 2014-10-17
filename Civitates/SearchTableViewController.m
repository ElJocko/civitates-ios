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

@interface SearchTableViewController ()

@property NSDictionary *cultureSymbols;
@property NSMutableArray *filteredCityNames;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CityNameTableViewCell2" bundle:nil] forCellReuseIdentifier:@"cityNameCell"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CityNameTableViewCell2" bundle:nil] forCellReuseIdentifier:@"cityNameCell"];
    
    UIImage *latinImage = [UIImage imageNamed:@"Artwork/Latin.png"];
    UIImage *greekImage = [UIImage imageNamed:@"Artwork/Greek.png"];
    UIImage *italianImage = [UIImage imageNamed:@"Artwork/Italian.png"];
    UIImage *englishImage = [UIImage imageNamed:@"Artwork/English.png"];
    UIImage *etruscanImage = [UIImage imageNamed:@"Artwork/Etruscan.png"];
    
    self.cultureSymbols = [NSDictionary dictionaryWithObjectsAndKeys:latinImage, @"Latin", greekImage, @"Greek", italianImage, @"Italian", englishImage, @"English", etruscanImage, @"Etruscan", nil];
    
    self.filteredCityNames = [NSMutableArray arrayWithCapacity:self.cityNames.count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1; // There's always a names section
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        // Section 0 is always names
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return self.filteredCityNames.count;
        }
        else {
            return self.cityNames.count;
        }
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
        
        AlternateName *name;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            name = [self.filteredCityNames objectAtIndex:indexPath.item];
        }
        else {
            name = [self.cityNames objectAtIndex:indexPath.item];
        }
        
        cell.cultureImage.image = [self.cultureSymbols objectForKey:name.culture];
        
        cell.nameLabel.text = name.name;
        cell.cultureLabel.text = name.culture;
    }
    
    return cell;
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredCityNames removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name BEGINSWITH[c] %@", searchText];
    self.filteredCityNames = [NSMutableArray arrayWithArray:[self.cityNames filteredArrayUsingPredicate:predicate]];
}

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlternateName *name;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        name = [self.filteredCityNames objectAtIndex:indexPath.item];
    }
    else {
        name = [self.cityNames objectAtIndex:indexPath.item];
    }

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
