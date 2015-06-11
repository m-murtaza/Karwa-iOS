//
//  KSAddressPickerController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/27/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAddressPickerController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "KSLocationManager.h"
#import "KSDAL.h"
#import "KSUser.h"
#import "KSBookmark.h"
#import "CoreData+MagicalRecord.h"


NSString * const KSPickerIdForPickupAddress = @"KSPickerIdForPickupAddress";
NSString * const KSPickerIdForDropoffAddress = @"KSPickerIdForDropoffAddress";
NSString * const KSSpecificRegionName = @"Qatar";

@interface KSAddressPickerController ()<UISearchBarDelegate>
{
    
}

@property (nonatomic, strong) NSArray *places;

@property (nonatomic, strong) NSArray *bookmarks;

@property (nonatomic, strong) NSArray *placemarks;

@end

@implementation KSAddressPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bookmarks = [[[KSDAL loggedInUser] fovourites] allObjects];
    self.placemarks = [NSArray array];
    self.places = [self.placemarks arrayByAddingObjectsFromArray:self.bookmarks];

    __block KSAddressPickerController *me = self;
    // Sync bookmarks
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {
        if (KSAPIStatusSuccess == status) {
            me.bookmarks = bookmarks;
            [me reloadPlaces];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadPlaces {

    self.places = [self.placemarks arrayByAddingObjectsFromArray:self.bookmarks];
    [self.tableView reloadData];
}

- (void)updatePlaces:(NSArray *)placemarks {
    if (!placemarks) {
        placemarks = [NSArray array];
    }
    self.placemarks = placemarks;
    [self reloadPlaces];
    // Select first row;
//    NSIndexPath *firstRow = [NSIndexPath indexPathForItem:0 inSection:0];
//    [self.tableView selectRowAtIndexPath:firstRow animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark -
#pragma mark - Table view datasource

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Favorites";
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const placemarkCellReuseId = @"KSAddressPickerPlacemarkCell";
    static NSString * const bookmarkCellReuseId = @"KSAddressPickerBookmarkCell";
    static NSString * const textCellReuseId = @"KSAddressPickerTextCell";

    UITableViewCell *cell = nil;

    id placeItem = [self.places objectAtIndex:indexPath.row];
    
    if ([placeItem isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:textCellReuseId forIndexPath:indexPath];
        cell.textLabel.text = placeItem;
    }
    else if ([placeItem isKindOfClass:[CLPlacemark class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:placemarkCellReuseId forIndexPath:indexPath];
        CLPlacemark *placemark = (CLPlacemark *)placeItem;
        cell.textLabel.text = placemark.name;
        cell.detailTextLabel.text = placemark.addressWithoutName;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:bookmarkCellReuseId forIndexPath:indexPath];
        cell.textLabel.text = [(KSBookmark *)placeItem name];
    }

    return cell;
}

#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);

    id placeItem = [self.places objectAtIndex:indexPath.row];

    NSString *placeName = nil;
    CLLocation *location = nil;
    if ([placeItem isKindOfClass:[NSString class]]) {
        placeName = placeItem;
    }
    else if ([placeItem isKindOfClass:[CLPlacemark class]]) {
        CLPlacemark *placemark = (CLPlacemark *)placeItem;
        placeName = placemark.address;
        location = placemark.location;
    }
    else {
        KSBookmark *bookmark = (KSBookmark *)placeItem;
        placeName = bookmark.name;
        location = [[CLLocation alloc] initWithLatitude:[bookmark.latitude doubleValue] longitude:[bookmark.longitude doubleValue]];
    }
    [self.delegate addressPicker:self didDismissWithAddress:placeName location:location];
    // Dismiss on selection
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s", __func__);
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%s", __func__);
    KSAddressPickerController *me = self;
    if (searchBar.text.length > 2) {
        [[KSLocationManager instance] nearestPlacemarksInCountry:KSSpecificRegionName searchQuery:searchBar.text completion:^(NSArray *placemarks) {
            if (!placemarks.count) {
                placemarks = [NSArray arrayWithObject: searchBar.text];
            }
            [me updatePlaces:placemarks];
        }];
    }
}

#pragma mark -
#pragma mark - Event handlers


@end
