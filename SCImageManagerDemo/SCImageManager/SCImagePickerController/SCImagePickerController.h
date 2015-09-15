//
//  SCImagePickerController.h
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class SCImagePickerController;

@protocol SCImagePickerDelegate <NSObject>
@optional
- (void)scImagePicker:(SCImagePickerController*)picker didSelectAImage:(UIImage*)aImage;

@end

@interface SCImagePickerController : UIViewController


@property (nonatomic, weak) IBOutlet id<SCImagePickerDelegate> delegate;

- (id)initWithDelegate:(id <SCImagePickerDelegate>)delegate;

+ (void)requestAImageFromAsset:(PHAsset*)asset targetSize:(CGSize)targetSize resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler;

@end
