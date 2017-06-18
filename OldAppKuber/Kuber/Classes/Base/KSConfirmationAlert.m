//
//  KSConfirmationAlert.m
//  Kuber
//
//  Created by Asif Kamboh on 5/19/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSConfirmationAlert.h"
#import "AppDelegate.h"

@implementation KSConfirmationAlertAction

+ (KSConfirmationAlertAction *)actionWithTitle:(NSString *)title handler:(KSConfirmationActionHandler)handler {
    KSConfirmationAlertAction *action = [[KSConfirmationAlertAction alloc] init];
    action.title = title;
    action->_handler = handler;
    return action;
}

- (KSConfirmationActionHandler)handler {
    return _handler;
}

@end

@interface KSConfirmationAlert ()<UIAlertViewDelegate>

@property (nonatomic) KSConfirmationAlertAction *okAction;
@property (nonatomic) KSConfirmationAlertAction *cancelAction;

@end

@implementation KSConfirmationAlert

+ (void)showWithTitle:(NSString *)title message:(NSString *)message okAction:(KSConfirmationAlertAction *)okAction cancelAction:(KSConfirmationAlertAction *)cancelAction {

    /*if (!okAction || !okAction.title.length) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                reason:@"You MUST provide okAction with title"
                              userInfo:@{}] raise];
        return;
    }
    if (!cancelAction || !cancelAction.title.length) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"You MUST provide cancelAction with title"
                               userInfo:@{}] raise];
        return;
    }

    KSConfirmationAlert *alertView = [[KSConfirmationAlert alloc] initWithTitle:title
                                                                            message:message
                                                                           okAction:okAction
                                                                       cancelAction:cancelAction];
    [alertView show];*/
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (!okAction || !okAction.title.length) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"You MUST provide okAction with title"
                               userInfo:@{}] raise];
        return;
    }
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* altOKAction = [UIAlertAction actionWithTitle:okAction.title
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              okAction.handler(okAction);
                                                          }];
    [alt addAction:altOKAction];
    
    
    if (cancelAction && cancelAction.title) {
        UIAlertAction *altCancelAction = [UIAlertAction actionWithTitle:cancelAction.title
                                                                  style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                                      cancelAction.handler(cancelAction);
                                                                  }];
        [alt addAction:altCancelAction];
    }
    [appDelegate.window.rootViewController presentViewController:alt animated:YES completion:nil];
    
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message okAction:(KSConfirmationAlertAction *)okAction {
    
    /*if (!okAction || !okAction.title.length) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"You MUST provide okAction with title"
                               userInfo:@{}] raise];
        return;
    }
    
    KSConfirmationAlert *alertView = [[KSConfirmationAlert alloc] initWithTitle:title
                                                                        message:message
                                                                       okAction:okAction
                                                                   cancelAction:nil];
    [alertView show];*/
    
    [KSConfirmationAlert showWithTitle:title
                               message:message
                              okAction:okAction
                          cancelAction:nil];
    
    
    
}

/*- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message okAction:(KSConfirmationAlertAction *)okAction cancelAction:(KSConfirmationAlertAction *)cancelAction {

    self = [super initWithTitle:title message:message delegate:nil cancelButtonTitle:okAction.title.localizedValue otherButtonTitles:cancelAction.title.localizedValue, nil];
    if (self) {
        self.okAction = okAction;
        self.cancelAction = cancelAction;
        self.delegate = self;
    }
    return self;
    
}*/

#pragma mark -
#pragma mark - Alert view delegate

/*- (void)alertView:(KSConfirmationAlert *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        if (alertView.okAction.handler) {
            alertView.okAction.handler(alertView.okAction);
        }
    }
    else if (buttonIndex == 1) {
        if (alertView.cancelAction.handler) {
            alertView.cancelAction.handler(alertView.cancelAction);
        }
    }
    alertView.delegate = nil;
}

- (void)alertViewCancel:(KSConfirmationAlert *)alertView {
    alertView.delegate = nil;
}*/

@end
