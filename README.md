# PieChart
最近在重构项目，里面涉及到饼状图，就自己写了个，在这里分享一下：[github地址](https://github.com/V5zhou/PieChart)

展示一下效果图：

![show.gif](http://upload-images.jianshu.io/upload_images/3913024-af97f7dffb68dd7a.gif?imageMogr2/auto-orient/strip)

大致思路如下：
1.确定中心点。中心点就是view的中心，最大线长MIN(宽,高)的一半。
```
_centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
```
2.-π/2位置作为第一个轴角度，依次确定每个轴的角度。
```
#pragma mark - 第N条边的角度
- (CGFloat)degreeForForCornerIndex:(NSInteger)index {
    CGFloat eachCornerRedius = M_PI * 2.0 / _cornerNum;
    CGFloat redius0 = -M_PI_2;
    CGFloat rediusN = redius0 + eachCornerRedius * index;
    return rediusN;
}
```
3.根据每个轴上的长度，来得到绘制的坐标点。
```
#pragma mark - 在第N条边上，长M的线对应的point
- (CGPoint)pointForCornerIndex:(NSInteger)index length:(CGFloat)length {
    CGFloat redius = [self degreeForForCornerIndex:index];  //得到角度
    CGFloat X = cos(redius) * length;
    CGFloat Y = sin(redius) * length;
    return CGPointMake(_centerPoint.x + X, _centerPoint.y + Y);
}
```
4.连接每个坐标点画成面。
```
#pragma mark - 画七角圈圈并填充
- (void)drawSevenLineWithLengths:(NSArray<NSNumber *> *)lengths color:(UIColor *)color fillColor:(UIColor *)fillColor context:(CGContextRef)context {
    UIGraphicsPushContext(context);
    CGPoint firstPoint = CGPointZero;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [color setStroke];
    [fillColor setFill];
    [path setLineWidth:0.5];
    for (NSInteger i = 0; i < lengths.count; i++) {
        CGPoint point = [self pointForCornerIndex:i length:[lengths[i] floatValue]];
        if (i == 0) {
            [path moveToPoint:point];
            firstPoint = point;
        }
        else {
            [path addLineToPoint:point];
        }
        if (i == lengths.count - 1) {   //最后一笔画完填充
            [path addLineToPoint:firstPoint];
            [path stroke];
            [path fill];
        }
    }
    UIGraphicsPopContext();
}
```
5.画描述文字，此文字是中心点在轴线上。
```
#pragma mark - 画统计提示
- (void)drawSevenTipsInContext:(CGContextRef)context {
    NSArray *Tips = _descriptions;
    CGFloat location = _descriptionOffsetCenter;
    for (NSInteger i = 0; i < Tips.count; i++) {
        CGPoint point = [self pointForCornerIndex:i length:location];
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:Tips[i]
                                                                            attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                                         NSForegroundColorAttributeName : UIColorHex(#888888)}];
        CGRect textRect = [self rectForAttributeText:attributeText centerPoint:point];
        [attributeText drawInRect:textRect];
    }
}
```
6.此时背影图已经画好，计算每个给进来的progress计算出长度与值的比例，根据progress的值乘以比例，计算出在轴线上的长度。
```
CGFloat rate = (_lineLength - _innerSpace)/[_fullProgressArray[i] floatValue];
CGFloat value = [_progressArray[i] floatValue];
CGFloat length = _innerSpace + rate * value;
```
7.同样道理走第3-5步。
8.画时间圆弧，不再陈述。

总结：
      根据index确定哪条轴，根据哪条轴确定角度，根据progess值计算出在此轴上的长度，轴上的长度可以确定点。把点画出来，连接成面，fill颜色。
