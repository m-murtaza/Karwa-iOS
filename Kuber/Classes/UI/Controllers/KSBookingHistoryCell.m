//
//  KSBookingHistoryCell.m
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookingHistoryCell.h"

#import "KSTrip.h"

@interface KSBookingHistoryCell ()

@property (nonatomic, strong) IBOutlet UILabel *lblPickupFrom;
@property (nonatomic, strong) IBOutlet UILabel *lblDropoffTo;
@property (nonatomic, strong) IBOutlet UILabel *lblDate;

@end

@implementation KSBookingHistoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellData:(KSTrip *)trip {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *date = [dateFormatter stringFromDate:trip.pickupTime];

    if (trip.pickupLandmark.length) {
        self.lblPickupFrom.text = [NSString stringWithFormat:@"From %@", trip.pickupLandmark];
    }
    else {
        NSString *loc = KSStringFromLatLng(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue);
        self.lblPickupFrom.text = [NSString stringWithFormat:@"From %@", loc];
    }

    self.lblDropoffTo.text = @"";
    if (trip.dropoffLandmark.length) {
        self.lblDropoffTo.text = [NSString stringWithFormat:@"to %@", trip.dropoffLandmark];
    }
    self.lblDate.text = @"";
    if (date) {
        self.lblDate.text = [NSString stringWithFormat:@"on %@", date];
    }
}

@end
