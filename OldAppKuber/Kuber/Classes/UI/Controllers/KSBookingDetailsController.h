//
//  KSBookingDetailsController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/2/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

@class KSTrip;

@interface KSBookingDetailsController : KSViewController

@property (nonatomic, strong) KSTrip *tripInfo;
@property (nonatomic) BOOL showsAcknowledgement;
@property (nonatomic) BOOL isOpenedFromPushNotification;


-(IBAction)btnCancelTapped:(id)sender;

@end
