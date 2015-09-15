//
//  ViewController.m
//  SCImageManagerDemo
//
//  Created by Aevit on 15/9/15.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import "ViewController.h"
#import "SCImageNavigationController.h"
#import "SCImageBrowser.h"

@interface ViewController () <SCImagePickerDelegate>

@property (nonatomic, strong) SCImageNavigationController *imagePickerNav;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aBtn.frame = CGRectMake(0, 0, 80, 40);
    aBtn.center = self.view.center;
    [aBtn setTitle:@"click" forState:UIControlStateNormal];
    [aBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [aBtn addTarget:self action:@selector(clickBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aBtn];
}

- (void)clickBtnPressed:(id)sender {
    SCImageNavigationController *nav = [[SCImageNavigationController alloc] initWithSCImagePickerControllerDelegate:self];
    [self presentViewController:nav animated:YES completion:nil];
    self.imagePickerNav = nav;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - image picker delegate
- (void)scImagePicker:(SCImagePickerController *)picker didSelectAImage:(UIImage *)aImage {
    SCImageBrowser *browser = [[SCImageBrowser alloc] init];
    browser.image = aImage;
    [self.imagePickerNav pushViewController:browser animated:YES];
    
//    [self.imagePickerNav dismissViewControllerAnimated:YES completion:^{
//        SCImageBrowser *browser = [[SCImageBrowser alloc] init];
//        browser.image = aImage;
//        [self presentViewController:browser animated:YES completion:^{
//            ;
//        }];
//    }];
}


@end
