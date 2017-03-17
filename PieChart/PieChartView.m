//
//  PieChartView.m
//  PieChart
//
//  Created by zmz on 17/3/17.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import "PieChartView.h"
#import "UIColor+category.h"

@implementation PieChartView

+ (instancetype)createWithFrame:(CGRect)frame {
    PieChartView *view = [[PieChartView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    [view setsDefaultArg];
    return view;
}

//设置默认参数
- (void)setsDefaultArg {
    _centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _roundNum = 5;
    _lineLength = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2 - 40;
    _innerSpace = 1.0/_roundNum * _lineLength;  //默认第一圈开始计数，不然都从中心点开始计
    _descriptionOffsetCenter = _lineLength * (_roundNum + 1) / _roundNum;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //小于三条边画个毛啊
    if (_cornerNum < 3) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //背景圈圈图
    for (NSInteger i = _roundNum - 1; i >= 0; i--) {
        [self drawSevenLineWithLengths:[self lengthsForRoundIndex:i] color:UIColorHex(#46a9e5) fillColor:UIColorHex(#e7e6fe) context:context];
    }
    //七条灰线
    for (NSInteger i = 0; i < _cornerNum; i++) {
        [self drawLineFromPoint:_centerPoint toPoint:[self pointForCornerIndex:i length:_lineLength] lineColor:UIColorHex(#999999) context:context];
    }
    //文字描述
    [self drawSevenTipsInContext:context];
    //红色进度区域七角形、七个点、七个值
    NSMutableArray *lengths, *attributes;
    [self GetsLengths:&lengths attributes:&attributes];    //把数据转化为长度
    [self drawSevenLineWithLengths:lengths color:UIColorHex(#ff2d55) fillColor:[UIColorHex(#ff2d55) colorWithAlphaComponent:0.5] context:context];
    [self drawSevenPoints:lengths fillColor:UIColorHex(#ff2d55) context:context];
    [self drawSevenValueWithLengths:lengths attributes:attributes inContext:context];
    //时间
    [self drawTimerInContext:context];
}

#pragma mark - ====================== 主要组成部分 ======================
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

#pragma mark - 画七个点
- (void)drawSevenPoints:(NSArray<NSNumber *> *)lengths fillColor:(UIColor *)fillColor context:(CGContextRef)context {
    for (NSInteger i = 0; i < lengths.count; i++) {
        CGPoint point = [self pointForCornerIndex:i length:[lengths[i] floatValue]];
        [self drawCircleWithPoint:point width:4 color:fillColor context:context];
    }
}

#pragma mark - 画七个点Value与rank值
- (void)drawSevenValueWithLengths:(NSArray<NSNumber *> *)lengths attributes:(NSArray<NSAttributedString *> *)attributes inContext:(CGContextRef)context {
    for (NSInteger i = 0; i < lengths.count; i++) {
        CGFloat length = [lengths[i] floatValue];
//        if (length > _innerSpace + 14) {
//            length -= 14;   //向里收缩,防止文字跑大饼外面出去
//        }
//        if (length < _innerSpace + 8) {
//            length = _innerSpace + 8;   //向外拉5，防止压住时间圈
//        }
        CGPoint point = [self pointForCornerIndex:i length:length];
        CGRect textRect = [self rectForAttributeText:attributes[i] centerPoint:point];
        [attributes[i] drawInRect:textRect];
    }
}

#pragma mark - 画时间显示
- (void)drawTimerInContext:(CGContextRef)context {
    NSString *timer = _minites;
    CGFloat progress = timer.floatValue/60.0;
    [self drawProgressCircleWithPoint:_centerPoint radius:_lineLength/_roundNum - 3 color:[UIColorHex(#333333) colorWithAlphaComponent:0.2] progressedColor:[UIColor whiteColor] progress:progress context:context];
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n分钟", _minites]
                                                                        attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:10],
                                                                                     NSForegroundColorAttributeName : [UIColor whiteColor]}];
    CGRect textRect = [self rectForAttributeText:attributeText centerPoint:_centerPoint];
    [attributeText drawInRect:textRect];
}

#pragma mark - ====================== 计算逻辑 ======================
#pragma mark - 生成对应圈的长度
- (NSArray<NSNumber *> *)lengthsForRoundIndex:(NSInteger)index {
    NSMutableArray *lengths = [NSMutableArray array];
    for (NSInteger i = 0; i < _cornerNum; i++) {
        CGFloat length = (index + 1.0f)/_roundNum * _lineLength;
        [lengths addObject:@(length)];
    }
    return lengths;
}

#pragma mark - 在第N条边上，长M的线对应的point
- (CGPoint)pointForCornerIndex:(NSInteger)index length:(CGFloat)length {
    CGFloat redius = [self degreeForForCornerIndex:index];  //得到角度
    CGFloat X = cos(redius) * length;
    CGFloat Y = sin(redius) * length;
    return CGPointMake(_centerPoint.x + X, _centerPoint.y + Y);
}

#pragma mark - 第N条边的角度
- (CGFloat)degreeForForCornerIndex:(NSInteger)index {
    CGFloat eachCornerRedius = M_PI * 2.0 / _cornerNum;
    CGFloat redius0 = -M_PI_2;
    CGFloat rediusN = redius0 + eachCornerRedius * index;
    return rediusN;
}

#pragma mark - point点对应文字位置
- (CGRect)rectForAttributeText:(NSAttributedString *)attributeText centerPoint:(CGPoint)point {
    CGSize size = [attributeText boundingRectWithSize:CGSizeMake(HUGE_VALF, HUGE_VALF) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
    CGRect rect = CGRectMake(point.x - size.width/2, point.y - size.height/2, size.width, size.height);
    return rect;
}

#pragma mark - 由技术统计数据--->长度与value值
- (void)GetsLengths:(NSMutableArray<NSNumber *> **)lengths attributes:(NSMutableArray<NSAttributedString *> **)attributes {
    if (_progressArray && _progressArray.count == _cornerNum) {
        *lengths = [NSMutableArray array];
        *attributes = [NSMutableArray array];
        for (NSInteger i = 0; i < _progressArray.count; i++) {
            CGFloat rate = (_lineLength - _innerSpace)/[_fullProgressArray[i] floatValue];
            CGFloat value = [_progressArray[i] floatValue];
            CGFloat length = _innerSpace + rate * value;
            [*lengths addObject:@(length)];
            //value
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = NSTextAlignmentCenter;//文本对齐方式 左右对齐（两边对齐）
            NSMutableAttributedString *muAttribute = [[NSMutableAttributedString alloc]
                                                      initWithString:[NSString stringWithFormat:@"%@分", _progressArray[i]]
                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                                                   NSForegroundColorAttributeName : UIColorHex(#333333),
                                                                   NSParagraphStyleAttributeName : paragraphStyle}];
            //评价
            NSString *superStr = [NSString stringWithFormat:@"%@", ([_progressArray[i] floatValue] >= 90) ? @"优秀" : @""];
            if (superStr.length > 0) {
                NSMutableAttributedString *rankAttribute = [[NSMutableAttributedString alloc]
                                                            initWithString:superStr
                                                            attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8],
                                                                         NSForegroundColorAttributeName : UIColorHex(#ff2222),
                                                                         NSParagraphStyleAttributeName : paragraphStyle}];
                [muAttribute appendAttributedString:rankAttribute];
            }
            [*attributes addObject:muAttribute];
        }
    }
}

#pragma mark - ====================== 画线 ======================
#pragma mark - 画线
- (void)drawLineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 lineColor:(UIColor *)lineColor context:(CGContextRef)context {
    UIGraphicsPushContext(context);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path setLineWidth:0.5];
    [lineColor setStroke];
    [path stroke];
    UIGraphicsPopContext();
}

#pragma mark - 画圆
- (void)drawCircleWithPoint:(CGPoint)point width:(CGFloat)width color:(UIColor *)color context:(CGContextRef)context {
    UIGraphicsPushContext(context);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - width/2, point.y - width/2, width, width)];
    [color setFill];
    [path fill];
    UIGraphicsPopContext();
}

#pragma mark - 画圆弧
- (void)drawProgressCircleWithPoint:(CGPoint)point radius:(CGFloat)radius color:(UIColor *)color progressedColor:(UIColor *)progressedColor progress:(CGFloat)progress context:(CGContextRef)context {
    UIGraphicsPushContext(context);
    UIBezierPath *path0 = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:-M_PI_2 endAngle:M_PI*2 - M_PI_2 clockwise:YES];
    [path0 setLineWidth:3];
    [color setStroke];
    [path0 stroke];
    UIGraphicsPopContext();
    
    UIGraphicsPushContext(context);
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:point radius:radius startAngle:-M_PI_2 endAngle:(progress*M_PI*2) - M_PI_2 clockwise:YES];
    [path1 setLineWidth:3];
    [progressedColor setStroke];
    [path1 stroke];
    UIGraphicsPopContext();
}

#pragma mark - setter & getter
- (void)setProgressArray:(NSArray<NSNumber *> *)progressArray {
    _progressArray = progressArray;
    _cornerNum = _progressArray.count;
    [self setNeedsDisplay];
}

- (void)setMinites:(NSString *)minites {
    _minites = [minites copy];
    [self setNeedsDisplay];
}

@end
