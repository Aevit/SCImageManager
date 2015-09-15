//
//  SCImageNavigationController.h
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCImageNavigationController.h"
#import "SCImagePickerController.h"

@interface SCImageNavigationController : UINavigationController <SCImagePickerDelegate>

@property (nonatomic, strong) SCImagePickerController *pickerController;

- (instancetype)initWithSCImagePickerControllerDelegate:(id<SCImagePickerDelegate>)delegate;

@end
