//
//  KSConfirmationAlert.h
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSConfirmationAlertAction;

typedef void (^KSConfirmationActionHandler)(KSConfirmationAlertAction *action);

@interface KSConfirmationAlertAction : NSObject
{
    KSConfirmationActionHandler _handler;
}

@property (nonatomic) NSString *title;

- (KSConfirmationActionHandler)handler;

+ (KSConfirmationAlertAction *)actionWithTitle:(NSString *)title handler:(KSConfirmationActionHandler)handler;

@end

@interface KSConfirmationAlert : UIAlertView

+ (void)showWithTitle:(NSString *)title message:(NSString *)message okAction:(KSConfirmationAlertAction *)okAction cancelAction:(KSConfirmationAlertAction *)cancelAction;
+ (void)showWithTitle:(NSString *)title message:(NSString *)message okAction:(KSConfirmationAlertAction *)okAction;

@end
