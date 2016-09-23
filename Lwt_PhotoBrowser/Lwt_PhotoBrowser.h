//
//  Lwt_PhotoBrowser.h
//  PhotoBrowserDemo
//
//  Created by 李文韬 on 16/9/21.
//  Copyright © 2016年 com.wentao. All rights reserved.
//

#import <UIKit/UIKit.h>




static NSString * const PlacerhoderName = @"";

typedef void (^BrowserWillDismiss)(UIImage *image,NSInteger index);


//长按图片弹出sheet
typedef void(^SheetAction)(NSInteger clickIndex,UIImageView *actionImgView);

@interface Lwt_PhotoBrowser : UIView

//网络图片

+ (instancetype)showFromClickView:(UIView *)clickView withURLStrings:( NSArray *)URLStrings  atIndex:(NSInteger)index sheetTitles:(NSArray *)sheetTitles sheetAcion:(SheetAction)sheetAcion   willDismiss:(BrowserWillDismiss )willDismiss;


//本地图片

+ (instancetype)showFromClickView:(UIView*)clickView withImages:( NSArray<UIImage*> *)images atIndex:(NSInteger)index sheetTitles:(NSArray *)sheetTitles sheetAcion:(SheetAction)sheetAcion willDismiss:(BrowserWillDismiss )wllDismiss;

@end
