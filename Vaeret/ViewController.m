//
//  ViewController.m
//  Vaeret
//
//  Created by Thomas Orten on 10/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"

#define defaultSearchString @"Søk etter sted"

@interface ViewController () <UITextViewDelegate>

@property(assign) NSInteger currentTaskId;
@property (weak, nonatomic) IBOutlet UIView *searchPlaceView;
@property (weak, nonatomic) IBOutlet UIView *findMeView;
@property (weak, nonatomic) IBOutlet UIView *underlineView;

@property int initialScrollOffsetPosition;
@property int initialFindMeScrollOffsetPosition;

@end

@implementation ViewController

@synthesize currentTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self generateData];

    [self.placeTextField setDelegate:self];

    [self.placeTextField setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.6]];
    [self.placeTextField setPopoverSize:CGRectMake(self.underlineView.frame.origin.x, (self.underlineView.frame.origin.y+self.underlineView.frame.size.height), self.underlineView.frame.size.width, 135)];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
     [self.view addGestureRecognizer:tap];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect fieldFrame = self.searchPlaceView.frame;
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = fieldFrame.origin;
    self.initialScrollOffsetPosition = origin.y;

    CGRect findMeFrame = self.findMeView.frame;
    self.initialFindMeScrollOffsetPosition = findMeFrame.origin.y;

    origin.y -= (self.searchPlaceView.frame.origin.y+50);
    if (!CGRectContainsPoint(aRect, origin) ) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame;
            // move our subView to its new position
            frame = self.searchPlaceView.frame;
            frame.origin.y = (fieldFrame.origin.y+240)-(aRect.size.height);

            self.searchPlaceView.frame=frame;

            CGRect frame2;
            // move our subView to its new position
            frame2 = self.findMeView.frame;
            frame2.origin.y = (findMeFrame.origin.y)+(aRect.size.height);

            self.findMeView.frame=frame2;
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame;
        // move our subView to its new position
        frame=self.searchPlaceView.frame;
        frame.origin.y = self.initialScrollOffsetPosition;
        self.searchPlaceView.frame=frame;

        CGRect frame2;
        // move our subView to its new position
        frame2=self.findMeView.frame;
        frame2.origin.y = self.initialFindMeScrollOffsetPosition;
        self.findMeView.frame=frame2;
    }];
}


- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqual:defaultSearchString]) {
        textField.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqual:@""]) {
        textField.text = defaultSearchString;
    }
}

- (void)callPlace
{
        data = [[NSMutableArray alloc] init];
        NSString *urlString = [NSString stringWithFormat:@"http://10.0.0.49:3000/weather/places?query={\"Stadnamn\":{\"$regex\":\"^%@\",\"$options\":\"i\"}}", self.placeTextField.text];
        NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:
                                  NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodedUrlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
            if (responseData) {
                NSArray *contents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&connectionError];
                [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [data addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"N"],@"DisplayText", nil]];
                }];
            }
        }];
}

- (void)generateData
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //
        NSError* err = nil;
        data = [[NSMutableArray alloc] init];
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"places" ofType:@"json"];
        NSArray *contents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&err];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [data addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"N"], @"DisplayText", [obj objectForKey:@"T"], @"DisplaySubText", obj, @"CustomObject", nil]];
            }];
        });
    });
}

#pragma mark MPGTextField Delegate Methods

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.placeTextField]) {
        return data;
    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
        if ([textField isEqual:self.placeTextField]) {
            //
        }
}


@end
