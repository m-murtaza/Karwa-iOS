//
//  KSDatePicker.h
//  Kuber
//
//  Created by Asif Kamboh on 8/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KSDatePickerDelegate;

@interface KSDatePicker : UIView

@property (nonatomic, strong, readonly) UIDatePicker *picker;

@property (nonatomic, weak) id<KSDatePickerDelegate> delegate;

- (NSDate *)date;

- (void)setMinimumDate:(NSDate *)date;

- (void)setMaximumDate:(NSDate *)date;

- (void)setDatePickerMode:(UIDatePickerMode)mode;

@end

@protocol KSDatePickerDelegate <NSObject>

@optional

- (void)datePicker:(KSDatePicker *)picker didPickDate:(NSDate *)date;

- (void)datePicker:(KSDatePicker *)picker didChangeDate:(NSDate *)date;

@end
