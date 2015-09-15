//
//  SCImagePickerController.m
//  SCImageBrowser
//
//  Created by Aevit on 15/9/8.
//  Copyright (c) 2015年 Aevit. All rights reserved.
//

#import "SCImagePickerController.h"
#import "SCPhotoCell.h"
#import "SCAlbumCell.h"
#import "SVProgressHUD.h"

// iOS 8.0，苹果去掉了“Camera Roll”这个相册，所以读取“全部照片”会有问题，这里的解决方法是当“全部照片”读取不到时，就读取“最近添加”这个相册，并将此相册排在最上面
#define LOAD_ALBUMS_IN_VIEWDIDLOAD  1

static CGFloat bottomViewHeight = 49;
static int bottomBtnNum = 2;
static int bottomBtnTag = 100;

static NSString *assetCellId = @"assetCellId";
static NSString *albumCellId = @"albumCellId";

@interface SCImagePickerController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    UIButton *_rightBtn;
    
    NSInteger _currAlbumIndex;
    NSInteger _cameraRollAlbumIndex;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *tableBgBtn;
@property (nonatomic, strong) NSMutableArray *albumsArr;

@end

@implementation SCImagePickerController

#pragma mark - Init

- (instancetype)init {
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithDelegate:(id <SCImagePickerDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
    }
    return self;
}

- (void)commonInit {
    // do the common init
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    _currAlbumIndex = 0;
    _cameraRollAlbumIndex = -1;
}

#pragma mark - View Loading
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"全部照片";
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.navigationController && [self.navigationController isKindOfClass:NSClassFromString(@"SCImageNavigationController")]) {
        [self configureNavigation];
    }
    [self addCollectionView];
//    [self addBottomView];
    
    [self willLoadFromAlbum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigation {
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 44, 44);
    [leftBtn setImage:[UIImage imageNamed:@"sc_close"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBarBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn setImage:[UIImage imageNamed:@"sc_album_down"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBarBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)leftBarBtnPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarBtnPressed:(UIButton*)sender {
    
    [self buildAlbumTableAndData];
    
    _rightBtn.selected = !_rightBtn.selected;
    [self toShowAlbumTable:_rightBtn.selected];
}

- (void)buildAlbumTableAndData {
    if (!_tableView) {
#if LOAD_ALBUMS_IN_VIEWDIDLOAD
        CGFloat tableY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
#else
        CGFloat tableY = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
#endif
        UITableView *aTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, self.view.frame.size.width, 0) style:UITableViewStylePlain];
        aTable.backgroundColor = [UIColor whiteColor];
        aTable.delegate = self;
        aTable.dataSource = self;
        aTable.tableFooterView = [UIView new];
        [aTable registerClass:[SCAlbumCell class] forCellReuseIdentifier:albumCellId];
        aTable.estimatedRowHeight = 44;
        [self.view addSubview:aTable];
        self.tableView = aTable;
        
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aBtn.frame = self.view.bounds;
        aBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        aBtn.alpha = 0;
        [aBtn addTarget:self action:@selector(rightBarBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:aBtn belowSubview:aTable];
        self.tableBgBtn = aBtn;
    }
    if (!_albumsArr) {
        _albumsArr = [NSMutableArray array];
        [self loadAlbums];
    }
}

- (void)toShowAlbumTable:(BOOL)toShow {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        // table
        CGRect frame = _tableView.frame;
        frame.size.height = (toShow ? MIN(_tableView.estimatedRowHeight * _albumsArr.count, 350) : 0);
        _tableView.frame = frame;
        
        // table bg button
        _tableBgBtn.alpha = (toShow ? 1 : 0);
        
        // rotate right button
        _rightBtn.transform = CGAffineTransformMakeRotation((toShow ? M_PI : 0));
        
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)addCollectionView {
    if (_photoCollectionView) {
        return;
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *aCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (_bottomView ? bottomViewHeight : 0)) collectionViewLayout:layout];
    aCollectionView.backgroundColor = [UIColor blackColor];
    aCollectionView.delegate = self;
    aCollectionView.dataSource = self;
    
    [aCollectionView registerClass:[SCPhotoCell class] forCellWithReuseIdentifier:assetCellId];
    
    [self.view addSubview:aCollectionView];
    self.photoCollectionView = aCollectionView;
}

- (void)addBottomView {
    if (_bottomView) {
        return;
    }
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -bottomViewHeight, self.view.frame.size.width, bottomViewHeight)];
    aView.backgroundColor = [UIColor whiteColor];
    
    NSArray *btnNormalImgStrArr = @[@"sc_photo", @"sc_cam"];
    NSArray *btnHLImgStrArr = @[@"sc_photo_h", @"sc_cam_h"];
    CGFloat btnWidth = self.view.frame.size.width / bottomBtnNum;
    for (int i = 0; i < bottomBtnNum; i++) {
        UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        aBtn.frame = CGRectMake(i * btnWidth, 0, btnWidth, bottomViewHeight);
        aBtn.backgroundColor = [UIColor clearColor];
        [aBtn setImage:[UIImage imageNamed:btnNormalImgStrArr[i]] forState:UIControlStateNormal];
        [aBtn setImage:[UIImage imageNamed:btnHLImgStrArr[i]] forState:UIControlStateHighlighted];
        [aBtn setImage:[UIImage imageNamed:btnHLImgStrArr[i]] forState:UIControlStateSelected];
        [aBtn addTarget:self action:@selector(bottomBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            aBtn.selected = YES;
        }
        aBtn.tag = bottomBtnTag + i;
        [aView addSubview:aBtn];
    }
    [self.view addSubview:aView];
    self.bottomView = aView;
}

- (void)bottomBtnPressed:(UIButton*)sender {
    switch (sender.tag - bottomBtnTag) {
        case 0:
        {
            break;
        }
        case 1:
        {
            [self showCamera];
            break;
        }
        default:
            break;
    }
}

#pragma mark - imagepicker
- (void)showCamera {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [SVProgressHUD showWithStatus:@"saving..."];
    [self performSelector:@selector(saveImage:) withObject:image afterDelay:0.35];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (error != nil) {
        [SVProgressHUD showErrorWithStatus:@"saved failer..."];
//        NSLog(@"save image fail: %@", error);
    } else {
        [SVProgressHUD showSuccessWithStatus:@"saved success"];
        [self loadFromAlbum:(PHAssetCollection*)(_albumsArr[_currAlbumIndex])];
    }
}

#pragma mark - Album
- (void)willLoadFromAlbum {
    
    // Check library permissions
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
#if LOAD_ALBUMS_IN_VIEWDIDLOAD
                [self buildAlbumTableAndData];
                if ([_albumsArr count] > 0) {
                    [self loadFromAlbum:_albumsArr[0]];
                }
#else
                [self loadFromAlbum:nil];
#endif
            }
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
#if LOAD_ALBUMS_IN_VIEWDIDLOAD
        [self buildAlbumTableAndData];
        if ([_albumsArr count] > 0) {
            [self loadFromAlbum:_albumsArr[0]];
        }
#else
        [self loadFromAlbum:nil];
#endif
    } else if (status == PHAuthorizationStatusDenied) {
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *msg = [NSString stringWithFormat:@"请前往“设置-隐私-照片-%@”，将右边开关打开", appName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)loadFromAlbum:(PHAssetCollection*)collection {
    
    if (_currAlbumIndex >= 0) {
        self.title = [self formatAlbumTitle:collection.localizedTitle indexRow:_currAlbumIndex];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *fetchResults = nil;
        
        if (collection == nil) {
            fetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        } else {
            fetchResults = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        }
        
        [_assets removeAllObjects];
        [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_assets addObject:obj];
        }];
        
//        if (fetchResults.count > 0) {
            [_photoCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//        }
    });
}

- (void)loadAlbums {
    if (_albumsArr) {
        [_albumsArr removeAllObjects];
    }
    
    // why the code below not work?
//    PHFetchOptions *smartOptions = [PHFetchOptions new];
//    smartOptions.predicate = [NSPredicate predicateWithFormat:@"assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumFavorites"];
    
    NSArray *albumSubTypes = @[
                               @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                               @(PHAssetCollectionSubtypeSmartAlbumPanoramas),
                               @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                               @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded)
                               ];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    __block NSInteger recentlyAddAlbumIndex = -1; // make index of recentlyAddAlbum next to camera roll
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        if ([albumSubTypes containsObject:@(collection.assetCollectionSubtype)]) {
            [_albumsArr addObject:collection];
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                _cameraRollAlbumIndex = _albumsArr.count - 1;
            } else if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded) {
                recentlyAddAlbumIndex = _albumsArr.count - 1;
            }
        }
    }];
    
    // why the code below not work?
//    PHFetchOptions *userOptions = [PHFetchOptions new];
//    userOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [topLevelUserCollections enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        if (collection.estimatedAssetCount > 0) {
            [_albumsArr addObject:collection];
        }
    }];
    
    if (_albumsArr.count > 0) {
        if (_cameraRollAlbumIndex > 0) {
            [_albumsArr exchangeObjectAtIndex:0 withObjectAtIndex:_cameraRollAlbumIndex];
            _cameraRollAlbumIndex = 0;
        }
        if (recentlyAddAlbumIndex > 0) {
            [_albumsArr exchangeObjectAtIndex:_cameraRollAlbumIndex + 1 withObjectAtIndex:recentlyAddAlbumIndex];
        }
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_assets count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SCPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:assetCellId forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        [cell.picBtn setImage:[UIImage imageNamed:@"sc_cam_h"] forState:UIControlStateNormal];
        cell.backgroundColor = [UIColor lightGrayColor];
        return cell;
    }
    cell.backgroundColor = [UIColor blackColor];
    [cell fillDataWithAsset:_assets[indexPath.row - 1]];
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.frame.size.width - 5) / 4, (self.view.frame.size.width - 5) / 4);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showCamera];
        return;
    }
    
    [SCImagePickerController requestAImageFromAsset:(PHAsset*)_assets[indexPath.row - 1] targetSize:CGSizeZero resultHandler:^(UIImage *result, NSDictionary *info) {
        if ([_delegate respondsToSelector:@selector(scImagePicker:didSelectAImage:)]) {
            [_delegate scImagePicker:self didSelectAImage:result];
        }
    }];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albumsArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SCAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:albumCellId];
    
    PHAssetCollection *collection = _albumsArr[indexPath.row];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSString *title = [self formatAlbumTitle:collection.localizedTitle indexRow:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%lu）", title, (unsigned long)fetchResult.count];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *collection = _albumsArr[indexPath.row];
    _currAlbumIndex = indexPath.row;
    
    [self loadFromAlbum:collection];
    
    [_rightBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (NSString*)formatAlbumTitle:(NSString*)albumTitle indexRow:(NSUInteger)row {
    if (_cameraRollAlbumIndex < 0) {
        return albumTitle;
    }
    return (_cameraRollAlbumIndex == row ? @"全部照片" : albumTitle);
}

#pragma mark - helper
+ (void)requestAImageFromAsset:(PHAsset*)asset targetSize:(CGSize)targetSize resultHandler:(void (^)(UIImage *result, NSDictionary *info))resultHandler {
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
    };
    
    if (CGSizeEqualToSize(targetSize, CGSizeZero)) {
        targetSize = PHImageManagerMaximumSize;
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:resultHandler];
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
