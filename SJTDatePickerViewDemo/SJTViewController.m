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
@property (strong, nonatomic) UIStepper *stepper;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UISlider *verticalSlider;
@property (strong, nonatomic) UISlider *horizontalSlider;
@property (strong, nonatomic) UIView *globalView;
@property (strong, nonatomic) UIView *localView;
@property (strong, nonatomic) SJTDatePickerView *datePickerView;
- (void)actionFromStepper;
- (void)actionFromSegmentedControl;
- (void)actionFromHorizontalSlider;
- (void)actionFromVerticalSlider;
- (void)actionFromDatePickerView;
@end

@implementation SJTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.stepper = [[UIStepper alloc] init];
    self.stepper.minimumValue = 1;
    [self.stepper addTarget:self action:@selector(actionFromStepper) forControlEvents:UIControlEventValueChanged];
    
    self.label = [[UILabel alloc] init];
    self.label.adjustsFontSizeToFitWidth = YES;
    
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
    
    self.datePickerView = [[SJTDatePickerView alloc] init];
    self.datePickerView.datePickerViewMode = SJTDatePickerViewModeYear;
    self.datePickerView.unitCount = 1;
    [self.datePickerView addTarget:self action:@selector(actionFromDatePickerView) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.stepper];
    [self.view addSubview:self.label];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.horizontalSlider];
    [self.view addSubview:self.verticalSlider];
    [self.view addSubview:self.globalView];
    [self.globalView addSubview:self.localView];
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
    CGRect stepperFrame = self.stepper.bounds;
    stepperFrame.origin = CGPointMake(5, 5);
    
    CGRect segmentedControlFrame = self.segmentedControl.bounds;
    segmentedControlFrame.origin.x = 5+CGRectGetMaxX(stepperFrame);
    segmentedControlFrame.origin.y = 5;
    
    CGRect labelFrame;
    labelFrame.origin.x = 5;
    labelFrame.origin.y = CGRectGetMaxY(stepperFrame)+5;
    labelFrame.size.width = stepperFrame.size.width;
    labelFrame.size.height = segmentedControlFrame.size.height-stepperFrame.size.height;
    
    CGRect horizontalSliderFrame = self.horizontalSlider.bounds;
    horizontalSliderFrame.origin.x = 5+horizontalSliderFrame.size.height;
    horizontalSliderFrame.origin.y = CGRectGetMaxY(segmentedControlFrame)+5;
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
    
    CGRect localViewFrame = CGRectZero;
    localViewFrame.size.width = globalViewFrame.size.width*self.horizontalSlider.value;
    localViewFrame.size.height = globalViewFrame.size.height*self.verticalSlider.value;
    
    self.stepper.frame = stepperFrame;
    self.label.frame = labelFrame;
    self.segmentedControl.frame = segmentedControlFrame;
    self.horizontalSlider.frame = horizontalSliderFrame;
    self.verticalSlider.transform = CGAffineTransformIdentity;
    self.verticalSlider.frame = verticalSliderFrame;
    self.verticalSlider.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    self.globalView.frame = globalViewFrame;
    self.localView.frame = localViewFrame;
    self.datePickerView.frame = self.localView.bounds;
}

- (void)actionFromStepper {
    self.datePickerView.unitCount = self.stepper.value;
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
    CGRect localViewFrame = self.localView.frame;
    localViewFrame.size.width = self.globalView.bounds.size.width*self.horizontalSlider.value;
    self.localView.frame = localViewFrame;
    self.datePickerView.frame = self.localView.bounds;
    
    NSLog(@"ParentView:%@", NSStringFromCGRect(localViewFrame));
    NSLog(@"DatePickerView:%@", NSStringFromCGRect(self.datePickerView.frame));
}

- (void)actionFromVerticalSlider {
    CGRect localViewFrame = self.localView.frame;
    localViewFrame.size.height = self.globalView.bounds.size.height*self.verticalSlider.value;
    self.localView.frame = localViewFrame;
    self.datePickerView.frame = self.localView.bounds;
    
    NSLog(@"ParentView:%@", NSStringFromCGRect(localViewFrame));
    NSLog(@"DatePickerView:%@", NSStringFromCGRect(self.datePickerView.frame));
}

- (void)actionFromDatePickerView {
    NSDate *date = [self.datePickerView getDateInUnit:self.datePickerView.changedUnit];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar currentCalendar];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    self.label.text = [dateFormatter stringFromDate:date];
}

@end
