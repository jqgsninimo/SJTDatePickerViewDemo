//
//  SJTDatePickerView.m
//  SJTDatePickerViewDemo
//
//  Created by Jqgsninimo on 12-12-4.
//  Copyright (c) 2012年 SJT. All rights reserved.
//

#import <objc/message.h>
#import "SJTDatePickerView.h"

#pragma mark -
#pragma mark Type Definition
#pragma mark -
typedef enum {
    ComponentTypeYear = 0,
    ComponentTypeMonth = 1,
    ComponentTypeDay = 2,
    ComponentTypeHour = 3,
    ComponentTypeMinute = 4,
    ComponentTypeSeparator = 5
} ComponentType;

#pragma mark -
#pragma mark Constant Definition
#pragma mark -
static const CGFloat kViewMinimumHeight = 162;
static const CGFloat kViewMediumHeight = 180;
static const CGFloat kViewMaximumHeight = 216;
static const CGFloat kViewMargin = 10;
static const CGFloat kComponentMargin = 1;
static const CGFloat kRowHeight = 44;
static const CGFloat kComponentWidthYear = 96;
static const CGFloat kComponentWidthMonth = 68;
static const CGFloat kComponentWidthDay = 68;
static const CGFloat kComponentWidthHour = 68;
static const CGFloat kComponentWidthMinute = 68;
static const CGFloat kComponentWidthSeparator = 20;
static const CGFloat kCellMargin = 5;
static const CGFloat kFontSize = 25;
static const NSInteger kLoopRowCount = 100000;
static NSString *const kTextYear = @"年";
static NSString *const kTextMonth = @"月";
static NSString *const kTextDay = @"日";
static NSString *const kTextHour = @"時";
static NSString *const kTextMinute = @"分";
static NSString *const kTextSeparator = @":";
static NSString *const kDateFormat = @"y年M月d日H時m分";
static NSString *const kMaximumDateString = @"2200年12月31日23時59分";
static NSString *const kMinimumDateString = @"1970年1月1日0時0分";

#pragma mark -
#pragma mark DatePickerData Class
#pragma mark -
@interface DatePickerData : NSObject<NSCopying>

@property(nonatomic, assign) NSDate *date;
@property(nonatomic, assign) NSInteger year;
@property(nonatomic, assign) NSInteger month;
@property(nonatomic, assign) NSInteger day;
@property(nonatomic, assign) NSInteger hour;
@property(nonatomic, assign) NSInteger minute;

+ (NSDateComponents *)componentsOfDate:(NSDate *)date;
+ (NSDate *)validateDate:(NSDate *)date inRangeFrom:(NSDate *)startDate to:(NSDate *)endDate;
- (DatePickerData *)initWithDate:(NSDate *)date;

@end

@implementation DatePickerData

#pragma mark -
#pragma mark Methods From NSObject
- (DatePickerData *)init {
    return [self initWithDate:[NSDate date]];
}

- (BOOL)isEqual:(id)anObject {
    BOOL result = NO;
    if ([anObject isKindOfClass:[self class]] ) {
        DatePickerData *other = (DatePickerData *)anObject;
        if (self.year == other.year &&
            self.month == other.month &&
            self.day == other.day &&
            self.hour == other.hour &&
            self.minute == other.minute) {
            result = YES;
        }
    }
    
    return result;
}

#pragma mark -
#pragma mark Methods From NSCopying
- (id)copyWithZone:(NSZone *)zone {
    DatePickerData *copy = [[[self class] allocWithZone:zone] init];
    copy.year = self.year;
    copy.month = self.month;
    copy.day = self.day;
    copy.hour = self.hour;
    copy.minute = self.minute;
    return copy;
}

#pragma mark -
#pragma mark Class Methods
+ (NSDateComponents *)componentsOfDate:(NSDate *)date {
    NSDate* aDate = date ? date : [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    return [calendar components:unitFlags fromDate:aDate];
}

+ (NSDate *)validateDate:(NSDate *)date inRangeFrom:(NSDate *)startDate to:(NSDate *)endDate {
    NSDate *validDate = date;
    validDate = [validDate laterDate:startDate];
    validDate = [validDate earlierDate:endDate];
    
    return validDate;
}

#pragma mark -
#pragma mark Instance Methods
- (DatePickerData *)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        self.date = date;
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    NSDateComponents *dateComponents = [DatePickerData componentsOfDate:date];
    self.year = [dateComponents year];
    self.month = [dateComponents month];
    self.day = [dateComponents day];
    self.hour = [dateComponents hour];
    self.minute = [dateComponents minute];
}

- (NSDate *)date {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setCalendar:[NSCalendar currentCalendar]];
    [dateComponents setYear:self.year];
    [dateComponents setMonth:self.month];
    [dateComponents setDay:self.day];
    [dateComponents setHour:self.hour];
    [dateComponents setMinute:self.minute];
    NSDate *date = [dateComponents date];
    
    return date;
}

@end

#pragma mark -
#pragma mark SJTEventObserver Class
#pragma mark -
@interface SJTEventObserver : NSObject
@property (strong) id target;
@property (assign) SEL action;
@end

@implementation SJTEventObserver
@end

#pragma mark -
#pragma mark SJTDatePickerView Class
#pragma mark -
@interface SJTDatePickerView()

@property (nonatomic, readonly) NSMutableArray *datePickerDataArray;
@property (nonatomic, strong) NSMutableDictionary *eventObserverDictionary;
@property (nonatomic, assign) CGRect userFrame;
@property (nonatomic, assign) CGSize adjustedSize;
@property (nonatomic, assign) CGFloat componentWidthYear;
@property (nonatomic, assign) CGFloat componentWidthMonth;
@property (nonatomic, assign) CGFloat componentWidthDay;
@property (nonatomic, assign) CGFloat componentWidthHour;
@property (nonatomic, assign) CGFloat componentWidthMinute;
@property (nonatomic, assign) BOOL needAdjustViewScale;

- (NSInteger)componentCountInUnit;
- (ComponentType)typeOfComponent:(NSInteger)component;
- (NSUInteger)unitOfComponent:(NSInteger)component;
- (NSInteger)componentOfType:(ComponentType)type inUnit:(NSUInteger)unit;
- (UIColor *)textColorOfYearCellForRow:(NSInteger)row;
- (UIColor *)textColorOfMonthCellForRow:(NSInteger)row forComponent:(NSInteger)component;
- (UIColor *)textColorOfDayCellForRow:(NSInteger)row forComponent:(NSInteger)component;
- (UIColor *)textColorOfHourCellForRow:(NSInteger)row forComponent:(NSInteger)component;
- (UIColor *)textColorOfMinuteCellForRow:(NSInteger)row forComponent:(NSInteger)component;
- (DatePickerData *)dataAtComponent:(NSInteger)component;
- (NSInteger)rowOffsetOfMonthComponentWithDatePickerData:(DatePickerData *)data;
- (NSInteger)rowOffsetOfDayComponentWithDatePickerData:(DatePickerData *)data;
- (NSInteger)rowOffsetOfHourComponentWithDatePickerData:(DatePickerData *)data;
- (NSInteger)rowOffsetOfMinuteComponentWithDatePickerData:(DatePickerData *)data;
- (NSInteger)rowCountForYearComponent;
- (NSInteger)valueAtRow:(NSInteger)row forComponentType:(ComponentType)type;
- (NSInteger)rowOfValue:(NSInteger)value forComponentType:(ComponentType)type;
- (void)reloadDataInUnit:(NSUInteger)unit animated:(BOOL)animated;
- (void)reloadDataWithDelay;
- (void)reloadDataWithAnimated:(BOOL)animated;
- (void)adjustViewSize;
- (void)adjustComponentsWidth;
- (void)adjustViewScale;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;
@end

@implementation SJTDatePickerView
@synthesize datePickerDataArray = _datePickerDataArray;
@synthesize maximumDate = _maximumDate;
@synthesize minimumDate = _minimumDate;
@synthesize needAdjustViewScale = _needAdjustViewScale;
@synthesize changedUnit = _changedUnit;
@synthesize datePickerViewMode = _datePickerViewMode;

#pragma mark -
#pragma mark Methods From UIView
- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        self.showsSelectionIndicator = YES;
        self.delegate = self;
        self.dataSource = self;
        _changedUnit = -1;
    }
    
    return self;
}

- (CGRect)frame {
    CGRect frame;
    frame.origin = self.userFrame.origin;
    CGFloat scale = self.userFrame.size.width/self.adjustedSize.width;
    frame.size.width = self.adjustedSize.width*scale;
    frame.size.height = self.adjustedSize.height*scale;
    return frame;
}

- (void)setFrame:(CGRect)frame {
    if (frame.size.width==0) {
        frame.size.width = 1;
    }
    if (frame.size.height==0) {
        frame.size.height = 1;
    }
    self.userFrame = frame;
    [self adjustViewSize];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.needAdjustViewScale) {
        self.needAdjustViewScale = NO;
        [self adjustViewScale];
    }
}

#pragma mark -
#pragma mark Methods From UIPickerViewDelegate
// Called by the picker view when it needs the row height to use for drawing row content.
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kRowHeight;
} // pickerView:rowHeightForComponent:

// Called by the picker view when it needs the row width to use for drawing row content.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat width;
    
    switch ([self typeOfComponent:component]) {
        case ComponentTypeYear:
            width = self.componentWidthYear;
            break;
        case ComponentTypeMonth:
            width = self.componentWidthMonth;
            break;
        case ComponentTypeDay:
            width = self.componentWidthDay;
            break;
        case ComponentTypeHour:
            width = self.componentWidthHour;
            break;
        case ComponentTypeMinute:
            width = self.componentWidthMinute;
            break;
        case ComponentTypeSeparator:
        default:
            width = kComponentWidthSeparator;
            break;
    }
    
    return width;
} // pickerView:widthForComponent:

// Called by the picker view when it needs the title to use for a given row in a given component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    ComponentType componentType = [self typeOfComponent:component];
    NSInteger rowValue = [self valueAtRow:row forComponentType:componentType];
    
    switch (componentType) {
        case ComponentTypeYear:
            title = [NSString stringWithFormat:@"%d%@", rowValue, kTextYear];
            break;
        case ComponentTypeMonth:
            title = [NSString stringWithFormat:@"%d%@", rowValue, kTextMonth];
            break;
        case ComponentTypeDay:
            title = [NSString stringWithFormat:@"%d%@", rowValue, kTextDay];
            break;
        case ComponentTypeHour:
            title = [NSString stringWithFormat:@"%d%@", rowValue, kTextHour];
            break;
        case ComponentTypeMinute:
            title = [NSString stringWithFormat:@"%d%@", rowValue, kTextMinute];
            break;
        case ComponentTypeSeparator:
        default:
            title = kTextSeparator;
            break;
    }
    
    return title;
} // pickerView:titleForRow:forComponent:

// Called by the picker view when it needs the view to use for a given row in a given component.
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *cellView = (UILabel *)view;
    if (cellView == nil) {
        cellView = [[UILabel alloc] init];
        cellView.font = [UIFont boldSystemFontOfSize:kFontSize];
        cellView.backgroundColor = [UIColor clearColor];
    }
    
    CGFloat componentWidth = [self pickerView:pickerView widthForComponent:component];
    cellView.frame = CGRectMake(0, 0, componentWidth-kCellMargin*2, kRowHeight);
    
    switch ([self typeOfComponent:component]) {
        case ComponentTypeYear:
            cellView.textAlignment = NSTextAlignmentRight;
            cellView.textColor = [self textColorOfYearCellForRow:row];
            break;
        case ComponentTypeMonth:
            cellView.textAlignment = NSTextAlignmentRight;
            cellView.textColor = [self textColorOfMonthCellForRow:row forComponent:component];
            break;
        case ComponentTypeDay:
            cellView.textAlignment = NSTextAlignmentRight;
            cellView.textColor = [self textColorOfDayCellForRow:row forComponent:component];
            break;
        case ComponentTypeHour:
            cellView.textAlignment = NSTextAlignmentRight;
            cellView.textColor = [self textColorOfHourCellForRow:row forComponent:component];
            break;
        case ComponentTypeMinute:
            cellView.textAlignment = NSTextAlignmentRight;
            cellView.textColor = [self textColorOfMinuteCellForRow:row forComponent:component];
            break;
        case ComponentTypeSeparator:
        default:
            cellView.textAlignment = NSTextAlignmentCenter;
            cellView.textColor = [UIColor blackColor];
            break;
    }
    
    cellView.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return cellView;
} // pickerView:viewForRow:forComponent:reusingView:

// Called by the picker view when the user selects a row in a component.
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    DatePickerData *data = [self dataAtComponent:component];
    DatePickerData *originalData = [data copy];
    NSInteger unit = [self unitOfComponent:component];
    NSInteger monthComponent = [self componentOfType:ComponentTypeMonth inUnit:unit];
    NSInteger dayComponent = [self componentOfType:ComponentTypeDay inUnit:unit];
    NSInteger hourComponent = [self componentOfType:ComponentTypeHour inUnit:unit];
    NSInteger minuteComponent = [self componentOfType:ComponentTypeMinute inUnit:unit];
    NSInteger monthRowOffset = 0;
    NSInteger dayRowOffset = 0;
    NSInteger hourRowOffset = 0;
    NSInteger minuteRowOffset = 0;
    
    NSInteger newRow, rowValue;
    ComponentType componentType = [self typeOfComponent:component];
    switch (componentType) {
        case ComponentTypeYear: {
            rowValue = [self valueAtRow:row forComponentType:ComponentTypeYear];
            data.year = rowValue;
            if (monthComponent < 0) {
                break;
            }
        }
        case ComponentTypeMonth: {
            if (componentType == ComponentTypeMonth) {
                rowValue = [self valueAtRow:row forComponentType:ComponentTypeMonth];
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeMonth];
                [self selectRow:newRow inComponent:monthComponent animated:NO];
                data.month = rowValue;
            } else {
                [self reloadComponent:monthComponent];
                rowValue = data.month;
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeMonth];
                [self selectRow:newRow inComponent:monthComponent animated:NO];
            }
            
            monthRowOffset = [self rowOffsetOfMonthComponentWithDatePickerData:data];
            if (monthRowOffset) {
                [self selectRow:newRow+monthRowOffset inComponent:monthComponent animated:YES];
            }
            data.month += monthRowOffset;
            if (dayComponent < 0) {
                break;
            }
        }
        case ComponentTypeDay: {
            if (componentType == ComponentTypeDay) {
                rowValue = [self valueAtRow:row forComponentType:ComponentTypeDay];
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeDay];
                [self selectRow:newRow inComponent:dayComponent animated:NO];
                data.day = rowValue;
            } else {
                [self reloadComponent:dayComponent];
                rowValue = data.day;
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeDay];
                [self selectRow:newRow inComponent:dayComponent animated:NO];
            }
            
            dayRowOffset = [self rowOffsetOfDayComponentWithDatePickerData:data];
            if (dayRowOffset) {
                [self selectRow:newRow+dayRowOffset inComponent:dayComponent animated:YES];
            }
            data.day += dayRowOffset;
            if (hourComponent < 0) {
                break;
            }
        }
        case ComponentTypeHour:{
            if (componentType == ComponentTypeHour) {
                rowValue = [self valueAtRow:row forComponentType:ComponentTypeHour];
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeHour];
                [self selectRow:newRow inComponent:hourComponent animated:NO];
                data.hour = rowValue;
            } else {
                [self reloadComponent:hourComponent];
                rowValue = data.hour;
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeHour];
                [self selectRow:newRow inComponent:hourComponent animated:NO];
            }
            
            hourRowOffset = [self rowOffsetOfHourComponentWithDatePickerData:data];
            if (hourRowOffset) {
                [self selectRow:newRow+hourRowOffset inComponent:hourComponent animated:YES];
            }
            data.hour += hourRowOffset;
            if (minuteComponent < 0) {
                break;
            }
        }
        case ComponentTypeMinute:{
            if (componentType == ComponentTypeMinute) {
                rowValue = [self valueAtRow:row forComponentType:ComponentTypeMinute];
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeMinute];
                [self selectRow:newRow inComponent:minuteComponent animated:NO];
                data.minute = rowValue;
            } else {
                [self reloadComponent:minuteComponent];
                rowValue = data.minute;
                newRow = [self rowOfValue:rowValue forComponentType:ComponentTypeMinute];
                [self selectRow:newRow inComponent:minuteComponent animated:NO];
            }
            
            minuteRowOffset = [self rowOffsetOfMinuteComponentWithDatePickerData:data];
            if (minuteRowOffset) {
                [self selectRow:newRow+minuteRowOffset inComponent:minuteComponent animated:YES];
            }
            data.minute += minuteRowOffset;
            break;
        }
        case ComponentTypeSeparator:
        default:
            break;
    }
    
    if (![data isEqual:originalData]) {
        _changedUnit = unit;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark -
#pragma mark Methods From UIPickerViewDataSource
// Called by the picker view when it needs the number of components. (required)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.unitCount*([self componentCountInUnit]+1)-1;
} // numberOfComponentsInPickerView:

// Called by the picker view when it needs the number of rows for a specified component. (required)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger rowCount;
    
    switch ([self typeOfComponent:component]) {
        case ComponentTypeYear:
            rowCount = [self rowCountForYearComponent];
            break;
        case ComponentTypeMonth:
        case ComponentTypeDay:
        case ComponentTypeHour:
        case ComponentTypeMinute:
            rowCount = kLoopRowCount;
            break;
        case ComponentTypeSeparator:
        default:
            rowCount = 1;
            break;
    }

    return rowCount;
} // pickerView:numberOfRowsInComponent:

#pragma mark -
#pragma mark Property Methods
- (void)setUnitCount:(NSUInteger)unitCount {
    unitCount = unitCount > 0 ? unitCount : 1;
    
    NSUInteger unitCountOld = self.unitCount;
    if (unitCount < unitCountOld) {
        while (self.unitCount != unitCount) {
            [self.datePickerDataArray removeLastObject];
        }
    } else if (unitCount > unitCountOld) {
        while (self.unitCount != unitCount) {
            DatePickerData *data = [[DatePickerData alloc] init];
            [self.datePickerDataArray addObject:data];
        }
    }
    
    if (unitCount != unitCountOld) {
        [self adjustViewSize];
        [self reloadDataWithDelay];
    }
} // setUnitCount:

- (NSUInteger)unitCount {
    return [self.datePickerDataArray count];
} // unitCount

- (NSArray *)datePickerDataArray {
    if (_datePickerDataArray == nil) {
        _datePickerDataArray = [[NSMutableArray alloc] init];
        DatePickerData *data = [[DatePickerData alloc] init];
        [_datePickerDataArray addObject:data];
    }
    
    return _datePickerDataArray;
} // datePickerDataArray

- (NSDate *)maximumDate {
    if (_maximumDate == nil) {
        [self setDateRangeFrom:_minimumDate to:_maximumDate];
    }
    
    return _maximumDate;
}

- (NSDate *)minimumDate {
    if (_minimumDate == nil) {
        [self setDateRangeFrom:_minimumDate to:_maximumDate];
    }
    
    return _minimumDate;
}

- (void)setDatePickerViewMode:(SJTDatePickerViewMode)datePickerViewMode {
    if (self.datePickerViewMode != datePickerViewMode) {
        _datePickerViewMode = datePickerViewMode;
        
        switch (_datePickerViewMode) {
            case SJTDatePickerViewModeMinute:
                break;
            case SJTDatePickerViewModeHour:
                for (DatePickerData *datePickerData in self.datePickerDataArray) {
                    datePickerData.minute = 0;
                }
                break;
            case SJTDatePickerViewModeDay:
                for (DatePickerData *datePickerData in self.datePickerDataArray) {
                    datePickerData.minute = 0;
                    datePickerData.hour = 0;
                }
                break;
            case SJTDatePickerViewModeMonth:
                for (DatePickerData *datePickerData in self.datePickerDataArray) {
                    datePickerData.minute = 0;
                    datePickerData.hour = 0;
                    datePickerData.day = 1;
                }
                break;
            case SJTDatePickerViewModeYear:
                for (DatePickerData *datePickerData in self.datePickerDataArray) {
                    datePickerData.minute = 0;
                    datePickerData.hour = 0;
                    datePickerData.day = 1;
                    datePickerData.month = 1;
                }
                break;
            default:
                self.datePickerViewMode = SJTDatePickerViewModeMinute;
                break;
        }
        
        [self adjustViewSize];
        [self reloadDataWithDelay];
    }
} // setDatePickerViewMode:

- (SJTDatePickerViewMode)datePickerViewMode {
    switch (_datePickerViewMode) {
        case SJTDatePickerViewModeMinute:
        case SJTDatePickerViewModeHour:
        case SJTDatePickerViewModeDay:
        case SJTDatePickerViewModeMonth:
        case SJTDatePickerViewModeYear:
            break;
        default:
            self.datePickerViewMode = SJTDatePickerViewModeMinute;
            break;
    }
    
    return _datePickerViewMode;
} // datePickerViewMode

- (void)setNeedAdjustViewScale:(BOOL)need {
    _needAdjustViewScale = need;
    if (self.needAdjustViewScale) {
        [self setNeedsLayout];
    }
} // setNeedAdjustViewScale:

#pragma mark -
#pragma mark Public Methods
- (void)setDateRangeFrom:(NSDate *)startDate to:(NSDate *)endDate {
    if (startDate == nil || endDate == nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDateFormat];
        
        if (startDate == nil) {
            startDate = [dateFormatter dateFromString:kMinimumDateString];
        }
        if (endDate == nil) {
            endDate = [dateFormatter dateFromString:kMaximumDateString];
        }
        if ([startDate compare:endDate] == NSOrderedDescending) {
            startDate = [dateFormatter dateFromString:kMinimumDateString];
            endDate = [dateFormatter dateFromString:kMaximumDateString];
        }
    }
    
    if (_minimumDate != startDate) {
        _minimumDate = startDate;
    }
    
    if (_maximumDate != endDate) {
        _maximumDate = endDate;
    }
    
    for (DatePickerData *data in self.datePickerDataArray) {
        data.date = [DatePickerData validateDate:data.date inRangeFrom:_minimumDate to:_maximumDate];
    }
    
    [self reloadDataWithDelay];
} // setDateRangeFrom:to:

- (void)setDate:(NSDate *)date inUnit:(NSUInteger)unit {
    if (unit < self.unitCount) {
        DatePickerData *data = (DatePickerData *)[self.datePickerDataArray objectAtIndex:unit];
        data.date = [DatePickerData validateDate:date inRangeFrom:self.minimumDate to:self.maximumDate];
        [self reloadDataInUnit:unit animated:NO];
    }
} // setDate:InUnit:

- (NSDate *)getDateInUnit:(NSUInteger)unit {
    NSDate *date = nil;
    if (unit < self.unitCount) {
        DatePickerData *data = [self.datePickerDataArray objectAtIndex:unit];
        date = data.date;
    }
    return date;
} // getDateInUnit:

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (self.eventObserverDictionary == nil) {
        self.eventObserverDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    if (target&&action) {
        NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:action];
        if (methodSignature) {
            switch (methodSignature.numberOfArguments) {
                case 3: {
                    const char *argumentType = [methodSignature getArgumentTypeAtIndex:2];
                    if (strcmp(@encode(id), argumentType)) {
                        break;
                    }
                }
                case 2: {
                    SJTEventObserver *eventObserver = [[SJTEventObserver alloc] init];
                    eventObserver.target = target;
                    eventObserver.action = action;
                    NSMutableArray *eventObserverArray = self.eventObserverDictionary[@(controlEvents)];
                    if (eventObserverArray) {
                        eventObserverArray[eventObserverArray.count] = eventObserver;
                    } else {
                        self.eventObserverDictionary[@(controlEvents)] = [NSMutableArray arrayWithObject:eventObserver];
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (self.eventObserverDictionary) {
        if (target) {
            NSMutableArray *eventObserverArray = self.eventObserverDictionary[@(controlEvents)];
            if (eventObserverArray) {
                NSMutableArray *deleteArray = [NSMutableArray array];
                for (SJTEventObserver *eventObserver in eventObserverArray) {
                    if (eventObserver.target==target&&(action==NULL||eventObserver.action==action)) {
                        deleteArray[deleteArray.count] = eventObserver;
                    }
                }
                [eventObserverArray removeObjectsInArray:deleteArray];
            }
        } else {
            [self.eventObserverDictionary removeAllObjects];
        }
    }
}

#pragma mark -
#pragma mark Private Methods
- (NSInteger)componentCountInUnit {
    NSInteger count;
    switch (self.datePickerViewMode) {
        case SJTDatePickerViewModeMinute:
            count = 5;
            break;
        case SJTDatePickerViewModeHour:
            count = 4;
            break;
        case SJTDatePickerViewModeDay:
            count = 3;
            break;
        case SJTDatePickerViewModeMonth:
            count = 2;
            break;
        case SJTDatePickerViewModeYear:
        default:
            count = 1;
            break;
    }
    
    return count;
} // componentCountInUnit

- (ComponentType)typeOfComponent:(NSInteger)component {
    ComponentType type = component%([self componentCountInUnit]+1);
    if (type == [self componentCountInUnit]) {
        type = ComponentTypeSeparator;
    }
    
    return type;
} // typeOfComponent

- (NSUInteger)unitOfComponent:(NSInteger)component {
    return component/([self componentCountInUnit]+1);
} // unitOfComponent:

- (NSInteger)componentOfType:(ComponentType)type inUnit:(NSUInteger)unit {
    NSInteger component;
    
    if (unit >= self.unitCount) {
        component = -1;
    } else {
        NSInteger countInUnit = [self componentCountInUnit];
        if (type < countInUnit) {
            component = unit*(countInUnit+1)+type;
        } else {
            component = -1;
        }
    }
    
    return component;
} // componentOfType:inUnit:

- (UIColor *)textColorOfYearCellForRow:(NSInteger)row {
    UIColor *color;
    NSInteger year = [self valueAtRow:row forComponentType:ComponentTypeYear];
    if (year == [[DatePickerData componentsOfDate:[NSDate date]] year]) {
        color = [UIColor blueColor];
    } else {
        color = [UIColor blackColor];
    }
    return color;
} // textColorOfYearCellForRow:

- (UIColor *)textColorOfMonthCellForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *color;
    NSInteger month = [self valueAtRow:row forComponentType:ComponentTypeMonth];
    DatePickerData *data = [self dataAtComponent:component];
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    if ((data.year == [minimumDateComponents year] && month < [minimumDateComponents month]) ||
        (data.year == [maximumDateComponents year] && month > [maximumDateComponents month])) {
        color = [UIColor grayColor];
    } else if (month == [[DatePickerData componentsOfDate:[NSDate date]] month]) {
        color = [UIColor blueColor];
    } else {
        color = [UIColor blackColor];
    }
    return color;
} // textColorOfMonthCellForRow:forComponent:

- (UIColor *)textColorOfDayCellForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *color;
    NSInteger day = [self valueAtRow:row forComponentType:ComponentTypeDay];
    DatePickerData *data = [[self dataAtComponent:component] copy];
    data.day = 1;
    NSRange dayRange = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:data.date];
    if (day > dayRange.location+dayRange.length-1) {
        color = [UIColor grayColor];
    } else {
        NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
        NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
        if ((data.year == [minimumDateComponents year] &&
             data.month == [minimumDateComponents month] &&
             day < [minimumDateComponents day]) ||
            (data.year == [maximumDateComponents year] &&
             data.month == [maximumDateComponents month] &&
             day > [maximumDateComponents day])) {
            color = [UIColor grayColor];
        } else if (day == [[DatePickerData componentsOfDate:[NSDate date]] day]) {
            color = [UIColor blueColor];
        } else {
            color = [UIColor blackColor];
        }
    }
    return color;
} // textColorOfDayCellForRow:forComponent:

- (UIColor *)textColorOfHourCellForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *color;
    NSInteger hour = [self valueAtRow:row forComponentType:ComponentTypeHour];
    DatePickerData *data = [self dataAtComponent:component];
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    if ((data.year == [minimumDateComponents year] &&
         data.month == [minimumDateComponents month] &&
         data.day == [minimumDateComponents day] &&
         hour < [minimumDateComponents hour]) ||
        (data.year == [maximumDateComponents year] &&
         data.month == [maximumDateComponents month] &&
         data.day == [maximumDateComponents day] &&
         hour > [maximumDateComponents hour])) {
        color = [UIColor grayColor];
    } else {
        if (hour == [[DatePickerData componentsOfDate:[NSDate date]] hour]) {
            color = [UIColor blueColor];
        } else {
            color = [UIColor blackColor];
        }
    }
    return color;
} // textColorOfHourCellForRow:forComponent:

- (UIColor *)textColorOfMinuteCellForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIColor *color;
    NSInteger minute = [self valueAtRow:row forComponentType:ComponentTypeMinute];
    DatePickerData *data = [self dataAtComponent:component];
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    if ((data.year == [minimumDateComponents year] &&
         data.month == [minimumDateComponents month] &&
         data.day == [minimumDateComponents day] &&
         data.hour == [minimumDateComponents hour] &&
         minute < [minimumDateComponents minute]) ||
        (data.year == [maximumDateComponents year] &&
         data.month == [maximumDateComponents month] &&
         data.day == [maximumDateComponents day] &&
         data.hour == [maximumDateComponents hour] &&
         minute > [maximumDateComponents minute])) {
            color = [UIColor grayColor];
        } else {
            if (minute == [[DatePickerData componentsOfDate:[NSDate date]] minute]) {
                color = [UIColor blueColor];
            } else {
                color = [UIColor blackColor];
            }
        }
    return color;
} // textColorOfMinuteCellForRow:forComponent:

- (DatePickerData *)dataAtComponent:(NSInteger)component {
    return [self.datePickerDataArray objectAtIndex:(component / ([self componentCountInUnit] + 1))];
} // dataAtComponent:

- (NSInteger)rowOffsetOfMonthComponentWithDatePickerData:(DatePickerData *)data {
    NSInteger rowOffset = 0;
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    
    if (data.year == [minimumDateComponents year] && 
        data.month < [minimumDateComponents month]) {
        rowOffset = [minimumDateComponents month] - data.month;
    } else if (data.year == [maximumDateComponents year] && 
               data.month > [maximumDateComponents month]) {
        rowOffset = [maximumDateComponents month] - data.month;
    }
    
    return rowOffset;
} // rowOffsetOfMonthComponentWithDatePickerData:

- (NSInteger)rowOffsetOfDayComponentWithDatePickerData:(DatePickerData *)data {
    NSInteger rowOffset = 0;
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    
    if (data.year == [minimumDateComponents year] &&
        data.month == [minimumDateComponents month] &&
        data.day < [minimumDateComponents day]) {
        rowOffset = [minimumDateComponents day] - data.day;
    } else if (data.year == [maximumDateComponents year] &&
               data.month == [maximumDateComponents month] &&
               data.day > [maximumDateComponents day]) {
        rowOffset = [maximumDateComponents day] - data.day;
    } else {
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setCalendar:[NSCalendar currentCalendar]];
        [dateComponents setYear:data.year];
        [dateComponents setMonth:data.month];
        NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[dateComponents date]];
        if (data.day > range.location+range.length-1) {
            rowOffset = range.location+range.length-1-data.day;
        }
    }
    
    return rowOffset;
} // rowOffsetOfDayComponentWithDatePickerData:

- (NSInteger)rowOffsetOfHourComponentWithDatePickerData:(DatePickerData *)data {
    NSInteger rowOffset = 0;
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    
    if (data.year == [minimumDateComponents year] &&
        data.month == [minimumDateComponents month] &&
        data.day == [minimumDateComponents day] &&
        data.hour < [minimumDateComponents hour]) {
        rowOffset = [minimumDateComponents hour] -data.hour;
    } else if (data.year == [maximumDateComponents year] &&
               data.month == [maximumDateComponents month] &&
               data.day == [maximumDateComponents day] &&
               data.hour > [maximumDateComponents hour]) {
        rowOffset = [maximumDateComponents hour] -data.hour;
    }
    
    return rowOffset;
} // rowOffsetOfHourComponentWithDatePickerData:

- (NSInteger)rowOffsetOfMinuteComponentWithDatePickerData:(DatePickerData *)data {
    NSInteger rowOffset = 0;
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    
    if (data.year == [minimumDateComponents year] &&
        data.month == [minimumDateComponents month] &&
        data.day == [minimumDateComponents day] &&
        data.hour == [minimumDateComponents hour] &&
        data.minute < [minimumDateComponents minute]) {
        rowOffset = [minimumDateComponents minute] -data.minute;
    } else if (data.year == [maximumDateComponents year] &&
               data.month == [maximumDateComponents month] &&
               data.day == [maximumDateComponents day] &&
               data.hour == [maximumDateComponents hour] &&
               data.minute > [maximumDateComponents minute]) {
        rowOffset = [maximumDateComponents minute] -data.minute;
    }
    
    return rowOffset;
} // rowOffsetOfMinuteComponentWithDatePickerData:

- (NSInteger)rowCountForYearComponent {
    NSDateComponents *minimumDateComponents = [DatePickerData componentsOfDate:self.minimumDate];
    NSDateComponents *maximumDateComponents = [DatePickerData componentsOfDate:self.maximumDate];
    return [maximumDateComponents year] - [minimumDateComponents year] + 1;
} // rowCountForYearComponent

- (NSInteger)valueAtRow:(NSInteger)row forComponentType:(ComponentType)type {
    NSInteger value;
    switch (type) {
        case ComponentTypeYear:
            value = [[DatePickerData componentsOfDate:self.minimumDate] year] + row;
            break;
        case ComponentTypeMonth:
            value = row%12+1;
            break;
        case ComponentTypeDay:
            value = row%31+1;
            break;
        case ComponentTypeHour:
            value = row%24;
            break;
        case ComponentTypeMinute:
        default:
            value = row%60;
            break;
    }
    
    return value;
} // valueAtRow:forComponentType:

- (NSInteger)rowOfValue:(NSInteger)value forComponentType:(ComponentType)type {
    NSInteger row;
    switch (type) {
        case ComponentTypeYear:
            row = value - [[DatePickerData componentsOfDate:self.minimumDate] year];
            break;
        case ComponentTypeMonth:
            row = kLoopRowCount/2;
            row -= row%12;
            row += value-1;
            break;
        case ComponentTypeDay:
            row = kLoopRowCount/2;
            row -= row%31;
            row += value-1;
            break;
        case ComponentTypeHour:
            row = kLoopRowCount/2;
            row -= row%24;
            row += value;
            break;
        case ComponentTypeMinute:
        default:
            row = kLoopRowCount/2;
            row -= row%60;
            row += value;
            break;
    }
    
    return row;
} // rowOfValue:forComponentType:

- (void)reloadDataInUnit:(NSUInteger)unit animated:(BOOL)animated {
    if (unit < self.unitCount) {
        DatePickerData *data = [self.datePickerDataArray objectAtIndex:unit];
        NSInteger component, row;
        switch (self.datePickerViewMode) {
            case SJTDatePickerViewModeMinute:
                component = [self componentOfType:ComponentTypeMinute inUnit:unit];
                row = [self rowOfValue:data.minute forComponentType:ComponentTypeMinute];
                [self selectRow:row inComponent:component animated:animated];
            case SJTDatePickerViewModeHour:
                component = [self componentOfType:ComponentTypeHour inUnit:unit];
                row = [self rowOfValue:data.hour forComponentType:ComponentTypeHour];
                [self selectRow:row inComponent:component animated:animated];
            case SJTDatePickerViewModeDay:
                component = [self componentOfType:ComponentTypeDay inUnit:unit];
                row = [self rowOfValue:data.day forComponentType:ComponentTypeDay];
                [self selectRow:row inComponent:component animated:animated];
            case SJTDatePickerViewModeMonth:
                component = [self componentOfType:ComponentTypeMonth inUnit:unit];
                row = [self rowOfValue:data.month forComponentType:ComponentTypeMonth];
                [self selectRow:row inComponent:component animated:animated];
            case SJTDatePickerViewModeYear:
                component = [self componentOfType:ComponentTypeYear inUnit:unit];
                row = [self rowOfValue:data.year forComponentType:ComponentTypeYear];
                [self selectRow:row inComponent:component animated:animated];
            default:
                break;
        }
    }
} // reloadDate:inUnit:animated:

- (void)reloadDataWithDelay {
    BOOL animated = NO;
    SEL sel = @selector(reloadDataWithAnimated:);
    NSMethodSignature *methodSignature = [self.class instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = sel;
    invocation.target = self;
    [invocation setArgument:&animated atIndex:2];
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0.1];
}

- (void)reloadDataWithAnimated:(BOOL)animated {
    for (NSInteger i = 0; i < self.unitCount; i++) {
        [self reloadDataInUnit:i animated:NO];
    }
}

- (void)adjustViewSize {
    CGSize viewSize;
    NSInteger unitCount = self.unitCount;
    viewSize.width = kViewMargin*2+(kComponentWidthSeparator+kComponentMargin*2)*(unitCount-1);
    switch (self.datePickerViewMode) {
        case SJTDatePickerViewModeMinute:
            viewSize.width += (kComponentWidthMinute+kComponentMargin*2)*unitCount;
        case SJTDatePickerViewModeHour:
            viewSize.width += (kComponentWidthHour+kComponentMargin*2)*unitCount;
        case SJTDatePickerViewModeDay:
            viewSize.width += (kComponentWidthDay+kComponentMargin*2)*unitCount;
        case SJTDatePickerViewModeMonth:
            viewSize.width += (kComponentWidthMonth+kComponentMargin*2)*unitCount;
        case SJTDatePickerViewModeYear:
        default:
            viewSize.width += (kComponentWidthYear+kComponentMargin*2)*unitCount;
    }
    
    
    CGFloat scale;
    if (viewSize.width > self.userFrame.size.width) {
        scale = self.userFrame.size.width/viewSize.width;
    } else {
        scale = 1;
    }
    
    if (self.userFrame.size.height <= kViewMinimumHeight*scale) {
        viewSize.height = kViewMinimumHeight;
        scale = self.userFrame.size.height / viewSize.height;
    } else if (self.userFrame.size.height <= kViewMediumHeight*scale) {
        viewSize.height = kViewMediumHeight;
        scale = self.userFrame.size.height / viewSize.height;
    } else if (self.userFrame.size.height <= kViewMaximumHeight*scale) {
        viewSize.height = kViewMaximumHeight;
        scale = self.userFrame.size.height / viewSize.height;
    } else {
        viewSize.height = kViewMaximumHeight;
    }
    
    viewSize.width = self.userFrame.size.width/scale;
    
    self.adjustedSize = viewSize;
    [self adjustComponentsWidth];
    
    self.transform = CGAffineTransformIdentity;
    CGRect viewFrame;
    viewFrame.origin = self.userFrame.origin;
    viewFrame.size = self.adjustedSize;
    super.frame = viewFrame;

    self.needAdjustViewScale = YES;
} // adjustViewFrame

- (void)adjustComponentsWidth {
    CGFloat adaptingAreaWidth = self.adjustedSize.width - kViewMargin*2;
    CGFloat standardWidth;
    
    adaptingAreaWidth -= (kComponentWidthSeparator+kComponentMargin*2)*(self.unitCount-1);
    adaptingAreaWidth /= self.unitCount;
    
    switch (self.datePickerViewMode) {
        case SJTDatePickerViewModeMinute:
            adaptingAreaWidth -= kComponentMargin*2*5;
            standardWidth = kComponentWidthYear + kComponentWidthMonth + kComponentWidthDay + kComponentWidthHour + kComponentWidthMinute;
            self.componentWidthYear = adaptingAreaWidth*kComponentWidthYear/standardWidth;
            self.componentWidthMonth = adaptingAreaWidth*kComponentWidthMonth/standardWidth;
            self.componentWidthDay = adaptingAreaWidth*kComponentWidthDay/standardWidth;
            self.componentWidthHour = adaptingAreaWidth*kComponentWidthHour/standardWidth;
            self.componentWidthMinute = adaptingAreaWidth*kComponentWidthMinute/standardWidth;
            break;
        case SJTDatePickerViewModeHour:
            adaptingAreaWidth -= kComponentMargin*2*4;
            standardWidth = kComponentWidthYear + kComponentWidthMonth + kComponentWidthDay + kComponentWidthHour;
            self.componentWidthYear = adaptingAreaWidth*kComponentWidthYear/standardWidth;
            self.componentWidthMonth = adaptingAreaWidth*kComponentWidthMonth/standardWidth;
            self.componentWidthDay = adaptingAreaWidth*kComponentWidthDay/standardWidth;
            self.componentWidthHour = adaptingAreaWidth*kComponentWidthHour/standardWidth;
            self.componentWidthMinute = 0;
            break;
        case SJTDatePickerViewModeDay:
            adaptingAreaWidth -= kComponentMargin*2*3;
            standardWidth = kComponentWidthYear + kComponentWidthMonth + kComponentWidthDay;
            self.componentWidthYear = adaptingAreaWidth*kComponentWidthYear/standardWidth;
            self.componentWidthMonth = adaptingAreaWidth*kComponentWidthMonth/standardWidth;
            self.componentWidthDay = adaptingAreaWidth*kComponentWidthDay/standardWidth;
            self.componentWidthHour = 0;
            self.componentWidthMinute = 0;
            break;
        case SJTDatePickerViewModeMonth:
            adaptingAreaWidth -= kComponentMargin*2*2;
            standardWidth = kComponentWidthYear + kComponentWidthMonth;
            self.componentWidthYear = adaptingAreaWidth*kComponentWidthYear/standardWidth;
            self.componentWidthMonth = adaptingAreaWidth*kComponentWidthMonth/standardWidth;
            self.componentWidthDay = 0;
            self.componentWidthHour = 0;
            self.componentWidthMinute = 0;
            break;
        case SJTDatePickerViewModeYear:
        default:
            adaptingAreaWidth -= kComponentMargin*2*1;
            self.componentWidthYear = adaptingAreaWidth;
            self.componentWidthMonth = 0;
            self.componentWidthDay = 0;
            self.componentWidthHour = 0;
            self.componentWidthMinute = 0;
            break;
    }
}

- (void)adjustViewScale {
    CGFloat scale = self.userFrame.size.width/self.adjustedSize.width;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation((scale-1)*self.adjustedSize.width/2, (scale-1)*self.adjustedSize.height/2);
    CGAffineTransform concatTransform = CGAffineTransformConcat (scaleTransform,translationTransform);
    self.transform = concatTransform;
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    if (self.eventObserverDictionary) {
        NSArray *eventObserverArray = self.eventObserverDictionary[@(controlEvents)];
        if (eventObserverArray) {
            for (SJTEventObserver *eventObserver in eventObserverArray) {
                NSMethodSignature *methodSignature = [[eventObserver.target class] instanceMethodSignatureForSelector:eventObserver.action];
                if (methodSignature) {
                    switch (methodSignature.numberOfArguments) {
                        case 2:
                            objc_msgSend(eventObserver.target, eventObserver.action, self);
                            break;
                        case 3:
                            objc_msgSend(eventObserver.target, eventObserver.action);
                            break;
                    }
                }
            }
        }
    }
}

@end
