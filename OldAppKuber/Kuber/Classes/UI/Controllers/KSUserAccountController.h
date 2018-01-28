//
//  KSUserAccountController.h
//  Kuber
//
//  Created by Asif Kamboh on 5/21/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSBaseRevealViewRightControllerViewController.h"
#import "KSUITextFieldInCell.h"

@interface KSUserAccountController : KSBaseRevealViewRightControllerViewController  <UITableViewDelegate,UITableViewDelegate,UITextFieldDelegate>
{
    KSUser *user;
    //KSUITextFieldInCell *txtName;
    //KSUITextFieldInCell *txtEmail;
    
}

@end
