//
//  SCPhotoCell.h
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface SCPhotoCell : UICollectionViewCell

@property (nonatomic, weak) UIButton *picBtn;

- (void)fillDataWithAsset:(PHAsset*)asset;

@end
