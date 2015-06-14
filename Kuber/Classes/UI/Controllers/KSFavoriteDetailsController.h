//
//  KSFavoriteDetailsController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

@class KSBookmark;

@interface KSFavoriteDetailsController : KSViewController

@property (nonatomic, copy) NSString *landmark;
@property (nonatomic, strong) KSBookmark *bookmark;

@end
