//
//Copyright (c) 2012, pyanfield@gmail.com
//Extend Tim Cinel's ActionSheetPicker
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//* Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//* Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//* Neither the name of the <organization> nor the
//names of its contributors may be used to endorse or promote products
//derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ActionSheetMonthYearPicker.h"

#define YEAR_COMPONENT 0
#define MONTH_COMPONENT 1
#define AVAILABLE @"avaiblable"
#define UNAVAILABLE @"canNotSelected"
#define AVAILABLE_COLOR [UIColor blueColor]
#define UNAVAILABLE_COLOR [UIColor lightGrayColor]

@interface ActionSheetMonthYearPicker()

@property (nonatomic, retain) NSString *startDate;
@property (nonatomic, retain) NSString *endDate;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSMutableArray *years;
@property (nonatomic, retain) NSArray *months;
@property (nonatomic, retain) NSString *separator;

- (void)parseData;

@end

@implementation ActionSheetMonthYearPicker

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize data = _data;
@synthesize years = _years;
@synthesize months = _months;
@synthesize selectedData = _selectedData;
@synthesize selectedYear = _selectedYear;
@synthesize selectedMonth = _selectedMonth;
@synthesize separator = _separator;

+ (id)showPickerWithTitle:(NSString *)title start:(NSString *)start end:(NSString *)end tartget:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin
{
    ActionSheetMonthYearPicker *picker = [[ActionSheetMonthYearPicker alloc] initWithTitle:title start:start end:end tartget:target successAction:successAction cancelAction:cancelAction origin:origin];
    [picker showActionSheetPicker];
    return [picker autorelease];
}

- (id)initWithTitle:(NSString *)title start:(NSString *)start end:(NSString *)end tartget:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelAction origin:(id)origin
{
    self = [super initWithTarget:target successAction:successAction cancelAction:nil origin:origin];
    if (self) {
        self.title = title;
        _startDate = start;
        _endDate = end;
        _data = [[NSMutableArray alloc] init];
        [self parseData];
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    _data = nil;
    [_years release];
    _years = nil;
    [_selectedData release];
    _selectedData = nil;
    [super dealloc];
}

- (void)parseData
{
    // date string e.g 2012/09 or 2012.09
//    Logger(@"From   %@     --    %@",self.startDate,self.endDate);
    NSString *startYear = [self.startDate substringToIndex:4];
    NSString *endYear = [self.endDate substringToIndex:4];
    NSString *startMonth = [self.startDate substringFromIndex:5];
    NSString *endMonth = [self.endDate substringFromIndex:5];
    
    self.separator = [self.startDate substringWithRange:NSMakeRange(4, 1)];
    if (([startYear isEqualToString:endYear] && [startMonth intValue] >= [endMonth intValue]) || ([startYear intValue] > [endYear intValue])) {
        NSAssert(NO,@"Invalid start date and end date.");
    }
    self.years = [self yearsFrom:[startYear intValue] toEnd:[endYear intValue]];
    self.months = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    // set the default selected value
    self.selectedMonth = self.months[[startMonth intValue]-1];
    self.selectedYear = [self.years objectAtIndex:0];
    self.selectedData = [NSString stringWithFormat:@"%@.%@",self.selectedYear,self.selectedMonth];
    
    if ([self.years count] == 1) {
        [self.data addObject:[self monthFlagsFrom:[startMonth intValue] toEnd:[endMonth intValue]]];
        return;
    }
    if ([self.years count] > 1) {
        [self.data addObject:[self monthFlagsFrom:[startMonth intValue] toEnd:12]];
        for (int i=1; i<[endYear intValue]-[startYear intValue]; i++) {
            [self.data addObject:[self monthFlagsFrom:1 toEnd:12]];
        }
        [self.data addObject:[self monthFlagsFrom:1 toEnd:[endMonth intValue]]];
        return;
    }
}

- (NSMutableArray*)yearsFrom:(int)small toEnd:(int)big
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i=small; i<=big; i++) {
        [arr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return [arr autorelease];
}

- (NSMutableArray*)monthFlagsFrom:(int)small toEnd:(int)big
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (int i=1; i<= 12; i++) {
        if (i < small || i > big) {
            [arr addObject:UNAVAILABLE];
        }else{
            [arr addObject:AVAILABLE];
        }
    }
    
    // save the flag AVAILABLE 's start and end index
    [arr addObject:[NSNumber numberWithInt:(small-1)]];
    [arr addObject:[NSNumber numberWithInt:(big-1)]];
    return [arr autorelease];
}


- (UIView *)configuredPickerView {
    if (!self.data)
        return nil;
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
    UIPickerView *yearPicker = [[[UIPickerView alloc] initWithFrame:pickerFrame] autorelease];
    yearPicker.delegate = self;
    yearPicker.dataSource = self;
    yearPicker.showsSelectionIndicator = YES;
    self.pickerView = yearPicker;
    [yearPicker selectRow:0 inComponent:YEAR_COMPONENT animated:YES];
    [yearPicker selectRow:([[self.startDate substringFromIndex:5] intValue]-1) inComponent:MONTH_COMPONENT animated:YES];
    return yearPicker;
}

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin
{
    if ([target respondsToSelector:successAction])
        //objc_msgSend(target, successAction, self.selectedData, origin);
        [target performSelector:successAction withObject:self.selectedData];
    else
        NSAssert(NO, @"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker", object_getClassName(target), (char *)successAction);
}

-(UILabel *)componentLabel
{
    CGRect frame = CGRectMake(0.f, 0.f,self.pickerView.bounds.size.width/2,43);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = AVAILABLE_COLOR;
    label.font = [UIFont boldSystemFontOfSize:17];
    label.userInteractionEnabled = NO;
    return label;
}

#pragma mark - 
#pragma UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == YEAR_COMPONENT) {
        return [self.years count];
    }
    return 12;
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadComponent:MONTH_COMPONENT];
    
    int monthCurrentIndex = [pickerView selectedRowInComponent:MONTH_COMPONENT];
    NSMutableArray *currentMonthFlags = [self.data objectAtIndex:[pickerView selectedRowInComponent:YEAR_COMPONENT]];
    int small = [[currentMonthFlags objectAtIndex:12] intValue];
    int big = [[currentMonthFlags objectAtIndex:13] intValue];
    if (monthCurrentIndex < small) {
        [pickerView selectRow:small inComponent:MONTH_COMPONENT animated:YES];
    }else if (monthCurrentIndex > big){
        [pickerView selectRow:big inComponent:MONTH_COMPONENT animated:YES];
    }
    
    self.selectedMonth = self.months[[pickerView selectedRowInComponent:MONTH_COMPONENT]];
    self.selectedYear = [self.years objectAtIndex:[pickerView selectedRowInComponent:YEAR_COMPONENT]];
    self.selectedData = [NSString stringWithFormat:@"%@%@%@",self.selectedYear,self.separator,self.selectedMonth];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *componentView = nil;
    if(view){
        componentView = (UILabel *)view;
    }else{
        componentView = [self componentLabel];
    }
    
    if (component == YEAR_COMPONENT) {
        componentView.text = [self.years objectAtIndex:row];
        return componentView;
    }else{
        if ([[self.data objectAtIndex:[pickerView selectedRowInComponent:YEAR_COMPONENT]] objectAtIndex:row] == UNAVAILABLE) {
            componentView.textColor = UNAVAILABLE_COLOR;
        }else{
            componentView.textColor = AVAILABLE_COLOR;
        }
        componentView.text = self.months[row];
        return componentView;
    }
}

@end