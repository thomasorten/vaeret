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

@property (weak, nonatomic) IBOutlet UIView *searchPlaceView;
@property (weak, nonatomic) IBOutlet UIView *findMeView;
@property int initialScrollOffsetPosition;
@property int initialFindMeScrollOffsetPosition;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
            frame.origin.y = (fieldFrame.origin.y+300)-(aRect.size.height);

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


@end
