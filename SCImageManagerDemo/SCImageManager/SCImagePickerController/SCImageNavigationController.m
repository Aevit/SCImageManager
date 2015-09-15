//
//  SCImageNavigationController.m
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import "SCImageNavigationController.h"

@interface SCImageNavigationController () {
    
    UIStatusBarStyle _preStatusBarStyle;
    UIColor *_preTintColor;
}

@end

@implementation SCImageNavigationController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithSCImagePickerControllerDelegate:(id<SCImagePickerDelegate>)delegate {
    SCImagePickerController *con = [[SCImagePickerController alloc] initWithDelegate:delegate];
    self = [super initWithRootViewController:con];
    if (self) {
        con.delegate = delegate;
        self.pickerController = con;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.navigationBar.barTintColor = [UIColor colorWithRed:20 / 255.0 green:20 / 255.0 blue:20 / 255.0 alpha:1];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    _preTintColor = [UINavigationBar appearance].tintColor;
    _preStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // make sure that have added "View controller-based status bar appearance" in the "info.plist"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UINavigationBar appearance] setTintColor:_preTintColor];
    [[UIApplication sharedApplication] setStatusBarStyle:_preStatusBarStyle animated:animated];
    [super viewWillDisappear:animated];
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
