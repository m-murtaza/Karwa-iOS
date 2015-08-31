//
//  KSGeoLocationCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSGeoLocationCell.h"

#import "KSGeoLocation.h"
#import "KSTrip.h"

@implementation KSGeoLocationCell

- (void)postInitialize {

    UIImage *image = [UIImage imageNamed:@"favorite.png"];
    [self setButtonImage:image];
}

- (void)setCellData:(id)cellData {
    
    [super setCellData:cellData];

    if ([cellData isKindOfClass:[KSGeoLocation class]]) {
        
        KSGeoLocation *location = (KSGeoLocation *)cellData;
        self.textLabel.text = location.address;
        self.detailTextLabel.text = location.area;
        
        if (location.geoLocationToBookmark) {
        
            [self setButtonImage:[UIImage imageNamed:@"favorite.png"]];
        }
        else{
        
            [self setButtonImage:[UIImage imageNamed:@"unfavorite.png"]];
        }
    }
    else if ([cellData isKindOfClass:[KSTrip class]]) {
        
        KSTrip *trip = (KSTrip *)cellData;
        
        NSString *address = trip.dropoffLandmark;
        if (trip.pickupLandmark.length) {
            
            address = trip.pickupLandmark;
        }

        NSString *subtitle = nil;
        const int wordbreak = 35;
        if (address.length > wordbreak) {
            NSRange spaceRange = [address rangeOfString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(wordbreak, address.length - wordbreak)];
            if (spaceRange.location != NSNotFound) {
                NSString *temp = address;
                address = [address substringToIndex:spaceRange.location];
                subtitle = [temp substringWithRange:NSMakeRange(0, wordbreak)];
            }
        }
        self.textLabel.text = address;
        self.detailTextLabel.text = subtitle;
    }
}


- (void)onClickButton:(id)sender {

    KSGeoLocation *location = (KSGeoLocation *)self.cellData;
    
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
    }
    [super onClickButton:sender];
    
}
@end
