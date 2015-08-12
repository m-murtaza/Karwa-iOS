//
//  KSAddressPickerController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/27/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSAddressPickerController_Old.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "KSLocationManager.h"
#import "KSDAL.h"
#import "KSUser.h"
#import "KSBookmark.h"
#import "CoreData+MagicalRecord.h"

#import "KSGeoLocation.h"
#import "KSAddressPickerDelegate.h"

@interface KSAddressPickerController_Old ()<UISearchBarDelegate>
{
    
}

@property (nonatomic, strong) NSArray *places;

@property (nonatomic, strong) NSArray *bookmarks;

@property (nonatomic, strong) NSArray *placemarks;

@end

@implementation KSAddressPickerController_Old

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bookmarks = [[[KSDAL loggedInUser] bookmarks] allObjects];
    self.placemarks = [NSArray array];
    self.places = [self.placemarks arrayByAddingObjectsFromArray:self.bookmarks];
    //    self.places = [NSArray arrayWithObject:@"No place"];
    __block KSAddressPickerController_Old *me = self;
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
    
    UITableView *tableView = self.tableView;
    
    self.places = [self.placemarks arrayByAddingObjectsFromArray:self.bookmarks];
    
    [tableView reloadData];
    
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

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    
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
    else if ([placeItem isKindOfClass:[KSGeoLocation class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:placemarkCellReuseId forIndexPath:indexPath];
        KSGeoLocation *placemark = (KSGeoLocation *)placeItem;
        cell.textLabel.text = placemark.address;
        cell.detailTextLabel.text = placemark.area;
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
    else if ([placeItem isKindOfClass:[KSGeoLocation class]]) {
        KSGeoLocation *placemark = (KSGeoLocation *)placeItem;
        placeName = placemark.address;
        location = [[CLLocation alloc] initWithLatitude:placemark.latitude.doubleValue longitude:placemark.longitude.doubleValue];
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
    //    KSAddressPickerController *me = self;
    if (searchBar.text.length > 2) {
        
        NSArray *placemarks = [KSDAL locationsMatchingText:searchBar.text];
        if (!placemarks.count) {
            placemarks = [NSArray arrayWithObject: searchBar.text];
        }
        [self updatePlaces:placemarks];
        //        [[KSLocationManager instance] nearestPlacemarksInCountry: @"Qatar" searchQuery:searchBar.text completion:^(NSArray *placemarks) {
        //            if (!placemarks.count) {
        //                placemarks = [NSArray arrayWithObject: searchBar.text];
        //            }
        //            [me updatePlaces:placemarks];
        //        }];
    }
}

#pragma mark -
#pragma mark - Event handlers


@end
