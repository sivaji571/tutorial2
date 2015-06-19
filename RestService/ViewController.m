//
//  ViewController.m
//  RestService
//
//  Created by sivaji ganesh kandimalla on 6/17/15.
//  Copyright (c) 2015 sivaji ganesh kandimalla. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"

//#define BASE_URL "http://api.wunderground.com/api/897dbb106f67279b/geolookup/conditions/forecast/q/sydney.json"
//http://api.wunderground.com/api/00e83aeb00e951db/conditions/q/CA/San_Francisco.json
//http://api.wunderground.com/api/00e83aeb00e951db/conditions/q/il/chicago.json

#define BASE_URL @"http://api.wunderground.com/api/00e83aeb00e951db/conditions/q/"

@interface ViewController () {
    UIPickerView *statePicker;
    NSMutableArray *stateArray;
}
@property (strong, nonatomic) IBOutlet UITextField *stateDropDown;

@property (weak, nonatomic) IBOutlet UITextField *sentenceTextField;
@property (nonatomic, weak) NSString *tags;
@property (nonatomic, weak) NSString *tokens;
@property (weak, nonatomic) IBOutlet UILabel *weather;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    stateArray=[[NSMutableArray alloc]initWithArray:@[@"IL",@"MO",@"TX"]];
    
    //_responseTableView.delegate = self;
    //_responseTableView.dataSource = self;
    //department picker view
    
    //create progmatically picker view
    statePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
    //add delegates
    statePicker.delegate = self;
    statePicker.dataSource = self;
    
    //selection indicator is displayed (no effect on iOS 7 and later)
    [statePicker setShowsSelectionIndicator:YES];
    
    //custom input view to display when the text field becomes the first responde
    _stateDropDown.inputView =  statePicker;

    // Create Toolbar on PickerView
    UIToolbar*  mypickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    mypickerToolbar.barStyle = UIBarStyleBlackOpaque;
    mypickerToolbar.barTintColor = [UIColor colorWithRed:209.0f/255.0f green:213.0f/255.0f blue:219.0f/255.0f alpha:0.5f];
    [mypickerToolbar sizeToFit];
    
    //add bar items
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    //add flex space
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    //add
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    [doneBtn setTintColor:[UIColor colorWithRed:111.0f/255.0f green:120.0f/255.0f blue:129.0f/255.0f alpha:1.0f]];
    
    [barItems addObject:doneBtn];
    
    
    [mypickerToolbar setItems:barItems animated:YES];
    
    
    _stateDropDown.inputAccessoryView = mypickerToolbar;
    
    _stateDropDown.text=[stateArray objectAtIndex:0];
    
    
}
#pragma TextField Delegate Method
//to disable textfield editing
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}
-(void)pickerDoneClicked
{
    [_stateDropDown resignFirstResponder];
   
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
        return stateArray.count;
    
    
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
        return [stateArray objectAtIndex:row] ;
    
   
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component

{
    
        //to set state name
        _stateDropDown.text = [stateArray objectAtIndex:row] ;
        

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedOnTokenize:(id)sender {
    
    NSString *cityNameStr=[_sentenceTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cityNameStr=[cityNameStr stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSLog(@"string city:----- %@",cityNameStr);
    //[foo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]
    if ([cityNameStr isEqualToString:@"" ]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:@"Please enter city name"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];

    }
    else{
        
    
        [_sentenceTextField resignFirstResponder];  //To hide the keyboard
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //NSString *sentense = [_sentenceTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
        NSString *url = [NSString stringWithFormat:@"%@%@/%@.json", BASE_URL, _stateDropDown.text,cityNameStr];
    
        NSLog(@"url ....... %@", url);
    
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            // NSLog(@"JSON: %@", responseObject);
        
            NSMutableDictionary *currentObservations=[responseObject objectForKey:@"current_observation"];
            _weather.text=[currentObservations objectForKey:@"temperature_string"];
            NSLog(@"temperature in state %@  %@",cityNameStr, _weather.text);
            // _tokens = [responseObject objectForKey:@"tokens"];
            // _tags = [responseObject objectForKey:@"UV"];
            // self.weather.text = _tags;
            //[_responseTableView reloadData];
        
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}

@end
