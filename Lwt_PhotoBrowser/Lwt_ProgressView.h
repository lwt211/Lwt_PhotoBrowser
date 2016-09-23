//
//  Lwt_ProgressView.h
//  shuangtu
//
//  Created by 李文韬 on 16/9/22.
//  Copyright © 2016年 TD_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Lwt_ProgressView : UIView


+ (instancetype)showHUDAddTo:(UIView *)superView animated:(BOOL)animated;


@property (nonatomic, strong) UIColor *HUDColor;


@property (nonatomic, strong) UIColor *sectorColor;


@property (nonatomic, strong) UIColor *sectorBoldColor;

@property (nonatomic, assign) CGFloat progress;
    
- (void)dismiss;
    



@end
