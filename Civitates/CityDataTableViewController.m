//
//  CityDataTableViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 5/22/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityDataTableViewController.h"
#import "City.h"
#import "AlternateName.h"
#import "CityNameTableViewCell2.h"

@interface CityDataTableViewController ()

@property NSDictionary *cultureSymbols;
@property NSArray *condensedNames;

@end

@implementation CityDataTableViewController

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
    
    self.condensedNames = [[NSArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.city) {
        self.nameLabel.text = self.city.identifier;
        self.nameDescriptorLabel.text = @"MODERN";
        
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
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSString *culture in [tempDictionary allKeys]) {
            AlternateName *alternateName = [[AlternateName alloc] init];
            alternateName.culture = culture;
            alternateName.name = [tempDictionary objectForKey:culture];
            [tempArray addObject:alternateName];
        }
        
        self.condensedNames = tempArray.copy;
    }
}

- (IBAction)displayWikipediaArticle:(id)sender {
    NSString *articlePath = [NSString stringWithFormat:@"http://wikipedia.com/wiki/%@", self.city.identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:articlePath]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1; // There's always a names section

    if (self.city.physicalData != nil && self.city.physicalData.count > 0) {
        ++numberOfSections;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0) {
        // Section 0 is always names
        return self.condensedNames.count;
    }
    else {
        // If there's another section, it must be physical data
        return self.city.physicalData.count;
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
        
        AlternateName *name = [self.condensedNames objectAtIndex:indexPath.item];
        
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
