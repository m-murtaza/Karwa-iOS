//
//  KSDatePicker.m
//  Kuber
//
//  Created by Asif Kamboh on 8/10/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSDatePicker.h"

@interface KSDatePicker ()

@end


@implementation KSDatePicker

- (instancetype)init {
    
    const CGFloat pickerHeight = 216;
    const CGFloat toolbarHeight = 44.0;
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, pickerHeight + toolbarHeight);

    
    
    self = [self initWithFrame:frame];

    if (self) {
    
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat width = self.bounds.size.width;

        _picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, toolbarHeight, width, pickerHeight)];

        [_picker addTarget:self action:@selector(onDateChange:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_picker];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, toolbarHeight)];

        UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickDone:)];

        btnDone.tintColor = [UIColor colorWithRed:27.0 / 255.0
                                            green:179.0 / 255.0
                                             blue:179.0 / 255.0
                                            alpha:1.0];
        
        [btnDone setTitleTextAttributes:@{
                                             NSFontAttributeName: [UIFont fontWithName:@"MuseoForDell-300" size:20.0]
                                             
                                             } forState:UIControlStateNormal];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:NULL];

        toolbar.items = [NSArray arrayWithObjects:flexSpace, btnDone, nil];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        
        [self addSubview:toolbar];
    }

    return self;
}

#pragma mark -
#pragma mark - Event Handlers

- (void)onDateChange:(id)sender {

    if ([self.delegate respondsToSelector:@selector(datePicker:didChangeDate:)]) {
        
        [self.delegate datePicker:self didChangeDate:self.date];
    }
}

- (void)onClickDone:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(datePicker:didPickDate:)]) {

        [self.delegate datePicker:self didPickDate:self.date];
    }
    
    [_picker resignFirstResponder];
    [self resignFirstResponder];
}

#pragma mark - 
#pragma mark - UIDatePicker wrapper

- (NSDate *)date {
    
    return _picker.date;
}

- (void)setMinimumDate:(NSDate *)date {

    _picker.minimumDate = date;
}

- (void)setMaximumDate:(NSDate *)date {
    
    _picker.maximumDate = date;
}

- (void)setDatePickerMode:(UIDatePickerMode)mode {
    
    _picker.datePickerMode = mode;
}

@end
