//
//  KSMenuController.m
//  Kuber
//
//  Created by Asif Kamboh on 5/18/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSMenuController.h"
#import "SWRevealViewController.h"
#import "KSConfirmationAlert.h"

#import "KSDAL.h"

@interface KSMenuController ()

@end

@implementation KSMenuController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickLogout:(id)sender {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 800)];
    controller.view.backgroundColor = [UIColor greenColor];
    UINavigationController *frontController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.revealViewController setFrontViewController:frontController animated:YES];
}

- (void)logoutThisUser {
    [KSDAL logoutUser];

    UIViewController *controller = [UIStoryboard loginRootController];
    [self.revealViewController setFrontViewController:controller animated:YES];
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Logout Decision
    NSUInteger lastRow = [tableView numberOfRowsInSection:0] - 1;
    if (indexPath.row == lastRow) {
        KSConfirmationAlertAction *okAction = [KSConfirmationAlertAction actionWithTitle:@"OK" handler:^(KSConfirmationAlertAction *action) {
            NSLog(@"%s OK Handler", __PRETTY_FUNCTION__);
            [self logoutThisUser];
        }];
        KSConfirmationAlertAction *cancelAction = [KSConfirmationAlertAction actionWithTitle:@"Cancel" handler:^(KSConfirmationAlertAction *action) {
            NSLog(@"%s Cancel Handler", __PRETTY_FUNCTION__);
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        }];
        [KSConfirmationAlert showWithTitle:nil
                                   message:@"Cofirm Logout?"
                                    okAction:okAction
                                cancelAction:cancelAction];
    }
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navController = segue.destinationViewController;

    NSLog(@"%@: %s", [navController.topViewController class], __PRETTY_FUNCTION__);
}


@end
