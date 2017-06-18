//
//  KSBookingHistoryCell.h
//  Kuber
//
//  Created by Asif Kamboh on 6/15/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSTrip;

@interface KSBookingHistoryCell : UITableViewCell

- (void)updateCellData:(KSTrip *)trip;

@end
