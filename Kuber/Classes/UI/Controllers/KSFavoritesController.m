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

#import "KSFavoriteDetailsController.h"


@interface KSFavoritesController ()

@property (nonatomic, strong) NSMutableArray *bookmarks;

@property (nonatomic, strong) NSArray *addDeleteBarButtonItems;
@property (nonatomic, strong) NSArray *addOnlyBarButtonItems;

@end

@implementation KSFavoritesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *btnAddPlace = self.navigationItem.rightBarButtonItem;
    UIBarButtonItem *btnDeletePlace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClickDeletePlaces:)];

    self.addOnlyBarButtonItems = @[btnAddPlace];
    self.addDeleteBarButtonItems = @[btnAddPlace, btnDeletePlace];

    [self buildBookmarks];

    __block KSFavoritesController *me = self;
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {
        [me buildBookmarks];
    }];

}

- (void)updateActionButtons {
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    self.navigationItem.rightBarButtonItems = selectedRows.count ? self.addDeleteBarButtonItems : self.addOnlyBarButtonItems;
}

- (void)buildBookmarks {

    KSUser *user = [KSDAL loggedInUser];
    
    self.bookmarks = [NSMutableArray array];
    for (KSBookmark *bookmark in user.fovourites.allObjects) {
        NSMutableDictionary *placeData = [NSMutableDictionary dictionary];
        placeData[@"bookmark"] = bookmark;
        [self.bookmarks addObject:placeData];
    }
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
        [KSLocationManager placemarkForCoordinate:coordinate completion:^(CLPlacemark *placemark) {
            NSString *address = @"";
            if (placemark) {
                address = placemark.address;
            }
            targetPlaceData[@"landmark"] = address;
            
            // Repeat until all bookmarks got addresses
            [me fetchLandmarks];
        }];
    }
    else {
        // Finished loading all landmarks
        [self.tableView reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    NSLog(@"%s", __func__);
    
#warning TODO: Add code for deleting a bookmark
}


@end
