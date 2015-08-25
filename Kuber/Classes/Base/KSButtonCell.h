//
//  KSButtonCell.h
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const KSNotificationButtonCellAction;

@interface KSButtonCell : UITableViewCell

@property (nonatomic, weak) id cellData;

- (void)setButtonImage:(UIImage *)image;

- (void)postInitialize;

@end