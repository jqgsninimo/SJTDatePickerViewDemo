//
//  SJTDatePickerView.h
//  SJTDatePickerViewDemo
//
//  Created by Jqgsninimo on 12-12-4.
//  Copyright (c) 2012年 SJT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SJTDatePickerViewModeMinute = 0,
    SJTDatePickerViewModeHour,
    SJTDatePickerViewModeDay,
    SJTDatePickerViewModeMonth,
    SJTDatePickerViewModeYear
} SJTDatePickerViewMode;

@interface SJTDatePickerView : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, assign) NSUInteger unitCount; 
@property(nonatomic, readonly) NSDate *maximumDate;
@property(nonatomic, readonly) NSDate *minimumDate;
@property(nonatomic, readonly) NSInteger changedUnit;
@property(nonatomic, assign) SJTDatePickerViewMode datePickerViewMode;

- (void)setDateRangeFrom:(NSDate *)startDate to:(NSDate *)endDate;
- (void)setDate:(NSDate *)date inUnit:(NSUInteger)unit;
- (NSDate *)getDateInUnit:(NSUInteger)unit;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end