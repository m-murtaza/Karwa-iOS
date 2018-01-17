//
//  KSBaseRevealViewRightControllerViewController.m
//  Kuber
//
//  Created by Muhammad Usman on 1/2/18.
//  Copyright © 2018 Karwa Solutions. All rights reserved.
//

#import "KSBaseRevealViewRightControllerViewController.h"

@interface KSBaseRevealViewRightControllerViewController ()

@end

@implementation KSBaseRevealViewRightControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupRevealViewController];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self addPanGestureForRevealView];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self removePanGestureForRevealView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
