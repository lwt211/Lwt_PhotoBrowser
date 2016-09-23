//
//  Lwt_PhotoBrowserCell.h
//  PhotoBrowserDemo
//
//  Created by 李文韬 on 16/9/21.
//  Copyright © 2016年 com.wentao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SingeTapBlock)(UITapGestureRecognizer *tapGesture);

typedef void (^LongPressBlock)(UILongPressGestureRecognizer *longPress);


@interface Lwt_PhotoBrowserCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy)  SingeTapBlock singeTapBlock;

@property (nonatomic, copy)  LongPressBlock longPressBlcok;

- (void)sd_ImageWithUrl:(NSURL *)url placeHolder:(UIImage *)placeHolder;
- (void)sd_ImageWithLocationImage:(UIImage *)image;


- (void)resetUI;


@end
