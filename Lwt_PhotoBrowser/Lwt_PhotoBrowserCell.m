


//
//  Lwt_PhotoBrowserCell.m
//  PhotoBrowserDemo
//
//  Created by 李文韬 on 16/9/21.
//  Copyright © 2016年 com.wentao. All rights reserved.
//

#import "Lwt_PhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "Lwt_ProgressView.h"

@interface Lwt_PhotoBrowserCell ()<UIScrollViewDelegate>
{
    Lwt_ProgressView *_progressHUD;
}


@end


@implementation Lwt_PhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
       
        [self setupView];
        [self setupTouch];
    }
    return self;
}
- (void)setupView {
    _scrollView = [[UIScrollView alloc] initWithFrame:SCREEN_BOUNDS];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.maximumZoomScale = 2;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.delegate = self;
    
    [self.contentView addSubview:_scrollView];
    
    _imageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];

    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
  
    
}

- (void)setupTouch
{
  
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singeTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPresss:)];
    
   
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:1];

    
   
    [tap requireGestureRecognizerToFail:doubleTap];
//    [tap requireGestureRecognizerToFail:longPress];
    
    [_imageView addGestureRecognizer:tap];
    [_imageView addGestureRecognizer:doubleTap];
    [_imageView addGestureRecognizer:longPress];
}


#pragma mark - 手势
//单击
- (void)singeTap:(UITapGestureRecognizer *)tap
{
    
    if(_singeTapBlock){
        _singeTapBlock(tap);
    }
}

//长按
- (void)longPresss:(UILongPressGestureRecognizer *)longPress
{
    if(!_imageView.image) return;
  
     switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"开始长按");
            if(_longPressBlcok){
                _longPressBlcok(longPress);
            }
            
        } ;break;
        default:
            break;
    }
}

//双击
- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    // 这里先判断图片是否下载好,, 如果没下载好, 直接return
    if(!_imageView.image) return;
    
    
    if(_scrollView.zoomScale <= 1){
        // 1.获取到 手势 在 自身上的 位置
        // 2.scrollView的偏移量 x(为负) + 手势的 x 需要放大的图片的X点
        CGFloat x = [tap locationInView:self].x + _scrollView.contentOffset.x;
        
        // 3.scrollView的偏移量 y(为负) + 手势的 y 需要放大的图片的Y点
        CGFloat y = [tap locationInView:self].y + _scrollView.contentOffset.y;
        [_scrollView zoomToRect:(CGRect){{x,y},CGSizeZero} animated:YES];
    }else{
        // 设置 缩放的大小  还原
        [_scrollView setZoomScale:1.f animated:YES];
    }


}

- (void)sd_ImageWithUrl:(NSURL *)url placeHolder:(UIImage *)placeHolder{
    
   
 
    __weak typeof(self) weakSelf = self;
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    
    // 尝试 从缓存里 拿出 图片
    [[mgr imageCache] queryDiskCacheForKey:[url absoluteString] done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if(_progressHUD){// 如果加载圈存在,则消失
            [_progressHUD removeFromSuperview];
        }
        
        if (image) { // 如果缓存中有图片, 则直接赋值
            _imageView.image = image;
            [weakSelf layoutSubviews];
        }else{// 缓存中没有图片, 则下载
            // 加载圈 开始 出现
            _progressHUD = [Lwt_ProgressView showHUDAddTo:self animated:YES];
           
            
            // SDWebImage 下载图片
            [_imageView sd_setImageWithPreviousCachedImageWithURL:url placeholderImage:placeHolder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                CGFloat progress = ((CGFloat)receivedSize / expectedSize);
                _progressHUD.progress = progress; // 设置 进度
                if(progress == 1){ // 如果进度 == 1 , 则消失
                    if(!_progressHUD){
                        [_progressHUD removeFromSuperview];
                    }
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [_scrollView setZoomScale:1.f animated:YES];
                if(error){
                     [_progressHUD removeFromSuperview];
                    [SVProgressHUD showErrorWithStatus:@"加载失败"];
                }else{
                    [weakSelf layoutSubviews];
                }
            }];
        }
    }];
}

- (void)sd_ImageWithLocationImage:(UIImage *)image
{
    _imageView.image = image;
    [self layoutSubviews];
  
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    [self resetUI];
}


- (void)resetUI{
    
    CGRect frame = self.frame;
    
    if(_imageView.image){
        
        CGSize imageSize = _imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        if (frame.size.width <= frame.size.height) { // 如果ScrollView的 宽 <= 高
            // 将图片的 宽 设置成 ScrollView的宽  ,高度 等比率 缩放
            CGFloat ratio = frame.size.width / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = frame.size.width;
            
        }else{
            
            // 将图片的 宽 设置成 ScrollView的宽  ,高度 等比率 缩放
            CGFloat ratio = frame.size.height / imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        // 设置 imageView 的 frame
        _imageView.frame = imageFrame;
        
        // scrollView 的滚动区域
        _scrollView.contentSize = _imageView.frame.size;
        
        // 将 scrollView.contentSize 赋值为 图片的大小. 再获取 图片的中心点
        _imageView.center = [self centerOfScrollViewContent:_scrollView];
        
        // 获取 ScrollView 高 和 图片 高 的 比率
        CGFloat maxScale = frame.size.height / imageFrame.size.height;
        // 获取 宽度的比率
        CGFloat widthRadit = frame.size.width / imageFrame.size.width;
        
        // 取出 最大的 比率
        maxScale = widthRadit > maxScale?widthRadit:maxScale;
        // 如果 最大比率 >= 2 倍 , 则取 最大比率 ,否则去 2 倍
        maxScale = maxScale > 2?maxScale:2;
        
        // 设置 scrollView的 最大 和 最小 缩放比率
        _scrollView.minimumZoomScale = 0.6;
        _scrollView.maximumZoomScale = maxScale;
        
        // 设置 scrollView的 原始缩放大小
        _scrollView.zoomScale = 1.0f;
        
    }else{
        frame.origin = CGPointZero;
        _imageView.frame = frame;
        _scrollView.contentSize = _imageView.size;
    }
    _scrollView.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView{
    // scrollView.bounds.size.width > scrollView.contentSize.width : 说明:scrollView 大小 > 图片 大小
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    // 在ScrollView上  所需要缩放的 对象
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // 每次 完成 拖动时 都 重置 图片的中心点
    _imageView.center = [self centerOfScrollViewContent:scrollView];
}


@end
