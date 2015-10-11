//
//  KSBookmarkCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookmarkCell.h"

#import "KSBookmark.h"

@interface KSBookmarkCell()

@property (nonatomic, retain) UILabel *txtLabel;
@property (nonatomic, retain) UILabel *detailTxtLabel;
@end

@implementation KSBookmarkCell

- (void)postInitialize {
    
    UIImage *image = [UIImage imageNamed:@"unfavorite.png"];
    [self setButtonImage:image];
    
    self.txtLabel = (UILabel*)[self viewWithTag:7001];
    [self.txtLabel sizeToFit];
    self.detailTxtLabel = (UILabel*)[self viewWithTag:7002];
    [self.detailTxtLabel sizeToFit];
}

- (void)setCellData:(id)cellData {
    
    [super setCellData:cellData];
        
    if ([cellData isKindOfClass:[KSBookmark class]]) {
        
        KSBookmark *bookmark = (KSBookmark *)cellData;
        self.txtLabel.text = bookmark.name;
        self.detailTxtLabel.text = bookmark.address;
        [self setButtonImage:[UIImage imageNamed:@"favorite.png"]];
    }
}
- (void)onClickButton:(id)sender {
    
    //KSBookmark *bookmark = (KSBookmark*)self.cellData;
    [[NSNotificationCenter defaultCenter] postNotificationName:KSNotificationButtonUnFavBookmarkCellAction
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObject:self.cellData forKey:@"cellData"]];
    
    //TODO catch this notification on table view
    [super onClickButton:sender];
    
}

@end
