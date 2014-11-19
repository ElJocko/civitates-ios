//
//  CityDataTableViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 5/22/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityNameTableViewController.h"
#import "City.h"
#import "AlternateName.h"
#import "CityNameTableViewCell2.h"

@interface CityNameTableViewController ()

@property NSDictionary *cultureSymbols;
@property NSArray *consolidatedNames;

@end

@implementation CityNameTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"CityNameTableViewCell2" bundle:nil] forCellReuseIdentifier:@"cityNameCell"];

    UIImage *latinImage = [UIImage imageNamed:@"Artwork/Latin.png"];
    UIImage *greekImage = [UIImage imageNamed:@"Artwork/Greek.png"];
    UIImage *italianImage = [UIImage imageNamed:@"Artwork/Italian.png"];
    UIImage *englishImage = [UIImage imageNamed:@"Artwork/English.png"];
    UIImage *etruscanImage = [UIImage imageNamed:@"Artwork/Etruscan.png"];
    
    self.cultureSymbols = [NSDictionary dictionaryWithObjectsAndKeys:latinImage, @"Latin", greekImage, @"Greek", italianImage, @"Italian", englishImage, @"English", etruscanImage, @"Etruscan", nil];
    
    self.consolidatedNames = [[NSArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *cultureOrder = @{
                                   @"Umbrian": @1,
                                   @"Etruscan": @2,
                                   @"Gallic": @3,
                                   @"Greek": @4,
                                   @"Latin": @5,
                                   @"Italian": @6,
                                   @"English": @7
                                   };
    
    if (self.city) {
        // Each city has one or more names associated with it. These names are provided to this viewController
        // as an array of alternateName objects, where each object has a name and a culture (e.g., "Fefluna"/"Etruscan").
        // To prepare these names for display, they're reorganized as follows:
        // 1. Consolidate all names for the same culture. So the objects "Vulci"/"Latin" and "Volci"/"Latin" are
        // converted to one object "Vulci, Volci"/"Latin".
        // 2. Sort the consolidated names by culture. The sorting is done using a very rough time peridization, not
        // alphabetically.
        // The product is an array that is used to fill the table view.
        
        // Consolidate the names
        //   tempDictionary holds the list of consolidated names as we build it
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
        for (AlternateName *alternateName in self.city.alternateNames) {
            NSString *nameList = [tempDictionary objectForKey:alternateName.culture];
            NSString *updatedNameList = nil;
            if (nameList) {
                updatedNameList = [nameList stringByAppendingFormat:@", %@", alternateName.name];
            }
            else {
                updatedNameList = alternateName.name;
            }
            [tempDictionary setObject:updatedNameList forKey:alternateName.culture];
        }
        
        // Convert to an array of alternateName objects
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSString *culture in [tempDictionary allKeys]) {
            AlternateName *alternateName = [[AlternateName alloc] init];
            alternateName.culture = culture;
            alternateName.name = [tempDictionary objectForKey:culture];
            [tempArray addObject:alternateName];
        }
        
        // Sort by culture time period
        self.consolidatedNames = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            AlternateName *name1 = obj1;
            AlternateName *name2 = obj2;
            
            NSNumber *name1Order = [cultureOrder objectForKey:name1.culture];
            NSNumber *name2Order = [cultureOrder objectForKey:name2.culture];
            
            if (name1Order && name2Order) {
                return [name1Order compare:name2Order];
            }
            else {
                return YES;
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.consolidatedNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cityNameCell";
    CityNameTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        AlternateName *name = [self.consolidatedNames objectAtIndex:indexPath.item];
        
        cell.cultureImage.image = [self.cultureSymbols objectForKey:name.culture];
        
        cell.nameLabel.text = name.name;
        cell.cultureLabel.text = name.culture;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end