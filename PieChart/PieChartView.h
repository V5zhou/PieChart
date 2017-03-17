//
//  PieChartView.h
//  PieChart
//
//  Created by zmz on 17/3/17.
//  Copyright © 2017年 zmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieChartView : UIView

//控制参数
@property (nonatomic, assign) CGPoint centerPoint;              ///< 中心点(默认view中点)
@property (nonatomic, assign) NSInteger cornerNum;              ///< N角形
@property (nonatomic, assign) NSInteger roundNum;               ///< 圈数（默认5）
@property (nonatomic, assign) CGFloat lineLength;               ///< 七星线长（默认MIN(W, H)/2 - 40）
@property (nonatomic, assign) CGFloat descriptionOffsetCenter;  ///< 描述文字距中心多远（默认lineLength * (roundNum + 1) / roundNum）
@property (nonatomic, assign) CGFloat innerSpace;               ///< 距中心点预留线长（即开始计数位置）

/**
 *  创建
 */
+ (instancetype)createWithFrame:(CGRect)frame;

//数据源
@property (nonatomic, strong) NSArray<NSString *> *descriptions;        ///< 描述文字
@property (nonatomic, strong) NSArray<NSNumber *> *fullProgressArray;   ///< 满分数组
@property (nonatomic, strong) NSArray<NSNumber *> *progressArray;       ///< 进度数组
@property (nonatomic, copy)   NSString *minites;                        ///< 分钟数

@end
