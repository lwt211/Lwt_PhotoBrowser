//
//  Lwt_ActionSheet.h
//  shuangtu
//
//  Created by 李文韬 on 16/9/22.
//  Copyright © 2016年 TD_. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionBlock)(NSInteger clickIndex);


@interface Lwt_ActionSheet : UIView

- (instancetype)initWithCancelBtnTitle:(NSString *)cancelBtnTitle
                destructiveButtonTitle:(NSString *)destructiveBtnTitle
                     otherBtnTitlesArr:(NSArray *)otherBtnTitlesArr
                           actionBlock:(ActionBlock)ActionBlock;

- (void)show;
- (void)dismiss;



@end
