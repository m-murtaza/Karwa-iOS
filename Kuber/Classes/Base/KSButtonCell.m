//
//  KSButtonCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSButtonCell.h"

NSString * const KSNotificationButtonCellAction = @"KSNotificationButtonCellAction";

@implementation KSButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self postInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self postInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self postInitialize];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self postInitialize];
    }
    return self;
}

- (void)postInitialize {
    
}

- (void)setButtonImage:(UIImage *)image {
    
    self.accessoryType = UITableViewCellAccessoryDetailButton;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.accessoryView = button;
}

- (void)onClickButton:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonCellAction object:self];
}

- (void)setCellData:(id)cellData {

    _cellData = cellData;
}


@end
