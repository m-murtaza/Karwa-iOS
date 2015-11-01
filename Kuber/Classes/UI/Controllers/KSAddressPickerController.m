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

#import "KSSafeArray.h"

typedef enum {
    
    KSTableViewTypeFavorites = 0,
    KSTableViewTypeNearby = 1,
    KSTableViewTypeRecent = 2
}
KSTableViewType;

#define NO_SECTION_INDEX        -1
#define LOADING_CELL_IDX        2
#define LOAD_MORE_TEXT          @"Load more data...";
#define LOAD_MORE_CELL_HEIGHT   25.0
#define TABLEVIEW_HEADER_HEIGHT 32.0
#define TABLEVIEW_CELL_HEIGHT   70.0
#define PLACE_HOLDER_TEXT       @"Search a place from list..."

@interface KSAddressPickerController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    KSSafeArray *_recentBookings;
    
    KSSafeArray *_savedBookmarks;
    
    KSSafeArray *_nearestLocations;
    
    KSSafeArray *_searchLocations;
    KSSafeArray *_searchSavedBookmarks;
    KSSafeArray *_searchRecentBookings;
    
    NSInteger idxNearSection;
    NSInteger idxFavSection;
    NSInteger idxRecentSection;
    BOOL showAllNearBy;
    BOOL showAllFav;
    BOOL showAllRecent;
    
    KSGeoLocation *selectedGeoLocation;
    KSTrip *selectedTrip;
}

@property (weak, nonatomic) IBOutlet UITextField *searchField;

//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) KSTableViewType tableViewType;

//- (IBAction)onSegmentChange:(id)sender;

@end

@implementation KSAddressPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedGeoLocation = nil;
    selectedTrip = nil;
    showAllNearBy = NO;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = TABLEVIEW_CELL_HEIGHT;
    
    [self SetSearchFieldUI];
    //self.navigationItem.hidesBackButton = YES;

    //self.navigationItem.titleView.center = self.navigationController.navigationBar.center;
   
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
    [self.tableView reloadData];
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
-(void)reloadTableData
{
    [self.tableView reloadData];
    
    //Ultimate Jugar (patch)
    [self performSelector:@selector(loadTbl) withObject:nil afterDelay:0.01];
}

-(void) SetSearchFieldUI
{
    UIImage *searchIcon = [UIImage imageNamed:@"search-ico.png"];
    UIImageView *searchIconView = [[UIImageView alloc] initWithImage:searchIcon];
    searchIconView.frame = CGRectMake(20, 0, searchIcon.size.width, searchIcon.size.height);
    self.searchField.leftView = searchIconView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"cancel.png"]
                 forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"cancel.png"]
                 forState:UIControlStateHighlighted];
    [closeButton addTarget:self
                    action:@selector(closeSearch:)
          forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake(0, 0, searchIcon.size.width, searchIcon.size.height);
    self.searchField.rightView = closeButton;
    self.searchField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    
    UIColor *color = [UIColor colorFromHexString:@"#777777"];
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:PLACE_HOLDER_TEXT attributes:@{NSForegroundColorAttributeName: color}];
    self.searchField.font = [UIFont fontWithName:KSMuseoSans500 size:15];
    self.searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}

-(NSString*) sectionTitleForSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    
    if (section == idxNearSection) {
        sectionTitle = @"Nearby";
    }
    else if(section == idxFavSection){
        sectionTitle = @"Favorites";
    }
    else{
        
        sectionTitle = @"Recent";
    }
    return sectionTitle;
}

- (void) filterFavLocationFortext:(NSString*)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@",searchText];
    _searchSavedBookmarks = (KSSafeArray*)[_savedBookmarks filteredArrayUsingPredicate:predicate];
}

- (void) filterRecentLocationsForText: (NSString*) searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pickupLandmark CONTAINS[c] %@",searchText];
    _searchRecentBookings = (KSSafeArray*)[_recentBookings filteredArrayUsingPredicate:predicate];
}
- (NSInteger) numberOfRowWhenSearchingForSection:(NSInteger)section
{
    NSInteger numRow = 0;
    if (section == idxNearSection) {
        if (showAllNearBy || _searchLocations.count <= LOADING_CELL_IDX)
            numRow = _searchLocations.count;
            
        else
            numRow = LOADING_CELL_IDX + 1;
    }
    else if(section == idxFavSection){
        if (showAllFav || _searchSavedBookmarks.count <= LOADING_CELL_IDX)
            numRow = _searchSavedBookmarks.count;
        else
            numRow = LOADING_CELL_IDX + 1;
    }
    else if(section == idxRecentSection){
        if (showAllRecent || _searchRecentBookings.count <= LOADING_CELL_IDX)
            numRow = _searchRecentBookings.count;
        else
            numRow = LOADING_CELL_IDX + 1;
    }
        
    return numRow;
}

-(NSInteger) numberOfRowWhenNotSearchingForSection:(NSInteger)section
{
    NSInteger numRow = 0;
    if (section == idxNearSection) {
        if (showAllNearBy || _nearestLocations.count <= LOADING_CELL_IDX)
            numRow = _nearestLocations.count;
        else
            numRow = LOADING_CELL_IDX + 1;
    }
    else if(section == idxFavSection){
        if (showAllFav || _savedBookmarks.count <= LOADING_CELL_IDX)
            numRow = _savedBookmarks.count;
        else
            numRow = LOADING_CELL_IDX + 1;
    }
    
    else if(section == idxRecentSection){
        if (showAllRecent || _recentBookings.count <= LOADING_CELL_IDX)
            numRow = _recentBookings.count;
        else
            numRow = LOADING_CELL_IDX + 1;
    }
    
    return numRow;
}

-(NSInteger) numberOfSectionsWhenSearching
{
    NSInteger sectionCount = 0;
    
    idxNearSection = NO_SECTION_INDEX;
    idxFavSection = NO_SECTION_INDEX;
    idxRecentSection = NO_SECTION_INDEX;
    
    if (_searchLocations.count > 0) {
        idxNearSection = 0;
        sectionCount ++;
    }
    if (_searchSavedBookmarks.count > 0) {
        
        idxFavSection = idxNearSection + 1;
        sectionCount++;
    }
    if (_searchRecentBookings.count > 0) {
        
        idxRecentSection = idxNearSection + idxFavSection + 2;
        if (idxRecentSection > 2) {
            idxRecentSection = 2;
        }
        sectionCount++;
    }
    return sectionCount;
}

-(NSUInteger) numberOfSerctionsWhenNotSearching
{
    NSInteger sectionCount = 0;
    
    idxNearSection = NO_SECTION_INDEX;
    idxFavSection = NO_SECTION_INDEX;
    idxRecentSection = NO_SECTION_INDEX;
    
    if (_nearestLocations.count > 0) {
        idxNearSection = 0;
        sectionCount++;
    }
    if (_savedBookmarks.count > 0) {
        
        idxFavSection = idxNearSection + 1;
        sectionCount++;
    }
    if(_recentBookings.count > 0){
        idxRecentSection = idxNearSection + idxFavSection + 2;
        if (idxRecentSection > 2) {
            idxRecentSection = 2;
        }
        sectionCount++;
    }
    
    return sectionCount;
}


-(void) addCellButtonObserver
{
    //For Geolocations
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favButtonTapped:)
                                                 name:KSNotificationButtonFavCellAction
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavButtonTapped:)
                                                 name:KSNotificationButtonUnFavCellAction
                                               object:nil];
    //For Bookmark / Favorites
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavBookmarkButtonTapped:)
                                                 name:KSNotificationButtonUnFavBookmarkCellAction
                                               object:nil];
    
    //For Recent Trip
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavRecentkButtonTapped:)
                                                 name:KSNotificationButtonUnFavRecentCellAction
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favRecentButtonTapped:)
                                                 name:KSNotificationButtonFavRecentCellAction
                                               object:nil];
}

-(void) loadAllBookmarkData
{
    //_savedBookmarks = [[[KSDAL loggedInUser] bookmarks] allObjects];
    NSArray *arr = [[[KSDAL loggedInUser] bookmarks] allObjects];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO];
    _savedBookmarks = (KSSafeArray*)[arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
}
-(void) loadAllData
{
    [self loadAllBookmarkData];
 
    _recentBookings = (KSSafeArray*)[KSDAL recentTripsWithLandmark:10];
    //_recentBookings = [KSDAL recentTripsWithLandmarkText];
    _nearestLocations = (KSSafeArray*)[NSArray array];
    
    if(self.searchField.text != nil && ![self.searchField.text isEqualToString:@""])
    {
        _searchLocations = (KSSafeArray*)[KSDAL locationsMatchingText:self.searchField.text];
    }
    else{
      _searchLocations = (KSSafeArray*)[NSArray array];
    }
    
    
    //--CLLocation *currentLocation = [KSLocationManager location];
    
    //self.tableViewType = KSTableViewTypeFavorites;
    
    [self loadAllNearByFromLocalDB];
    [self.tableView reloadData];
    
    //Ultimate Jugar (patch)
    [self performSelector:@selector(loadTbl) withObject:nil afterDelay:0.01];
    
    //Background server call for nearby locations.
    if (!_nearestLocations.count) {
        [self showLoadingView];
    }
    
    [self fetchNearByFromServer];
        
    
}
-(void) loadAllNearByFromLocalDB
{
    CLLocation *currentLocation = [KSLocationManager location];
    if (currentLocation) {
        
        CLLocationCoordinate2D coordinate = currentLocation.coordinate;
        _nearestLocations = (KSSafeArray*)[KSDAL nearestLocationsMatchingLatitude:coordinate.latitude longitude:coordinate.longitude radius:500.0];
        
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
        _nearestLocations = (KSSafeArray*)[NSArray arrayWithArray:tempLocations];
        
        if (_nearestLocations.count) {
            self.tableViewType = KSTableViewTypeNearby;
        }
    }
}


-(void) fetchNearByFromServer
{
    CLLocation *currentLocation = [KSLocationManager location];
    [KSDAL nearestLocationsFromServerMatchingLatitude:currentLocation.coordinate.latitude
                                            longitude:currentLocation.coordinate.longitude
                                               radius:80.0 completion:^(KSAPIStatus status, id response) {
                                                   if (status == KSAPIStatusSuccess) {

                                                           [self hideLoadingView];
                                                           [self loadAllNearByFromLocalDB];
                                                           [self reloadTableData];

                                                   }
                                                   else{
                                                       DLog(@"Error Fetching nearby location %lu",(unsigned long)status);
                                                   }
                                               }];
}

-(void)loadTbl
{
    [self.tableView reloadData];
}

#pragma mark - Event handlers 

-(void) closeSearch:(id)sender
{
    [self.searchField resignFirstResponder];
    [self.searchField setText:@""];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueAddPickerToBookmarkForGeoLocation"]) {
        
        KSFavoriteDetailsController * favController = (KSFavoriteDetailsController*)segue.destinationViewController;
        favController.gLocation = selectedGeoLocation;
    }
    else if([segue.identifier isEqualToString:@"SegueAddPickerToBookmarkForTrip"]){
        
        KSFavoriteDetailsController * favController = (KSFavoriteDetailsController*)segue.destinationViewController;
        favController.trip = selectedTrip;
    }
    
    
    
}

#pragma mark -
#pragma mark - Notifications
-(void) favButtonTapped:(NSNotification*)data
{
    selectedGeoLocation = (KSGeoLocation*) [[data userInfo] valueForKey:@"cellData"];
    [self performSegueWithIdentifier:@"SegueAddPickerToBookmarkForGeoLocation" sender:self];
    
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


//For Recent Trip
-(void) favRecentButtonTapped:(NSNotification*)data
{
    selectedTrip = (KSTrip*) [[data userInfo] valueForKey:@"cellData"];
    [self performSegueWithIdentifier:@"SegueAddPickerToBookmarkForTrip" sender:self];
    
    NSLog(@"%@",selectedTrip);
    
    /*NSLog(@"data %@",[[data userInfo] valueForKey:@"cellData"]);
     [KSDAL addBookMarkForGeoLocation:[[data userInfo] valueForKey:@"cellData"] completion:^(KSAPIStatus status, id response) {
     
     [self loadAllData];
     [self.tableView reloadData];
     }];*/
    
}

-(void) unfavRecentkButtonTapped:(NSNotification*)data
{
    NSLog(@"data %@",[[data userInfo] valueForKey:@"cellData"]);
    [KSDAL removeBookMarkForTrip:[[data userInfo] valueForKey:@"cellData"]
                      completion:^(KSAPIStatus status, id response) {
        if (KSAPIStatusSuccess == status) {
            
            [self loadAllData];
            [self.tableView reloadData];
        }
        else{
            [KSAlert show:KSStringFromAPIStatus(status)];
        }
        
    }];
}

//Rof Bookmark
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return TABLEVIEW_HEADER_HEIGHT;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString *sectionName = @"";
    
    if (section == idxNearSection) {
        sectionName = @"Nearby";
    }
    else if(section == idxFavSection){
        sectionName = @"Favorites";
    }
    else{
    
        sectionName = @"Recent";
    }
    return sectionName;
    
    ////    if (self.searchField.text.length) {
////        return @"";
////    }
////    else{
//        NSString *sectionName;
//        switch (section)
//        {
//            case 0:
//                sectionName = @"Nearby";
//                break;
//            case 1:
//                sectionName = @"Favorites";
//                break;
//                // ...
//            default:
//                sectionName = @"Recent";
//                break;
//        }
//        return sectionName;
////    }
    
}
*/

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, TABLEVIEW_HEADER_HEIGHT)] ;
   
    [headerView setBackgroundColor:[UIColor colorFromHexString:@"#e5edf4"]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, tableView.bounds.size.width-20, TABLEVIEW_HEADER_HEIGHT)];
    title.text = [self sectionTitleForSection:section];
    [title setTextColor:[UIColor colorFromHexString:@"#187a89"]];
    [title setFont:[UIFont fontWithName:KSMuseoSans500 size:14.0]];

    [headerView addSubview:title];
    return headerView;
}
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    CGFloat cellHeight = TABLEVIEW_CELL_HEIGHT;
    
    DLog(@"row = %ld, section = %ld",(long)indexPath.row,(long)indexPath.section);
    
    if (section == idxNearSection && showAllNearBy == FALSE && indexPath.row == LOADING_CELL_IDX)
        cellHeight = LOAD_MORE_CELL_HEIGHT;
    else if(section == idxFavSection && showAllFav == FALSE && indexPath.row == LOADING_CELL_IDX)
        cellHeight = LOAD_MORE_CELL_HEIGHT;
    else if(section == idxRecentSection && showAllRecent == FALSE && indexPath.row == LOADING_CELL_IDX)
        cellHeight = LOAD_MORE_CELL_HEIGHT;

    if (cellHeight == LOAD_MORE_CELL_HEIGHT) {
        return cellHeight;
    }
    return UITableViewAutomaticDimension;
    //return cellHeight;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if (self.searchField.text.length) {
        return [self numberOfSectionsWhenSearching];
    }
    return [self numberOfSerctionsWhenNotSearching];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchField.text.length) {
        return [self numberOfRowWhenSearchingForSection:section];
    }
    return [self numberOfRowWhenNotSearchingForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    static NSString * const nearbyCellReuseId = @"KSGeoLocationCellId";
    static NSString * const bookmarkCellReuseId = @"KSBoomarkCellId";
    static NSString * const recentCellReuseId = @"KSRecentCellId";
    static NSString * const loadMoreCellReuseId = @"LoadMoreCellIdentifier";

    NSString *cellReuseId;
    KSButtonCell *cell = nil;
    id cellData;
    
    BOOL isSearching = self.searchField.text.length;
    
    if (indexPath.section == idxNearSection) {
        cellReuseId = nearbyCellReuseId;
        if (!showAllNearBy && indexPath.row == LOADING_CELL_IDX) {

             UITableViewCell *loadMoreCell =[tableView dequeueReusableCellWithIdentifier:loadMoreCellReuseId];
            return loadMoreCell;
        }
        
        if (isSearching) {
            
            cellData = [_searchLocations objectAtIndex:indexPath.row];
        }
        else {
            
            cellData = [_nearestLocations objectAtIndex:indexPath.row];
        }
    }
    else if(indexPath.section == idxFavSection){
        cellReuseId = bookmarkCellReuseId;
        if (!showAllFav && indexPath.row == LOADING_CELL_IDX) {
            
            UITableViewCell *loadMoreCell =[tableView dequeueReusableCellWithIdentifier:loadMoreCellReuseId];
            return loadMoreCell;
        }
        if (isSearching) {
            cellData = [_searchSavedBookmarks objectAtIndex:indexPath.row];
        }
        else {
            cellData = [_savedBookmarks objectAtIndex:indexPath.row];
        }
    }
    else {
        
        cellReuseId = recentCellReuseId;
        if (!showAllRecent && indexPath.row == LOADING_CELL_IDX) {
            
            UITableViewCell *loadMoreCell =[tableView dequeueReusableCellWithIdentifier:loadMoreCellReuseId];
            return loadMoreCell;
        }
        
        if (isSearching) {
            
            cellData = [_searchRecentBookings objectAtIndex:indexPath.row];
        }
        else {
            
            cellData = [_recentBookings objectAtIndex:indexPath.row];
        }
    }

    cell = (KSButtonCell *)[tableView dequeueReusableCellWithIdentifier:cellReuseId forIndexPath:indexPath];
    
    cell.cellData = cellData;
    
    return cell;
}


-(void)reloadCell:(UITableViewCell*)cell
{
UILabel *lbl = (UILabel*) [cell viewWithTag:120];
    
    [lbl sizeToFit];
    //[lbl layoutIfNeeded];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    //
    //        [loadMoreCell setNeedsUpdateConstraints];
    //        [loadMoreCell updateConstraintsIfNeeded];
}
#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    @try {
        
        if (indexPath.section == idxNearSection && showAllNearBy == FALSE && indexPath.row == LOADING_CELL_IDX) {
            showAllNearBy = TRUE;
            [UIView transitionWithView:tableView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void) {
                                [self reloadTableData];
                            } completion:NULL];
            return;
        }
        else if (indexPath.section == idxFavSection && showAllFav == FALSE && indexPath.row == LOADING_CELL_IDX){
        
            showAllFav = TRUE;
            [UIView transitionWithView:tableView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void) {
                                [self reloadTableData];
                            } completion:NULL];
            return;

        }
        else if (indexPath.section == idxRecentSection && showAllRecent == FALSE && indexPath.row == LOADING_CELL_IDX){
            
            showAllRecent = TRUE;
            [UIView transitionWithView:tableView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void) {
                                [self reloadTableData];
                            } completion:NULL];
            return;
            
        }
        
        NSString *placeName = nil;
        CLLocation *location = nil;
        KSBookmark *bookmark;
        KSGeoLocation *geolocation;
        KSTrip *trip;
        NSString *hint = @"";
        
        if (indexPath.section == idxNearSection){
            
            if (!self.searchField.text.length) {
                geolocation = [_nearestLocations objectAtIndex:indexPath.row];
                
                
                
            }
            else {
                geolocation = [_searchLocations objectAtIndex:indexPath.row];
                
                
            }
            placeName = geolocation.address;
            location = [[CLLocation alloc] initWithLatitude:geolocation.latitude.doubleValue longitude:geolocation.longitude.doubleValue];
        }
        else if(indexPath.section == idxFavSection){
        
            if (!self.searchField.text.length) {
            
                bookmark = [_savedBookmarks objectAtIndex:indexPath.row];
            }
            else{
                
                bookmark = [_searchSavedBookmarks objectAtIndex:indexPath.row];
            }
            placeName = bookmark.address.length ? bookmark.address : bookmark.name;
            location = [[CLLocation alloc] initWithLatitude:bookmark.latitude.doubleValue longitude:bookmark.longitude.doubleValue];
        }
        else {
            
            if (!self.searchField.text.length) {
                trip = [_recentBookings objectAtIndex:indexPath.row];
            }
            else {
                trip = [_searchRecentBookings objectAtIndex:indexPath.row];
            }
            
            placeName = trip.dropoffLandmark;
            if (trip.pickupLandmark.length) {
                placeName = trip.pickupLandmark;
                location = [[CLLocation alloc] initWithLatitude:trip.pickupLat.doubleValue longitude:trip.pickupLon.doubleValue];
            }
            else {
                location = [[CLLocation alloc] initWithLatitude:trip.dropOffLat.doubleValue longitude:trip.dropOffLon.doubleValue];
            }
            hint = trip.pickupHint;
        }

        [self.delegate addressPicker:self didDismissWithAddress:placeName location:location hint:hint];

        // Dismiss on selection
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        DLog(@"%@",exception);
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Exception"     // Event category (required)
                                                              action:@"Address Picker didselectedrow"  // Event action (required)
                                                               label:[NSString stringWithFormat:@"indexpath.row = %ld - indexpath.section = %ld",(long)indexPath.row,(long)indexPath.section]         // Event label
                                                               value:nil] build]];    // Event value
        
    }
    
}

#pragma mark -

-(void) searchForQuery:(NSString*)searchString
{
    KSAddressPickerController *me = self;
    //[self showLoadingView];
    [[KSLocationManager instance] placemarksMatchingQuery:searchString country:@"" completion:^(NSArray *placemarks) {
        //[self hideLoadingView];
        _searchLocations = (KSSafeArray*)placemarks;
        
        [self filterFavLocationFortext:searchString];
        [self filterRecentLocationsForText:searchString];
        [me.tableView reloadData];
    }];
}

#pragma mark -
#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSString *searchString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if (textField == self.searchField) {
        
        //[textField resignFirstResponder];
        
        if (textField.text.length > 2) {
            [self searchForQuery:searchString];
            /*KSAddressPickerController *me = self;
            //[self showLoadingView];
            [[KSLocationManager instance] placemarksMatchingQuery:searchString country:@"" completion:^(NSArray *placemarks) {
                //[self hideLoadingView];
                _searchLocations = placemarks;
                
                [self filterFavLocationFortext:searchString];
                [self filterRecentLocationsForText:searchString];
                [me.tableView reloadData];
            }];*/
        }
        return YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.searchField) {

        [textField resignFirstResponder];

        if (textField.text.length > 2) {
           
            //KSAddressPickerController *me = self;
            [self showLoadingView];
            [KSDAL  searchServerwithQuery:[textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                               completion:^(KSAPIStatus status, id response) {
                                   [self hideLoadingView];
                                   if (KSAPIStatusSuccess == status) {
                                        [self searchForQuery:textField.text];
                                   }
                                   else{
                                       [KSAlert show:KSStringFromAPIStatus(status)];
                                   }
                                   
                               }];
             
            /*[[KSLocationManager instance] placemarksMatchingQuery:textField.text country:@"" completion:^(NSArray *placemarks) {
                [self hideLoadingView];
                _searchLocations = placemarks;
                
                [self filterFavLocationFortext:textField.text];
                [self filterRecentLocationsForText:textField.text];
                [me.tableView reloadData];
            }];*/
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    //textField.text = @"";

    [textField resignFirstResponder];
        //[self.tableView reloadData];
    return YES;
}

//- (void)onSearchTextChange:(UITextField *)textField {
//    
//    if (textField == self.searchField) {
//
//        if (!textField.text.length) {
//            if (KSTableViewTypeNearby == self.segmentControl.selectedSegmentIndex) {
//                
//                [self.tableView reloadData];
//            }
//        }
//    }
//}

//#pragma mark -
//#pragma mark - Event handlers
//
//- (IBAction)onSegmentChange:(id)sender {
//    
//    self.tableViewType =  (KSTableViewType)self.segmentControl.selectedSegmentIndex;
//
//    [self.tableView reloadData];
//}


@end
