//
//  YSFirstLaunchGuideView.h
//  GuideViewDemo
//
//  Created by Joseph Gao on 16/4/1.
//  Copyright © 2016年 Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSFirstLaunchGuideView : UIView

/*!
 @param imgNames              图片名称数组
 @param key                   保存的key, 每个调用的key要不一样
 @param blurRadius            模糊度半径,值越高,模糊度越大.传0则使用默认1.0
 @param saturationDeltaFactor 渲染度,值越大,渲染颜色越深.传0则使用默认值0.8
 @param inView                截取哪个view显示的图,当前屏幕显示内容传: self.view ; 如果直接用图片、不用背景图,则传nil.
 */
+ (void)configFirstLaunchWithImgNames:(NSArray *)imgNames
                                  key:(NSString *)key
                           blurRadius:(CGFloat)blurRadius
                saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                               inView:(UIView *)inView;

@end
