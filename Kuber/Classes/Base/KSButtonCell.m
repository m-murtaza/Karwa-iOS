//
//  KSButtonCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSButtonCell.h"

NSString * const KSNotificationButtonCellAction = @"KSNotificationButtonCellAction";
NSString * const KSNotificationButtonFavCellAction = @"KSNotificationButtonFavCellAction";
NSString * const KSNotificationButtonUnFavCellAction = @"KSNotificationButtonUnFavCellAction";
NSString * const KSNotificationButtonUnFavBookmarkCellAction = @"KSNotificationButtonUnFavBookmarkCellAction";


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
    
    //Usman: Find this function in extension to increase tap area.
    [button setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    [button addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.accessoryView = button;
}

- (void)onClickButton:(id)sender {
    
    
    /*if(1){
        
        [self setButtonImage:[UIImage imageNamed:@"favorite.png"]];
    }
    else{
        
        [self setButtonImage:[UIImage imageNamed:@"unfavorite.png"]];
    }*/
    [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonCellAction
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:_cellData forKey:@"cellData"]];
}

- (void)setCellData:(id)cellData {
    _cellData = cellData;
}


@end
