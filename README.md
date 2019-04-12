# YYFPSLabel

YYText 中计算当前界面每秒帧数FPS的小组件，见：[YYText/Demo/YYTextDemo/YYFPSLabel](https://github.com/ibireme/YYText/blob/master/Demo/YYTextDemo/YYFPSLabel.m)

## 对于源码的学习和探讨：

### 主要原理

YYFPSLabel 实现思路：
- `CADisplayLink` 默认每秒 60次；
- 将 `CADisplayLink`  add 到 `mainRunLoop` 中；
- 使用 `CADisplayLink` 的 `timestamp` 属性，在 `CADisplayLink` 每次 tick 时，记录上一次的 `timestamp`；
- 用 _count 记录 `CADisplayLink` tick 的执行次数;
- 计算此次 tick 时， `CADisplayLink` 的当前 timestamp 和 _lastTimeStamp 的差值；
- 如果差值大于1，fps = _count / delta，计算得出 FPS 数；

详见 [代码](https://github.com/yehot/YYFPSLabel/blob/master/YYFPSLabel/YYFPSLabel/YYFPSLabel.m)

### 深入探讨

[iOS查看当前界面帧数](http://www.jianshu.com/p/878bfd38666d)

## Demo 效果：

![](demo.gif)
