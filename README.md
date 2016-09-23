# Lwt_ProgressView
一款极其简约的图片浏览器，封装了底部弹出菜单，支持本地浏览和网络浏览

##如何使用？

###例子:


![](https://github.com/lwt211/Lwt_PhotoBrowser/raw/master/resource/IMG_2215.PNG)  


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 /[collectionView deselectItemAtIndexPath:indexPath animated:YES];
MyCell *cell = ( MyCell *)/[collectionView cellForItemAtIndexPath:indexPath];
####状态栏隐藏
_hidenStatuBar = YES;
/[self setNeedsStatusBarAppearanceUpdate];
###弹出浏览器
/[Lwt_PhotoBrowser showFromClickView:cell.imageView withURLStrings:self.photoURLArr atIndex:indexPath.row sheetTitles:@[@"保存图片到相册",@"分享图片"] sheetAcion:^(NSInteger clickIndex, UIImageView *actionImgView) {
#####长按图片弹出底部菜单
if (clickIndex == 0)
{
#####保存图片到相册
UIImageWriteToSavedPhotosAlbum(actionImgView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}else
{
  
}
} willDismiss:^(UIImage *image, NSInteger index) {
####状态栏显示
_hidenStatuBar = NO;
[self setNeedsStatusBarAppearanceUpdate];

}];

}




