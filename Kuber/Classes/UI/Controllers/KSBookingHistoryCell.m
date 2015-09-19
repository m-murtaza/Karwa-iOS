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

@property (nonatomic, strong) IBOutlet KSLabel *lblPickupFrom;
@property (nonatomic, strong) IBOutlet KSLabel *lblDropoffTo;
@property (nonatomic, strong) IBOutlet KSLabel *lblDate;
@property (nonatomic, strong) IBOutlet KSLabel *lblTime;


@end

@implementation KSBookingHistoryCell

- (void)awakeFromNib {
    // Initialization code
    self.lblPickupFrom.font = [UIFont fontWithName:@"MuseoForDell-500" size:17];
    [self.lblDropoffTo setFontSize:13];
    [self.lblTime setFontSize:12];
    [self.lblDate setFontSize:12];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellData:(KSTrip *)trip {
    
    
    if (trip.pickupLandmark.length) {
        self.lblPickupFrom.text = [NSString stringWithFormat:@"%@", trip.pickupLandmark];
    }
    else {
        NSString *loc = KSStringFromLatLng(trip.pickupLat.doubleValue, trip.pickupLon.doubleValue);
        self.lblPickupFrom.text = [NSString stringWithFormat:@"%@", loc];
    }

    self.lblDropoffTo.text = @"";
    if (trip.dropoffLandmark.length) {
        self.lblDropoffTo.text = [NSString stringWithFormat:@"%@", trip.dropoffLandmark];
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
    [formatter setDateFormat:@"hh:mm a"];
    fTime = [formatter stringFromDate:date];
    
    return fTime;
}

@end
