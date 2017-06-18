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

@property (nonatomic, weak) IBOutlet KSLabel *lblPickupFrom;
@property (nonatomic, weak) IBOutlet KSLabel *lblDropoffTo;
@property (nonatomic, weak) IBOutlet KSLabel *lblDate;
@property (nonatomic, weak) IBOutlet KSLabel *lblTime;
@property (nonatomic, weak) IBOutlet UIImageView *imgStatus;
@property (nonatomic, weak) IBOutlet UIImageView *imgVehicleType;
//@property (nonatomic, weak) IBOutlet UIImageView *imgVehicleTypeRateYourTrip;


@end

@implementation KSBookingHistoryCell

/*- (void)awakeFromNib {
    // Initialization code
    //self.lblPickupFrom.font = [UIFont fontWithName:@"MuseoForDell-500" size:17];
    //[self.lblDropoffTo setFontSize:13];
    //[self.lblTime setFontSize:12];
    //[self.lblDate setFontSize:12];
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateCellData:(KSTrip *)trip {
    
    if (trip.pickupLandmark.length) {
        self.lblPickupFrom.text = [NSString stringWithString:trip.pickupLandmark]; //[NSString stringWithFormat:@"%@, %@",trip.pickupHint, trip.pickupLandmark];        //removed after discussion with shadab bahi.
    }
    else if (trip.pickupHint){
        
        self.lblPickupFrom.text = [NSString stringWithFormat:@"%@",trip.pickupHint];
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
    
    [self setStatusImage:trip];
    
    [self setVehicleTypeImage:(KSVehicleType)[trip.vehicleType intValue]];
}

-(void) setVehicleTypeImage:(KSVehicleType) type
{
    switch (type) {
        case KSCityTaxi:
            [self.imgVehicleType setImage:[UIImage imageNamed:@"history-taxi-ico.png"]];
            break;
        case KSStandardLimo:
            [self.imgVehicleType setImage:[UIImage imageNamed:@"history-standard-limo-ico.png"]];
            break;
        case KSBusinessLimo:
            [self.imgVehicleType setImage:[UIImage imageNamed:@"history-business-limo-ico.png"]];
            break;
        case KSLuxuryLimo:
            [self.imgVehicleType setImage:[UIImage imageNamed:@"history-luxury-limo-ico.png"]];
            break;
        default:
            [self.imgVehicleType setImage:[UIImage imageNamed:@"history-taxi-ico.png"]];
            break;
    }
    
}

-(void) setStatusImage:(KSTrip*)trip
{
    NSInteger status = [trip.status integerValue];
    [self.imgStatus setHidden:FALSE];
    
    switch (status) {
        case KSTripStatusOpen:
            [self.imgStatus setImage:[UIImage imageNamed:@"scheduled-tag.png"]];
            break;
        case KSTripStatusInProcess:
        case KSTripStatusManuallyAssigned:
        case KSTripStatusPassengerInTaxi:
            [self.imgStatus setImage:[UIImage imageNamed:@"in-process-tag.png"]];
            break;
        case KSTripStatusTaxiAssigned:
            [self.imgStatus setImage:[UIImage imageNamed:@"confirmed-tag.png"]];
            break;
        case KSTripStatusCancelled:
            [self.imgStatus setImage:[UIImage imageNamed:@"cancelled-tag.png"]];
            break;
        case KSTripStatusTaxiNotFound:
            [self.imgStatus setImage:[UIImage imageNamed:@"taxi-unavailable-tag.png"]];
            break;
        case KSTripStatusComplete:
            [self.imgStatus setImage:[UIImage imageNamed:@"completed-tag.png"]];
            break;
        default:
            [self.imgStatus setHidden:TRUE];
            break;
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
