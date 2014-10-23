//
//  ViewController.h
//  Vaeret
//
//  Created by Thomas Orten on 10/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGTextField.h"
#import "CustomProgressView.h"

@interface ViewController : UIViewController <UITextFieldDelegate, MPGTextFieldDelegate, CustomProgressViewDelegate>
{
    NSMutableArray *data;
    CustomProgressView *customProgressView;
}

@property (weak, nonatomic) IBOutlet MPGTextField *placeTextField;

@end

