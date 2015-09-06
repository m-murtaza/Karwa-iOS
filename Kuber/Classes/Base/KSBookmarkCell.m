//
//  KSBookmarkCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookmarkCell.h"

#import "KSBookmark.h"

@implementation KSBookmarkCell

- (void)postInitialize {
    
    UIImage *image = [UIImage imageNamed:@"unfavorite.png"];
    [self setButtonImage:image];
}

- (void)setCellData:(id)cellData {
    
    [super setCellData:cellData];
    
    if ([cellData isKindOfClass:[KSBookmark class]]) {
        
        KSBookmark *bookmark = (KSBookmark *)cellData;
        self.textLabel.text = bookmark.name;
        self.detailTextLabel.text = bookmark.address;
        [self setButtonImage:[UIImage imageNamed:@"favorite.png"]];
    }
}
- (void)onClickButton:(id)sender {
    
    /*KSGeoLocation *location = (KSGeoLocation *)((KSBookmark*)self.cellData).bookmarkToGeoLocation;
    
    //These check are inverse as we need to un fav is cell is already fav
    if (location.geoLocationToBookmark) {
        
        [self setButtonImage:[UIImage imageNamed:@"unfavorite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonUnFavCellAction
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:self.cellData forKey:@"cellData"]];
    }
    else{
        
        [self setButtonImage:[UIImage imageNamed:@"favorite.png"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonFavCellAction
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:self.cellData forKey:@"cellData"]];
    }*/
    
    //KSBookmark *bookmark = (KSBookmark*)self.cellData;
    [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonUnFavBookmarkCellAction
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self.cellData forKey:@"cellData"]];
    
    //TODO catch this notification on table view
    [super onClickButton:sender];
    
}

@end
