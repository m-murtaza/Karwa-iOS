//
//  KSViewController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/11/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSViewController : UIViewController

@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;

-(void) APICallFailAction:(KSAPIStatus) status;
@end
