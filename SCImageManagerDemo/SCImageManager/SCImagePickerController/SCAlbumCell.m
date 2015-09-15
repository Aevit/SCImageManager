//
//  SCAlbumCell.m
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import "SCAlbumCell.h"

@interface SCAlbumCell() {
    
}

@end

@implementation SCAlbumCell
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // init code here
}
@end
