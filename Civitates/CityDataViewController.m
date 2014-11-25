//
//  CityDataControllerViewController.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 11/14/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "CityDataViewController.h"
#import "City.h"
#import "CityPhysicalViewController.h"
#import "CityNameTableViewController.h"

@interface CityDataViewController ()

@property CityPhysicalViewController *physicalViewController;
@property CityNameTableViewController *tableViewController;

@end

@implementation CityDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewController = [[UIStoryboard storyboardWithName:@"CityPopover" bundle:nil] instantiateViewControllerWithIdentifier:@"CityNameTableViewController"];
    self.tableViewController.city = self.city;
    
    self.physicalViewController = [[UIStoryboard storyboardWithName:@"CityPopover" bundle:nil] instantiateViewControllerWithIdentifier:@"CityPhysicalViewController"];
    self.physicalViewController.city = self.city;
  
    [self.contentView addSubview:self.tableViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.city) {
        self.nameLabel.text = self.city.identifier;
        self.nameDescriptorLabel.text = self.city.title;
    }
    
    CGRect contentFrame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    if (self.physicalViewController) {
        self.physicalViewController.view.frame = contentFrame;
    }
    
    if (self.tableViewController) {
        self.tableViewController.view.frame = contentFrame;
    }
}

- (IBAction)segmentedControlSelected:(id)sender {
//    [[self.contentView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    UISegmentedControl *segmentedControl = sender;
//    CGRect contentFrame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self animateSlideRightFromView:self.physicalViewController.view toView:self.tableViewController.view];
//        self.tableViewController.view.frame = contentFrame;
//        [self.contentView addSubview:self.tableViewController.view];
    }
    else {
        [self animateSlideLeftFromView:self.tableViewController.view toView:self.physicalViewController.view];
//        self.physicalViewController.view.frame = contentFrame;
//        [self.contentView addSubview:self.physicalViewController.view];
    }
}

- (void)animateSlideLeftFromView:(UIView *)startView toView:(UIView *)endView {
    double width = self.contentView.frame.size.width;
    double height = self.contentView.frame.size.height;
    
    CGRect displayFrame = CGRectMake(0.0, 0.0, width, height);
    CGRect offscreenLeftFrame = CGRectMake(width * -1.0, 0.0, width, height);
    CGRect offscreenRightFrame = CGRectMake(width, 0.0, width, height);
    
    // Add the endView offscreen
    endView.frame = offscreenRightFrame;
    [self.contentView addSubview:endView];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [endView setFrame:displayFrame];
                         [startView setFrame:offscreenLeftFrame];
                     }
                     completion:^(BOOL finished){
                         [startView removeFromSuperview];
                     }
     ];
}

- (void)animateSlideRightFromView:(UIView *)startView toView:(UIView *)endView {
    double width = self.contentView.frame.size.width;
    double height = self.contentView.frame.size.height;
    
    CGRect displayFrame = CGRectMake(0.0, 0.0, width, height);
    CGRect offscreenLeftFrame = CGRectMake(width * -1.0, 0.0, width, height);
    CGRect offscreenRightFrame = CGRectMake(width, 0.0, width, height);
    
    // Add the endView offscreen
    endView.frame = offscreenLeftFrame;
    [self.contentView addSubview:endView];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [endView setFrame:displayFrame];
                         [startView setFrame:offscreenRightFrame];
                     }
                     completion:^(BOOL finished){
                         [startView removeFromSuperview];
                     }
     ];
}

- (IBAction)displayWikipediaArticle:(id)sender {
    NSString *articlePath = [NSString stringWithFormat:@"http://wikipedia.com/wiki/%@", self.city.identifier];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:articlePath]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
