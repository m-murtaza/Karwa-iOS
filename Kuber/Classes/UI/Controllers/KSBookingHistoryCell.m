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
@property (nonatomic, strong) IBOutlet UILabel *lblTime;


@end

@implementation KSBookingHistoryCell

- (void)awakeFromNib {
    // Initialization code
    self.lblPickupFrom.font = [UIFont fontWithName:@"MuseoForDell-500" size:17];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellData:(KSTrip *)trip {

    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *date = [dateFormatter stringFromDate:trip.pickupTime];
     */
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
    NSString *date = [self formatedDate:trip.pickupTime];
    if (date) {
        
        self.lblDate.text =  date;
    }
    
    self.lblTime.text = @"";
    NSString *time = [self formatedTime:trip.pickupTime];
    if (time) {
        
        self.lblTime.text = time;
    }
}

-(NSString*) formatedDate:(NSDate*)date
{
    NSString *fDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE d MMM, YYYY"];
    fDate = [formatter stringFromDate:date];
    
    return fDate;
}

-(NSString*) formatedTime:(NSDate*)date
{
    NSString *fTime;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    fTime = [formatter stringFromDate:date];
    
    return fTime;
}

@end
