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
#import "KSAddressPickerDelegate.h"
#import "UISegmentedControl+KSExtended.h"
#import "KSButtonCell.h"
#import "KSFavoriteDetailsController.h"

typedef enum {
    
    KSTableViewTypeFavorites = 0,
    KSTableViewTypeNearby = 1,
    KSTableViewTypeRecent = 2
}
KSTableViewType;


@interface KSAddressPickerController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray *_recentBookings;
    
    NSArray *_savedBookmarks;
    
    NSArray *_nearestLocations;
    
    NSArray *_searchLocations;
    
    KSGeoLocation *selectedGeoLocation;
}

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) KSTableViewType tableViewType;

- (IBAction)onSegmentChange:(id)sender;

@end

@implementation KSAddressPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedGeoLocation = nil;

    UIImage *searchIcon = [UIImage imageNamed:@"search-icon.png"];
    UIImageView *searchIconView = [[UIImageView alloc] initWithImage:searchIcon];
    searchIconView.frame = CGRectMake(0, 0, searchIcon.size.width, searchIcon.size.height);
    self.searchField.leftView = searchIconView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;

    [self.searchField addTarget:self action:@selector(onSearchTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    // Customize segment control
    UIImage *segmentImg = [UIImage imageNamed:@"segment_unselected.png"];
    UIImage *highlightedSegmentImg = [UIImage imageNamed:@"segment_selected.png"];
    UIImage *segmentDividerImg = [UIImage imageNamed:@"segment_splitter.png"];
    
    [self.segmentControl setBackgroudImage:segmentImg
                          highlightedImage:highlightedSegmentImg
                              dividerImage:segmentDividerImg];

    UIColor *segmentHighlightColor = [UIColor colorWithRed:90.0 / 255.0
                                                     green:250.0 / 255.0
                                                      blue:250.0 / 255.0
                                                     alpha:1.];
    [self.segmentControl setTitleColor:segmentHighlightColor
                       forControlState:UIControlStateHighlighted];
    [self.segmentControl setTitleColor:segmentHighlightColor
                       forControlState:UIControlStateSelected];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [KSGoogleAnalytics trackPage:@"AddressPicker"];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addCellButtonObserver];
    [self loadAllData];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Private Methods
-(void) addCellButtonObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favButtonTapped:)
                                                 name:KSNotificationButtonFavCellAction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavButtonTapped:)
                                                 name:KSNotificationButtonUnFavCellAction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavBookmarkButtonTapped:)
                                                 name:KSNotificationButtonUnFavBookmarkCellAction
                                               object:nil];
}

-(void) loadAllBookmarkData
{
    //_savedBookmarks = [[[KSDAL loggedInUser] bookmarks] allObjects];
    NSArray *arr = [[[KSDAL loggedInUser] bookmarks] allObjects];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    _savedBookmarks = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
}
-(void) loadAllData
{
    [self loadAllBookmarkData];
    
    
    
    
    _recentBookings = [KSDAL recentTripsWithLandmarkText];
    _nearestLocations = [NSArray array];
    
    if(self.searchField.text != nil && ![self.searchField.text isEqualToString:@""])
    {
        _searchLocations = [KSDAL locationsMatchingText:self.searchField.text];
    }
    else{
      _searchLocations = [NSArray array];
    }
    
    
    CLLocation *currentLocation = [KSLocationManager location];
    
    self.tableViewType = KSTableViewTypeFavorites;
    
    
    if (currentLocation) {
        
        CLLocationCoordinate2D coordinate = currentLocation.coordinate;
        _nearestLocations = [KSDAL nearestLocationsMatchingLatitude:coordinate.latitude longitude:coordinate.longitude radius:500.0];
        
        NSMutableArray *tempLocations = [NSMutableArray array];
        for (KSGeoLocation *location in _nearestLocations) {
            BOOL isUnique = YES;
            for (KSGeoLocation *location2 in tempLocations) {
                if ([location2.address isEqual:location.address]) {
                    isUnique = NO;
                    break;
                }
            }
            if (isUnique) {
                [tempLocations addObject:location];
            }
        }
        _nearestLocations = [NSArray arrayWithArray:tempLocations];
        
        if (_nearestLocations.count) {
            self.tableViewType = KSTableViewTypeNearby;
        }
    }
    self.segmentControl.selectedSegmentIndex = self.tableViewType;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueAddPickerToBookmark"]) {
        KSFavoriteDetailsController * favController = (KSFavoriteDetailsController*)segue.destinationViewController;
        favController.gLocation = selectedGeoLocation;
    }
    
    
    
    
}

#pragma mark -
#pragma mark - Notifications
-(void) favButtonTapped:(NSNotification*)data
{
    selectedGeoLocation = (KSGeoLocation*) [[data userInfo] valueForKey:@"cellData"];
    [self performSegueWithIdentifier:@"SegueAddPickerToBookmark" sender:self];
    
    NSLog(@"%@",selectedGeoLocation);
    
    /*NSLog(@"data %@",[[data userInfo] valueForKey:@"cellData"]);
    [KSDAL addBookMarkForGeoLocation:[[data userInfo] valueForKey:@"cellData"] completion:^(KSAPIStatus status, id response) {
        
        [self loadAllData];
        [self.tableView reloadData];
    }];*/
    
}

-(void) unfavButtonTapped:(NSNotification*)data
{
    NSLog(@"data %@",[[data userInfo] valueForKey:@"cellData"]);
    [KSDAL removeBookMarkForGeoLocation:[[data userInfo] valueForKey:@"cellData"] completion:^(KSAPIStatus status, id response) {
        if (KSAPIStatusSuccess == status) {
         
            [self loadAllData];
            [self.tableView reloadData];
        }
        else{
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
        
    }];
   
}

-(void) unfavBookmarkButtonTapped:(NSNotification*)data
{
    /*[KSDAL deleteBookmark:[[data userInfo] valueForKey:@"cellData"] completion:^(KSAPIStatus status, id response) {
        if (KSAPIStatusSuccess == status) {
            
            [self loadAllData];
            [self.tableView reloadData];
        }
        else{
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
    }];*/
}

#pragma mark -
#pragma mark - Table view datasource

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Favorites";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (self.tableViewType) {
        case KSTableViewTypeFavorites:
            return _savedBookmarks.count;
        case KSTableViewTypeRecent:
            return _recentBookings.count;
        default:
            if (self.searchField.text.length) {
                return _searchLocations.count;
            }
            return _nearestLocations.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * const nearbyCellReuseId = @"KSGeoLocationCellId";
    static NSString * const bookmarkCellReuseId = @"KSBoomarkCellId";
    static NSString * const recentCellReuseId = @"KSGeoLocationCellId";

    NSString *cellReuseId;
    KSButtonCell *cell = nil;
    id cellData;
    switch (self.tableViewType) {
        case KSTableViewTypeFavorites:
            cellReuseId = bookmarkCellReuseId;
            cellData = [_savedBookmarks objectAtIndex:indexPath.row];
            break;

        case KSTableViewTypeRecent:
            cellReuseId = recentCellReuseId;
            cellData = [_recentBookings objectAtIndex:indexPath.row];
            break;

        default:
            if (self.searchField.text.length) {
                cellData = [_searchLocations objectAtIndex:indexPath.row];
            }
            else {
                cellData = [_nearestLocations objectAtIndex:indexPath.row];
            }
            cellReuseId = nearbyCellReuseId;
            break;
    }
    
    cell = (KSButtonCell *)[tableView dequeueReusableCellWithIdentifier:cellReuseId forIndexPath:indexPath];
    
    
    
    cell.cellData = cellData;
    
    return cell;
}

#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"%s", __func__);

    NSString *placeName = nil;
    CLLocation *location = nil;
    KSBookmark *bookmark;
    KSGeoLocation *geolocation;
    KSTrip *trip;
    switch (self.tableViewType) {
        case KSTableViewTypeFavorites:
            bookmark = [_savedBookmarks objectAtIndex:indexPath.row];
            placeName = bookmark.address.length ? bookmark.address : bookmark.name;
            location = [[CLLocation alloc] initWithLatitude:bookmark.latitude.doubleValue longitude:bookmark.longitude.doubleValue];
            break;

        case KSTableViewTypeRecent:
            trip = [_recentBookings objectAtIndex:indexPath.row];
            placeName = trip.dropoffLandmark;
            if (trip.pickupLandmark.length) {
                placeName = trip.pickupLandmark;
                location = [[CLLocation alloc] initWithLatitude:trip.pickupLat.doubleValue longitude:trip.pickupLon.doubleValue];
            }
            else {
                location = [[CLLocation alloc] initWithLatitude:trip.dropOffLat.doubleValue longitude:trip.dropOffLon.doubleValue];
            }
            break;

        default:
            if (self.searchField.text.length) {
                geolocation = [_searchLocations objectAtIndex:indexPath.row];
            }
            else {
                geolocation = [_nearestLocations objectAtIndex:indexPath.row];
            }
            placeName = geolocation.address;
            location = [[CLLocation alloc] initWithLatitude:geolocation.latitude.doubleValue longitude:geolocation.longitude.doubleValue];
            break;
    }

    [self.delegate addressPicker:self didDismissWithAddress:placeName location:location];

    // Dismiss on selection
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.searchField) {

        [textField resignFirstResponder];

        if (textField.text.length > 2) {
            
            KSAddressPickerController *me = self;
//            _searchLocations = [KSDAL locationsMatchingText:textField.text];
            if (self.segmentControl.selectedSegmentIndex != KSTableViewTypeNearby) {
                self.segmentControl.selectedSegmentIndex = KSTableViewTypeNearby;
                _tableViewType = KSTableViewTypeNearby;
            }
            [self showLoadingView];
            [[KSLocationManager instance] placemarksMatchingQuery:textField.text country:@"" completion:^(NSArray *placemarks) {
                [self hideLoadingView];
                _searchLocations = placemarks;
                [me.tableView reloadData];
            }];
//            [self.tableView reloadData];
        }
        return NO;
    }
    return YES;
}

- (void)onSearchTextChange:(UITextField *)textField {
    
    if (textField == self.searchField) {

        if (!textField.text.length) {
            if (KSTableViewTypeNearby == self.segmentControl.selectedSegmentIndex) {
                
                [self.tableView reloadData];
            }
        }
    }
}

#pragma mark -
#pragma mark - Event handlers

- (IBAction)onSegmentChange:(id)sender {
    
    self.tableViewType =  (KSTableViewType)self.segmentControl.selectedSegmentIndex;

    [self.tableView reloadData];
}


@end
