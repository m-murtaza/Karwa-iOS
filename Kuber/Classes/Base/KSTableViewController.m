//
//  KSTableViewController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSTableViewController.h"


@interface KSTableViewController () {

    UIView *_mainView;
}

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

@property (nonatomic, strong) UIView *overlayView;

@end

const NSInteger KSTableViewOverlayTagForLoadingView = 10;
const NSInteger KSTableViewOverlayTagForNoDataLabel = 10;

@implementation KSTableViewController

- (UILabel *)noDataLabel {
    return (UILabel *)[self.overlayView viewWithTag:KSTableViewOverlayTagForNoDataLabel];
}

- (UIView *)overlayView {
    if (!_overlayView) {
        CGRect frameRect = self.tableView.frame;
        CGFloat y = 0;
        if (self.navigationController) {
            y = self.navigationController.navigationBar.frame.size.height;
        }
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameRect.size.width, frameRect.size.height - y)];
        _overlayView.backgroundColor = [UIColor clearColor];

        frameRect = _overlayView.frame;

        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameRect.size.width, frameRect.size.height)];
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.text = KSTableViewDefaultErrorMessage;
        noDataLabel.textColor = [UIColor darkTextColor];
        noDataLabel.backgroundColor = self.tableView.backgroundColor;
        noDataLabel.tag = KSTableViewOverlayTagForNoDataLabel;

        [_overlayView addSubview:noDataLabel];
    }
    return _overlayView;
}

- (void)setNoDataMessage:(NSString *)message {

    self.noDataLabel.text = message;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupRevealViewController];
    
    //set Back button title
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@""
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:nil];
    [self.navigationItem setBackBarButtonItem: btnBack];
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

- (void)showNoDataLabel {

    [self.view addSubview:self.overlayView];
    [self.tableView setScrollEnabled:NO];
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0)];
}

- (void)hideNoDataLabel {

    [self.overlayView removeFromSuperview];
    [self.tableView setScrollEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger numberOfRows = [self numberOfRowsInSection:section];
    if (!numberOfRows) {
        [self showNoDataLabel];
    }
    else {
        [self hideNoDataLabel];
    }
    return numberOfRows;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [super tableView:self.tableView numberOfRowsInSection:section];
}

- (void)reloadTableViewData {

    [self.tableView reloadData];
}

@end
