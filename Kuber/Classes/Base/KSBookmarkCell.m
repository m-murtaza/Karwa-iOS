//
//  KSBookmarkCell.m
//  Kuber
//
//  Created by Asif Kamboh on 8/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBookmarkCell.h"

#import "KSBookmark.h"

@implementation KSBookmarkCell

- (void)postInitialize {
    
    UIImage *image = [UIImage imageNamed:@"unfavorite.png"];
    [self setButtonImage:image];
}

- (void)setCellData:(id)cellData {
    
    [super setCellData:cellData];
    
    if ([cellData isKindOfClass:[KSBookmark class]]) {
        
        KSBookmark *bookmark = (KSBookmark *)cellData;
        self.textLabel.text = bookmark.name;
        self.detailTextLabel.text = bookmark.address;
    }
}


@end
