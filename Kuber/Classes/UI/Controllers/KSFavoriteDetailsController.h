//
//  KSFavoriteDetailsController.h
//  Kuber
//
//  Created by Asif Kamboh on 6/14/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSViewController.h"

@class KSBookmark;
@class KSGeoLocation;

@interface KSFavoriteDetailsController : KSViewController <UITextFieldDelegate>

@property (nonatomic, copy) NSString *landmark;
@property (nonatomic, strong) KSBookmark *bookmark;
@property (nonatomic, strong) KSGeoLocation *gLocation;

@end
