//
//  SJTViewController.m
//  SJTDatePickerViewDemo
//
//  Created by Jqgsninimo on 12-12-4.
//  Copyright (c) 2012年 SJT. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SJTViewController.h"
#import "SJTDatePickerView.h"

@interface SJTDateFormater : NSObject
@property (assign) NSInteger yearIndex;
@property (assign) NSInteger monthIndex;
@property (assign) NSInteger dayIndex;
@property (assign) NSInteger hourIndex;
@property (assign) NSInteger minuteIndex;
@property (assign) NSInteger secondIndex;
@property (assign) NSArray *formatArray;
- (id)initWithString:(NSString *)string;
@end


@interface SJTViewController ()
@property (strong, nonatomic) UIStepper *countStepper;
@property (strong, nonatomic) UIStepper *insetStepper;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UISlider *verticalSlider;
@property (strong, nonatomic) UISlider *horizontalSlider;
@property (strong, nonatomic) UIView *globalView;
@property (strong, nonatomic) UIView *localView;
@property (strong, nonatomic) UITextView *logView;
@property (strong, nonatomic) SJTDatePickerView *datePickerView;
- (void)actionFromStepper:(UIStepper *)sender;
- (void)actionFromSegmentedControl;
- (void)actionFromHorizontalSlider;
- (void)actionFromVerticalSlider;
- (void)actionFromDatePickerView;
- (void)adjustFrame;
- (void)logMessage:(NSString *)message;
@end

@implementation SJTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.countStepper = [[UIStepper alloc] init];
    self.countStepper.minimumValue = 1;
    [self.countStepper addTarget:self action:@selector(actionFromStepper:) forControlEvents:UIControlEventValueChanged];
    
    self.insetStepper = [[UIStepper alloc] init];
    self.insetStepper.minimumValue = 0;
    [self.insetStepper addTarget:self action:@selector(actionFromStepper:) forControlEvents:UIControlEventValueChanged];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"年",@"月",@"日",@"時",@"分"]];
    [self.segmentedControl addTarget:self action:@selector(actionFromSegmentedControl) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex =0;
    
    self.horizontalSlider = [[UISlider alloc] init];
    self.horizontalSlider.value = 1;
    [self.horizontalSlider addTarget:self action:@selector(actionFromHorizontalSlider) forControlEvents:UIControlEventValueChanged];
    
    self.verticalSlider = [[UISlider alloc] init];
    self.verticalSlider.value = 1;
    [self.verticalSlider addTarget:self action:@selector(actionFromVerticalSlider) forControlEvents:UIControlEventValueChanged];
    
    self.globalView = [[UIView alloc] init];
    self.globalView.layer.borderWidth = 1;
    
    self.localView = [[UIView alloc] init];
    self.localView.backgroundColor = [UIColor lightGrayColor];
    self.localView.layer.borderWidth = 1;
    
    self.logView = [[UITextView alloc] init];
    self.logView.editable = NO;
    
    self.datePickerView = [[SJTDatePickerView alloc] init];
    self.datePickerView.datePickerViewMode = SJTDatePickerViewModeYear;
    self.datePickerView.unitCount = 1;
    [self.datePickerView addTarget:self action:@selector(actionFromDatePickerView) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.countStepper];
    [self.view addSubview:self.insetStepper];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.horizontalSlider];
    [self.view addSubview:self.verticalSlider];
    [self.view addSubview:self.globalView];
    [self.globalView addSubview:self.localView];
    [self.globalView addSubview:self.logView];
    [self.localView addSubview:self.datePickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewWillLayoutSubviews {
    CGRect countStepperFrame = self.countStepper.bounds;
    countStepperFrame.origin = CGPointMake(5, 5);
    
    CGRect insetStepperFrame = self.insetStepper.bounds;
    insetStepperFrame.origin = CGPointMake(5, CGRectGetMaxY(countStepperFrame)+2);
    
    CGRect segmentedControlFrame = self.segmentedControl.bounds;
    segmentedControlFrame.origin.x = 5+CGRectGetMaxX(countStepperFrame);
    segmentedControlFrame.origin.y = (CGRectGetMinY(countStepperFrame)+CGRectGetMaxY(insetStepperFrame)-segmentedControlFrame.size.height)/2;
    
    CGRect horizontalSliderFrame = self.horizontalSlider.bounds;
    horizontalSliderFrame.origin.x = 5+horizontalSliderFrame.size.height;
    horizontalSliderFrame.origin.y = CGRectGetMaxY(insetStepperFrame)+5;
    horizontalSliderFrame.size.width = self.view.bounds.size.width-horizontalSliderFrame.origin.x-5;
    
    CGRect verticalSliderFrame = horizontalSliderFrame;
    verticalSliderFrame.size.width = self.view.bounds.size.height-CGRectGetMaxY(horizontalSliderFrame)-5;
    verticalSliderFrame.origin.x -= (verticalSliderFrame.size.width+verticalSliderFrame.size.height)/2;
    verticalSliderFrame.origin.y += (verticalSliderFrame.size.width+verticalSliderFrame.size.height)/2;
    
    CGRect globalViewFrame;
    globalViewFrame.origin.x = horizontalSliderFrame.origin.x;
    globalViewFrame.origin.y = CGRectGetMaxY(horizontalSliderFrame);
    globalViewFrame.size.width = horizontalSliderFrame.size.width;
    globalViewFrame.size.height = verticalSliderFrame.size.width;
    globalViewFrame = CGRectInset(globalViewFrame, 10, 10);
    
    self.countStepper.frame = countStepperFrame;
    self.insetStepper.frame = insetStepperFrame;
    self.segmentedControl.frame = segmentedControlFrame;
    self.horizontalSlider.frame = horizontalSliderFrame;
    self.verticalSlider.transform = CGAffineTransformIdentity;
    self.verticalSlider.frame = verticalSliderFrame;
    self.verticalSlider.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    self.globalView.frame = globalViewFrame;
    
    [self adjustFrame];
}

- (void)actionFromStepper:(UIStepper *)sender {
    if (sender==self.countStepper) {
        self.datePickerView.unitCount = self.countStepper.value;
        [self logMessage:[NSString stringWithFormat:@"UnitCount:%d", (NSInteger)self.countStepper.value]];
    } else {
        self.datePickerView.frame = CGRectInset(self.localView.bounds, self.insetStepper.value, self.insetStepper.value);
        [self logMessage:[NSString stringWithFormat:@"RectInset:%d", (NSInteger)self.insetStepper.value]];
    }
}

- (void)actionFromSegmentedControl {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.datePickerView.datePickerViewMode = SJTDatePickerViewModeYear;
            break;
        case 1:
            self.datePickerView.datePickerViewMode = SJTDatePickerViewModeMonth;
            break;
        case 2:
            self.datePickerView.datePickerViewMode = SJTDatePickerViewModeDay;
            break;
        case 3:
            self.datePickerView.datePickerViewMode = SJTDatePickerViewModeHour;
            break;
        case 4:
        default:
            self.datePickerView.datePickerViewMode = SJTDatePickerViewModeMinute;
            break;
    }
}

- (void)actionFromHorizontalSlider {
    [self adjustFrame];
}

- (void)actionFromVerticalSlider {
    [self adjustFrame];
}

- (void)actionFromDatePickerView {
    NSDate *date = [self.datePickerView getDateInUnit:self.datePickerView.changedUnit];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar currentCalendar];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    
    [self logMessage:[NSString stringWithFormat:@"DatePickerDate:%@", [dateFormatter stringFromDate:date]]];
}

- (void)adjustFrame {
    CGRect globalViewFrame = self.globalView.frame;
    CGRect localViewFrame = CGRectZero;
    localViewFrame.size.width = globalViewFrame.size.width*self.horizontalSlider.value;
    localViewFrame.size.height = globalViewFrame.size.height*self.verticalSlider.value;
    
    CGRect logViewFrame = CGRectZero;
    if (globalViewFrame.size.width*(globalViewFrame.size.height-localViewFrame.size.height)>
        globalViewFrame.size.height*(globalViewFrame.size.width-localViewFrame.size.width)) {
        logViewFrame.origin.y = localViewFrame.size.height;
        logViewFrame.size.width = globalViewFrame.size.width;
        logViewFrame.size.height = globalViewFrame.size.height-localViewFrame.size.height;
    } else {
        logViewFrame.origin.x = localViewFrame.size.width;
        logViewFrame.size.width = globalViewFrame.size.width-localViewFrame.size.width;
        logViewFrame.size.height = globalViewFrame.size.height;
    }
    
    self.localView.frame = localViewFrame;
    self.logView.frame = logViewFrame;
    self.datePickerView.frame = CGRectInset(self.localView.bounds, self.insetStepper.value, self.insetStepper.value);
    
    CGRect userFrame;
    SEL sel = @selector(userFrame);
    NSMethodSignature *methodSignature = [SJTDatePickerView instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = sel;
    invocation.target = self.datePickerView;
    [invocation invoke];
    [invocation getReturnValue:&userFrame];
    
    CGSize adjustedSize;
    sel = @selector(adjustedSize);
    methodSignature = [SJTDatePickerView instanceMethodSignatureForSelector:sel];
    invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = sel;
    invocation.target = self.datePickerView;
    [invocation invoke];
    [invocation getReturnValue:&adjustedSize];
    
    [self logMessage:[NSString stringWithFormat:@"Frame:%@\nBounds:%@\nUserFrame:%@\nAdjustedSize:%@",
                      NSStringFromCGRect(self.datePickerView.frame),
                      NSStringFromCGRect(self.datePickerView.bounds),
                      NSStringFromCGRect(userFrame),
                      NSStringFromCGSize(adjustedSize)]];
}

- (void)logMessage:(NSString *)message {
    self.logView.text = [NSString stringWithFormat:@"LOG[%@]:\n%@\n\n%@",
                         [NSDate date],
                         message,
                         self.logView.text];
}

@end
