# YSGuideView
## 一.概述
* 快速创建第一次启动页面时显示指导页
* 直接一行代码即可

```ObjectiveC
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
```

## 二.使用
* 如果不要渲染背景图, inView:参数传 nil
* 渲染背景图, inView:传渲染背景图的控制的view,一般是`self.view`
* 如果是不用渲染背景图,直接在`ViewDidLoad`里面调用
* 如果要渲染背景图,在`ViewDidAppear`里面条用


