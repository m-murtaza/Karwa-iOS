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

@end
