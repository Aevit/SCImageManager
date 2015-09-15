//
//  SCPhotoCell.m
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import "SCPhotoCell.h"
#import "SCImagePickerController.h"

@interface SCPhotoCell() {
}

@end

@implementation SCPhotoCell

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // init code here
    if (!_picBtn) {
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.picBtn = aBtn;
        _picBtn.frame = self.bounds;
        _picBtn.userInteractionEnabled = NO;
        _picBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_picBtn];
    }
}

- (void)prepareForReuse {
    if (_picBtn) {
        [_picBtn setImage:nil forState:UIControlStateNormal];
    }
    [super prepareForReuse];
}

- (void)fillDataWithAsset:(PHAsset*)asset {
    
    if (!asset) {
        return;
    }
    
    CGFloat imageWidth = [UIScreen mainScreen].scale * _picBtn.frame.size.width;
    [SCImagePickerController requestAImageFromAsset:asset targetSize:CGSizeMake(imageWidth, imageWidth) resultHandler:^(UIImage *result, NSDictionary *info) {
        [_picBtn setImage:result forState:UIControlStateNormal];
    }];
}

@end
