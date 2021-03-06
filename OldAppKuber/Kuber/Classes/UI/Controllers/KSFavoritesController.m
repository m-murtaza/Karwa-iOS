//
//  KSFavoritesController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/24/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSFavoritesController.h"
#import "KSLocationManager.h"

#import "KSGeoLocation.h"

#import "KSFavoriteDetailsController.h"
#import "KSButtonCell.h"

@interface KSFavoritesController ()

@property (nonatomic, strong) NSMutableArray *bookmarks;

@property (nonatomic, strong) NSArray *addDeleteBarButtonItems;
@property (nonatomic, strong) NSArray *addOnlyBarButtonItems;

-(IBAction)editTableBtnTapped:(id)sender;

@end

@implementation KSFavoritesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tblIsEditing = FALSE;
    
    
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;

    self.bookmarks = [NSMutableArray array];

    

    UIBarButtonItem *btnAddPlace = self.navigationItem.rightBarButtonItem;
    UIBarButtonItem *btnDeletePlace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onClickDeletePlaces:)];

    self.addOnlyBarButtonItems = @[btnAddPlace];
    self.addDeleteBarButtonItems = @[btnAddPlace, btnDeletePlace];

//    __block KSFavoritesController *me = self;
//    [me showLoadingView];
//    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {
//        [me buildBookmarks];
//        [me hideLoadingView];
//    }];
//
//    [self buildBookmarks];
    
    //[self loadAllData];
    
    

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [KSGoogleAnalytics trackPage:@"Favorites List"];
    
    [self loadAllData];
    
    [KSGoogleAnalytics trackPage:@"Change Password"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFavoriteChangeNotification:) name:KSNotificationForNewBookmark object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unfavBookmarkButtonTapped:)
                                                 name:KSNotificationButtonUnFavBookmarkCellAction
                                               object:nil];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)updateActionButtons {
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    self.navigationItem.rightBarButtonItems = selectedRows.count ? self.addDeleteBarButtonItems : self.addOnlyBarButtonItems;
}

- (void)buildBookmarks {

    KSUser *user = [KSDAL loggedInUser];
    
   /* NSArray *sortedBookmarks = [user.bookmarks.allObjects sortedArrayUsingComparator:^NSComparisonResult(KSBookmark *obj1, KSBookmark *obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];*/

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO];
    NSArray *sortedBookmarks = [user.bookmarks.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return UITableViewCellEditingStyleNone;
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}*/
/*- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}*/
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    NSLog(@"%@",self.bookmarks);
    
    id bmark = [self.bookmarks objectAtIndex:sourceIndexPath.row];
    [self.bookmarks removeObjectAtIndex:sourceIndexPath.row];
    [self.bookmarks insertObject:bmark atIndex:destinationIndexPath.row];
    
    NSInteger destination = destinationIndexPath.row;
    NSInteger source = sourceIndexPath.row;
    
    if(destination < source){
        //Moving upward
        for (NSInteger i = destination; i <= source; i++) {
            //run a loop from destination to source
            NSDictionary *placeData = self.bookmarks[i];
            KSBookmark *bookmark = placeData[@"bookmark"];
            bookmark.sortOrder = [NSNumber numberWithInteger:i+1];
        }
    }
    else{
        //Moving a cell down
        for (NSInteger i = destination; i >= source; i--) {
            //run a loop from destination to source backward
            NSDictionary *placeData = self.bookmarks[i];
            KSBookmark *bookmark = placeData[@"bookmark"];
            bookmark.sortOrder = [NSNumber numberWithInteger:i+1];
        }
    }
    
    [KSDAL updateBookmarksFromTripdata:self.bookmarks];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const placemarkCellReuseId = @"KSBoomarkCellId";
    
    NSDictionary *placeData = self.bookmarks[indexPath.row];
    KSBookmark *bookmark = placeData[@"bookmark"];
    //NSString *landmark = placeData[@"landmark"];

    KSButtonCell *cell = (KSButtonCell*)[tableView dequeueReusableCellWithIdentifier:placemarkCellReuseId forIndexPath:indexPath];

    /*cell.textLabel.text = bookmark.name;
    if (landmark.length) {
        cell.detailTextLabel.text = landmark;
    }*/
    cell.cellData = bookmark;

    return cell;
}

#pragma mark -
#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"segueFavToFavDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

/*- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self updateActionButtons];
}*/




#pragma mark - Notifications 

-(void) unfavBookmarkButtonTapped:(NSNotification*)data
{
    [KSDAL deleteBookmark:[[data userInfo] valueForKey:@"cellData"] completion:^(KSAPIStatus status, id response) {
        if (KSAPIStatusSuccess == status) {
            
            [self loadAllData];
            [self.tableView reloadData];
        }
        else{
            [self APICallFailAction:status];
        }
    }];

}

#pragma mark - Private Method 
-(void) loadAllData {

    __block KSFavoritesController *me = self;
    [me showLoadingView];
    [KSDAL syncBookmarksWithCompletion:^(KSAPIStatus status, NSArray *bookmarks) {
        [me hideLoadingView];
        if (status == KSAPIStatusSuccess) {
            [me buildBookmarks];
            
        }
        else{
            [self APICallFailAction:status];
        }
    }];
    
    [self buildBookmarks];
}


#pragma mark -
#pragma mark - Event handlers

-(IBAction)editTableBtnTapped:(id)sender
{
    tblIsEditing = !tblIsEditing;
    [self.tableView setEditing:tblIsEditing animated:YES];
    [self.tableView reloadData];
    if (tblIsEditing) {
    
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    }
    else{
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    }
}

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
            [self APICallFailAction:status];
        }
    }];
}

- (void)onFavoriteChangeNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildBookmarks];
    });
}

@end
