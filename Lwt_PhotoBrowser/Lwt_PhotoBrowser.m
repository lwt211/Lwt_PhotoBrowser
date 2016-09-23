//
//  Lwt_PhotoBrowser.m
//  PhotoBrowserDemo
//
//  Created by 李文韬 on 16/9/21.
//  Copyright © 2016年 com.wentao. All rights reserved.
//

#import "Lwt_PhotoBrowser.h"
#import "Lwt_PhotoBrowserCell.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import <ImageIO/ImageIO.h>
#import "Lwt_ActionSheet.h"

static NSString *Identifier = @"cell";

static float const AnimateDuration = 0.3;


@interface Lwt_PhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    BOOL _isFirstShow;
   
  
}

@property (nonatomic, strong) UIView *clickView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) NSArray *URLStrings;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger clickIndex;
@property (nonatomic, copy) BrowserWillDismiss dismissBlock;
@property (nonatomic, copy) SheetAction sheetAction;
@property (nonatomic, strong) NSArray *sheetTitles;



@end

@implementation Lwt_PhotoBrowser

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    NSLog(@"Lwt_PhotoBrowser release");
}


+ (instancetype)showFromClickView:(UIView *)clickView withURLStrings:(NSArray *)URLStrings atIndex:(NSInteger)index sheetTitles:(NSArray *)sheetTitles sheetAcion:(SheetAction)sheetAcion willDismiss:(BrowserWillDismiss)willDismiss{
    Lwt_PhotoBrowser *browser = [[Lwt_PhotoBrowser alloc] init];
    browser.clickView = clickView;
    browser.URLStrings = URLStrings;
    browser.dismissBlock = willDismiss;
    browser.currentIndex = index;
    browser.clickIndex = index;
    browser.sheetTitles = sheetTitles;
    browser.sheetAction = sheetAcion;
    [browser present];
    return browser;
}

+ (instancetype)showFromClickView:(UIView *)clickView withImages:(NSArray<UIImage *> *)images atIndex:(NSInteger)index sheetTitles:(NSArray *)sheetTitles sheetAcion:(SheetAction)sheetAcion willDismiss:(BrowserWillDismiss)wllDismiss
{
    Lwt_PhotoBrowser *browser = [[Lwt_PhotoBrowser alloc] init];
    browser.clickView = clickView;
    browser.images = images;
    browser.dismissBlock = wllDismiss;
    browser.currentIndex = index;
     browser.clickIndex = index;
    browser.sheetAction = sheetAcion;
    browser.sheetTitles = sheetTitles;
    [browser present];
    return browser;
}


- (void)present
{
    UIViewController *rootVc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.frame = SCREEN_BOUNDS;
    self.backgroundColor = [UIColor blackColor];
    [rootVc.view addSubview:self];
    

}

#pragma mark - 装载视图

- (void)setupCollectionView{
    
    
    CGRect bounds = CGRectMake(0, 0,self.frame.size.width,self.frame.size.height);
  
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
    
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.decelerationRate = 0;
    [_collectionView registerClass:[Lwt_PhotoBrowserCell class] forCellWithReuseIdentifier:Identifier];

    [self addSubview:_collectionView];
}



- (void)setupCountLabel {
    
    _countLabel = [[UILabel alloc] init];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.layer.cornerRadius = 2;
    _countLabel.layer.masksToBounds = YES;
    _countLabel.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    _countLabel.text = [NSString stringWithFormat:@" %zd / %zd ",_currentIndex+1,_URLStrings?_URLStrings.count:_images.count];
    _countLabel.font = [UIFont systemFontOfSize:15];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [_countLabel sizeToFit];
    _countLabel.center = CGPointMake(self.center.x,30);
  
    [self addSubview:_countLabel];
    
}

#pragma mark - 移到父控件上
- (void)willMoveToSuperview:(UIView *)newSuperview{
    
    [self setupCollectionView];
    [self setupCountLabel];
}



#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_URLStrings) {
        
        return  _URLStrings.count;
    }
    if (_images) {
        
        return  _images.count;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self) weakSelf = self;
    Lwt_PhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    
    if (_URLStrings&&_URLStrings.count > 0)
    {
        NSString *url = _URLStrings[indexPath.row];
        
        [cell sd_ImageWithUrl:[NSURL URLWithString:url] placeHolder:[UIImage imageNamed:PlacerhoderName]];
    }else
    {
        [cell sd_ImageWithLocationImage:_images[indexPath.row]];

    }
    
    [cell.scrollView setZoomScale:1.0f animated:NO];
    
    cell.singeTapBlock = ^(UITapGestureRecognizer * tap ){
        [weakSelf dismiss];
    };
    
    cell.longPressBlcok = ^(UILongPressGestureRecognizer *longPress){
        [weakSelf popSheet:(UIImageView *)longPress.view];
    };
    
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
    _countLabel.text = [NSString stringWithFormat:@" %zd / %zd ",_currentIndex+1,_URLStrings?_URLStrings.count:_images.count];
     [_countLabel sizeToFit];
      _countLabel.center = CGPointMake(self.center.x,30);
}


#pragma mark 将子控件上的控件 转成 ImageView
- (UIImageView *)tempViewFromClickView{
  
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    if([_clickView isKindOfClass:[UIImageView class]]){
        UIImageView *imgV = (UIImageView *)_clickView;
        tempView.image = imgV.image;
    }
    
    if([_clickView isKindOfClass:[UIButton class]]){
        UIButton *btn = (UIButton *)_clickView;
        tempView.image = btn.currentImage?btn.currentImage:btn.currentImage;
    }


    if(!tempView.image){
        [tempView setImage:[UIImage imageNamed:PlacerhoderName]];
    }
    return tempView;
}
#pragma mark - 展现的时候 动画
- (void)photoBrowerWillShowWithAnimated{
  
    [_collectionView setContentOffset:(CGPoint){_currentIndex * (self.frame.size.width ),0} animated:NO];
 

    CGRect rect = [_clickView convertRect:_clickView.frame toView:self];
    
    UIImageView *tempView = [self tempViewFromClickView];
    
    tempView.frame = rect;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:tempView];
   
    CGSize tempRectSize;
    
    if (tempView.image)
    {
        CGFloat width = tempView.image.size.width;
        CGFloat height = tempView.image.size.height;
        tempRectSize =CGSizeMake(SCREEN_WIDTH,(height*SCREEN_WIDTH/width)>SCREEN_HEIGHT?SCREEN_HEIGHT:(height*SCREEN_WIDTH)/width);
    }else
    {
        tempRectSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    }

    
    _collectionView.hidden = YES;
    
    [UIView animateWithDuration:AnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        tempView.frame = CGRectMake(0, 0, tempRectSize.width, tempRectSize.height);
        tempView.center= self.center;
        
    } completion:^(BOOL finished) {
        _isFirstShow = YES;
        [tempView removeFromSuperview];
        _collectionView.hidden = NO;
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if(!_isFirstShow){
        [self photoBrowerWillShowWithAnimated];
    }
}



- (void )dismiss {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#endif
    
    if (self.dismissBlock) {
        Lwt_PhotoBrowserCell *cell = (Lwt_PhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        self.dismissBlock(cell.imageView.image, _currentIndex);
    }

   
        UIImageView *tempView = [[UIImageView alloc] init];
    
        SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    
    if (_URLStrings&&_URLStrings.count>0)
    {
        
        NSString *url = _URLStrings[_currentIndex];
        if ([mgr diskImageExistsForURL:[NSURL URLWithString:url]])
        {
            if([[[[url lastPathComponent] pathExtension] lowercaseString] isEqualToString:@"gif"]){ // gif 图片
                NSData *data = UIImageJPEGRepresentation([[mgr imageCache] imageFromDiskCacheForKey:url], 1.f);
                tempView.image = [self imageFromGifFirstImage:data]; // 获取图片的第一帧
            }else{ // 普通图片
                tempView.image = [[mgr imageCache] imageFromDiskCacheForKey:url];
            }
        }else
        {
            tempView.image = [self tempViewFromClickView].image;
         }
    }else
    {
         tempView.image = [_images objectAtIndex:_currentIndex];
    }
        
  
      _countLabel.hidden = YES;

    if (_currentIndex == _clickIndex)
    {
        CGRect rect = [_clickView convertRect:_clickView.bounds toView:self];
        _collectionView.hidden = YES;
        _countLabel.hidden = YES;
        tempView.clipsToBounds = YES;
        tempView.contentMode = UIViewContentModeScaleAspectFill;
        CGSize tempRectSize;
        if (tempView.image)
        {
            CGFloat width = tempView.image.size.width;
            CGFloat height = tempView.image.size.height;
            tempRectSize =CGSizeMake(SCREEN_WIDTH,(height*SCREEN_WIDTH/width)>SCREEN_HEIGHT?SCREEN_HEIGHT:(height*SCREEN_WIDTH)/width);
        }else
        {
            tempRectSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        
        tempView.frame = CGRectMake(0, 0, tempRectSize.width,tempRectSize.height);
   
        tempView.center = self.center;
        [self addSubview:tempView];
        [UIView animateWithDuration:AnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            tempView.frame = rect;
            self.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
              [tempView removeFromSuperview];
        }];

    }else
    {
        
        [UIView animateWithDuration:AnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _collectionView.alpha = 0;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            
            
        }];
    }

    
   
    
    
}

#pragma mark - 获取到 GIF图片的第一帧
- (UIImage *)imageFromGifFirstImage:(NSData *)data{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *sourceImage;
    if(count <= 1){
        CFRelease(source);
        sourceImage = [[UIImage alloc] initWithData:data];
    }else{
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        sourceImage = [UIImage imageWithCGImage:image];
        CFRelease(source);
        CGImageRelease(image);
    }
    return sourceImage;
}


#pragma mark - 保存图片
- (void)popSheet:(UIImageView *)imageView;
{
   
    Lwt_ActionSheet *actionSheet = [[Lwt_ActionSheet alloc] initWithCancelBtnTitle:@"取消" destructiveButtonTitle:nil otherBtnTitlesArr:_sheetTitles  actionBlock:^(NSInteger clickIndex) {
        
        if (_sheetAction)
        {
            _sheetAction(clickIndex,imageView);
        }
    }];
    
    [actionSheet show];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
