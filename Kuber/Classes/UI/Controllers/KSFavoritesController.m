//
//  KSFavoritesController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSFavoritesController.h"

#import "KSDAL.h"
#import "KSBookmark.h"
#import "KSUser.h"
#import "KSLocationManager.h"

#import "KSGeoLocation.h"

#import "KSFavoriteDetailsController.h"
#import "MBProgressHUD.h"


@interface KSFavoritesController ()

@property (nonatomic, strong) NSMutableArray *bookmarks;

@property (nonatomic, strong) NSArray *addDeleteBarButtonItems;
@property (nonatomic, strong) NSArray *addOnlyBarButtonItems;

@end

@implementation KSFavoritesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.bookmarks = [NSMutableArray array];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFavoriteChangeNotification:) name:KSNotificationForNewBookmark object:nil];

    UIBarButtonItem *btnAddPlace = self.navigationItem.rightBarButtonItem;
    UIBarButtonItem *btnDeletePlace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClickDeletePlaces:)];

    self.addOnlyBarButtonItems = @[btnAddPlace];
    self.addDeleteBarButtonItems = @[btnAddPlace, btnDeletePlace];

    __block KSFavoritesController *me = self;
    [me showLoadingView];
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {
        [me buildBookmarks];
        [me hideLoadingView];
    }];

    [self buildBookmarks];

}

- (void)updateActionButtons {
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    self.navigationItem.rightBarButtonItems = selectedRows.count ? self.addDeleteBarButtonItems : self.addOnlyBarButtonItems;
}

- (void)buildBookmarks {

    KSUser *user = [KSDAL loggedInUser];
    
    NSArray *sortedBookmarks = [user.bookmarks.allObjects sortedArrayUsingComparator:^NSComparisonResult(KSBookmark *obj1, KSBookmark *obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];

    [self.bookmarks removeAllObjects];

    for (KSBookmark *bookmark in sortedBookmarks) {
        NSMutableDictionary *placeData = [NSMutableDictionary dictionary];
        placeData[@"bookmark"] = bookmark;
        [self.bookmarks addObject:placeData];
    }

    [self updateActionButtons];
    [self fetchLandmarks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchLandmarks {

    __block NSMutableDictionary *targetPlaceData = nil;
    for (NSMutableDictionary *placeData in self.bookmarks) {
        if (!placeData[@"landmark"]) {
            targetPlaceData = placeData;
            break;
        }
    }
    if (targetPlaceData) {
        KSBookmark *bookmark = targetPlaceData[@"bookmark"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(bookmark.latitude.doubleValue, bookmark.longitude.doubleValue);
        __block KSFavoritesController *me = self;
        [KSLocationManager placemarkForCoordinate:coordinate completion:^(KSGeoLocation *geolocation) {
            NSString *address = @"";
            if (geolocation) {
                address = geolocation.address;
            }
            targetPlaceData[@"landmark"] = address;
            // Repeat until all bookmarks got addresses
            dispatch_async(dispatch_get_main_queue(), ^{
                [me fetchLandmarks];
            });
        }];
    }
    else {
        // Finished loading all landmarks
        [self reloadTableViewData];
    }
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[KSFavoriteDetailsController class]]) {
        KSFavoriteDetailsController *controller = (KSFavoriteDetailsController *)segue.destinationViewController;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSDictionary *placeData = self.bookmarks[indexPath.row];
            controller.bookmark = placeData[@"bookmark"];
            controller.landmark = placeData[@"landmark"];
        }
    }
}


#pragma mark -
#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const placemarkCellReuseId = @"KSFavoritesCell";
    
    NSDictionary *placeData = self.bookmarks[indexPath.row];
    KSBookmark *bookmark = placeData[@"bookmark"];
    NSString *landmark = placeData[@"landmark"];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placemarkCellReuseId forIndexPath:indexPath];

    cell.textLabel.text = bookmark.name;
    if (landmark.length) {
        cell.detailTextLabel.text = landmark;
    }

    return cell;
}

#pragma mark -
#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateActionButtons];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateActionButtons];
}

#pragma mark -
#pragma mark - Event handlers

- (void)onClickDeletePlaces:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (!indexPath) {
        return;
    }
    NSDictionary *placeData = self.bookmarks[indexPath.row];
    KSBookmark *bookmark = placeData[@"bookmark"];

    [self showLoadingView];
    __block KSFavoritesController *me = self;
    [KSDAL deleteBookmark:bookmark completion:^(KSAPIStatus status, NSDictionary *data) {
        [me hideLoadingView];
        if (KSAPIStatusSuccess == status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [me buildBookmarks];
            });
        }
        else {
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];
}

- (void)onFavoriteChangeNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildBookmarks];
    });
}

@end
