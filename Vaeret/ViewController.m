//
//  ViewController.m
//  Vaeret
//
//  Created by Thomas Orten on 10/22/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import "WeatherCollectionViewCell.h"
#import "Masonry.h"
#import "CoverFlowLayout.h"

#define kLatestUpdatekey @"Latest Update"
#define defaultSearchString @"Søk etter sted"

@interface ViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(assign) NSInteger currentTaskId;

@property NSMutableArray *savedPlacesArray;
@property NSMutableArray *collectionViewArray;
@property NSMutableArray *dataArray;
@property NSMutableArray *glyphsArray;
@property NSArray *forecast;

@property NSInteger period;
@property NSInteger selectedDay;

@property (weak, nonatomic) IBOutlet UIView *searchPlaceView;
@property (weak, nonatomic) IBOutlet UIView *findMeView;
@property (weak, nonatomic) IBOutlet UIView *underlineView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIView *weatherGridView;

@property (weak, nonatomic) IBOutlet UICollectionView *weatherCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *weatherGridOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFourLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFiveLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridSixLabel;

@property (weak, nonatomic) IBOutlet UILabel *weatherGridOneTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridTwoTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridThreeTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFourTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridFiveTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherGridSixTempLabel;

@property (weak, nonatomic) IBOutlet UIButton *weatherGridOneDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weatherGridTwoDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weatherGridThreeDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weatherGridFourDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weatherGridFiveDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weatherGridSixDayButton;

@property CGRect initialTextFieldFrame;

@property (nonatomic, strong) MASConstraint *logoCenterYConstraint;
@property (nonatomic, strong) MASConstraint *searchCenterYConstraint;
@property (nonatomic, strong) MASConstraint *searchCenterXConstraint;
@property (nonatomic, strong) MASConstraint *findMeCenterYConstraint;
@property (nonatomic, strong) MASConstraint *cancelButtonXConstraint;

@property float screenHeight;
@property float screenWidth;

@end

@implementation ViewController

@synthesize currentTaskId;

- (void)viewDidLoad {

    [super viewDidLoad];

    self.screenWidth = [[UIScreen mainScreen] bounds].size.width;
    self.screenHeight = [[UIScreen mainScreen] bounds].size.height;

    // Constraints
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        self.logoCenterYConstraint = make.centerY.equalTo(self.view);
    }];
    [self.searchPlaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.searchCenterXConstraint = make.centerX.equalTo(self.view);
        self.searchCenterYConstraint = make.centerY.equalTo(self.view);
    }];
    [self.findMeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        self.findMeCenterYConstraint = make.top.equalTo(self.searchPlaceView.mas_bottom);
    }];
    [self.copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-30);
    }];
    [self.weatherGridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).centerOffset(CGPointMake(0, self.weatherGridView.frame.size.height));
    }];
    [self.weatherCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.screenWidth);
        make.height.mas_equalTo(self.screenHeight/2);
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).centerOffset(CGPointMake(0, -100));
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(58);
        self.cancelButtonXConstraint = make.centerX.equalTo(self.view).centerOffset(CGPointMake((self.placeTextField.frame.size.width/2)+10, 0));
    }];

    [self.weatherCollectionView setCollectionViewLayout:[[CoverFlowLayout alloc] init]];

    [self generateData];

    [self.placeTextField setDelegate:self];

    [self.placeTextField setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7]];

    [self registerForKeyboardNotifications];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    [self performSelector:@selector(animateLogo) withObject:nil afterDelay:0.5];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.selectedDay = 0; // Today
    // Already saved a place?
    [self load];
}

-(void)animateLogo
{
    self.logoCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.35));
    [UIView animateWithDuration:0.6 animations:^{
        [self.view layoutIfNeeded];
    }];

    [self performSelector:@selector(fadeInSearch) withObject:nil afterDelay:0.5];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self.savedPlacesArray removeAllObjects];

    self.findMeView.hidden = NO;
    self.underlineView.hidden = NO;
    self.searchPlaceView.hidden = NO;
    self.titleLabel.hidden = NO;

    [self animateTitles:YES];
}

- (IBAction)onLocateMeButtonPressed:(id)sender
{

}

-(void)fadeInSearch
{
    [UIView animateWithDuration:0.6 animations:^{
        self.searchPlaceView.alpha = 1.0;
        self.findMeView.alpha = 1.0;
        self.copyrightLabel.alpha = 0.8;
    }];
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
    self.searchCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.15));
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self.placeTextField setPopoverSize:CGRectMake(self.searchPlaceView.frame.origin.x, (self.searchPlaceView.frame.origin.y+self.placeTextField.frame.size.height), self.underlineView.frame.size.width, 135)];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.searchCenterYConstraint.centerOffset = (CGPointMake(0, 0));
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
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

- (void)callPlace:(NSString *)xmlUrl
{
        NSString *urlString = [NSString stringWithFormat:@"https://evening-gorge-8065.herokuapp.com/api/forecast?url=%@", xmlUrl];
        NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:
                                  NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodedUrlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
            if (responseData) {
                NSDictionary *contents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&connectionError];
                [self setupForecast:[[NSArray alloc] initWithArray:contents[@"weatherdata"][@"forecast"][@"tabular"]]];
            }
        }];
}

-(void)setupForecast:(NSArray *)forecast
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    NSMutableArray *dayOneArray = [[NSMutableArray alloc] init];
    [tmpArray addObject:dayOneArray];
    int day = 0;
    for (NSDictionary *timeSpan in forecast) {
        if (day == 7) {
            break;
        }
        NSMutableDictionary *tmpDictionary = [[NSMutableDictionary alloc] initWithDictionary:timeSpan];
        if ([timeSpan[@"period"] isEqualToString:@"0"]) {
            [tmpDictionary setObject:@"00 - 06" forKey:@"time"];
        } else if ([timeSpan[@"period"] isEqualToString:@"1"]) {
            [tmpDictionary setObject:@"06 - 12" forKey:@"time"];
        } else if ([timeSpan[@"period"] isEqualToString:@"2"]) {
            [tmpDictionary setObject:@"12 - 18" forKey:@"time"];
        } else {
            [tmpDictionary setObject:@"18 - 00" forKey:@"time"];
        }

        [[tmpArray objectAtIndex:day] addObject:tmpDictionary];

        // Setup weather icons
        for (NSDictionary *glyph in self.glyphsArray) {
            NSString *tmpString = timeSpan[@"symbol"][@"var"];
            if ([tmpString rangeOfString:@"/"].location != NSNotFound) {
                NSRange range = [tmpString rangeOfString:@"/"];
                tmpString = [tmpString substringWithRange:NSMakeRange(range.location+1, tmpString.length-range.location-1)];
            }
            if ([tmpString rangeOfString:@"."].location != NSNotFound) {
                NSRange rangeTwo = [tmpString rangeOfString:@"."];
                tmpString = [tmpString substringWithRange:NSMakeRange(0, rangeTwo.location)];
            }
            if ([glyph[@"var"] isEqualToString:tmpString]) {
                NSString *currentWeatherSymbol = glyph[@"unicode"];
                [tmpDictionary setObject:currentWeatherSymbol forKey:@"unicode"];
            }
        }

        // Setup dates
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3600]];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"no_NB"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        NSDate *date = [dateFormatter dateFromString:timeSpan[@"from"]];

        [dateFormatter setDateFormat:@"EEEE"];
        NSString *dayOfWeek = [dateFormatter stringFromDate:date];

        dayOfWeek = [dayOfWeek stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[dayOfWeek substringToIndex:1] capitalizedString]];

        [tmpDictionary setObject:dayOfWeek forKey:@"day"];

        // New day?
        if ([timeSpan[@"period"] isEqualToString:@"3"] && day != 6) {
            NSMutableArray *newDayArray = [[NSMutableArray alloc] init];
            [tmpArray addObject:newDayArray];
            day++;
        }
    }

    self.forecast = (NSArray *)tmpArray;
    // Cells
    self.collectionViewArray = [[NSMutableArray alloc] initWithArray:[self.forecast objectAtIndex:0]];

    [self.weatherGridOneLabel setText:[[self.forecast objectAtIndex:1] objectAtIndex:1][@"unicode"]];
    [self.weatherGridOneTempLabel setText:[[self.forecast objectAtIndex:1] objectAtIndex:1][@"temperature"][@"value"]];
    [self.weatherGridTwoLabel setText:[[self.forecast objectAtIndex:2] objectAtIndex:1][@"unicode"]];
    [self.weatherGridTwoTempLabel setText:[[self.forecast objectAtIndex:2] objectAtIndex:1][@"temperature"][@"value"]];
    [self.weatherGridThreeLabel setText:[[self.forecast objectAtIndex:3] objectAtIndex:1][@"unicode"]];
    [self.weatherGridThreeTempLabel setText:[[self.forecast objectAtIndex:3] objectAtIndex:1][@"temperature"][@"value"]];
    [self.weatherGridFourLabel setText:[[self.forecast objectAtIndex:4] objectAtIndex:1][@"unicode"]];
    [self.weatherGridFourTempLabel setText:[[self.forecast objectAtIndex:4] objectAtIndex:1][@"temperature"][@"value"]];
    [self.weatherGridFiveLabel setText:[[self.forecast objectAtIndex:5] objectAtIndex:1][@"unicode"]];
    [self.weatherGridFiveTempLabel setText:[[self.forecast objectAtIndex:5] objectAtIndex:1][@"temperature"][@"value"]];
    [self.weatherGridSixLabel setText:[[self.forecast objectAtIndex:6] objectAtIndex:1][@"unicode"]];
    [self.weatherGridSixTempLabel setText:[[self.forecast objectAtIndex:6] objectAtIndex:1][@"temperature"][@"value"]];

    NSString *dayOneTitle = [[self.forecast objectAtIndex:1] objectAtIndex:1][@"day"];
    [self.weatherGridOneDayButton setTitle:dayOneTitle forState:UIControlStateNormal];
    NSString *dayTwoTitle = [[self.forecast objectAtIndex:2] objectAtIndex:1][@"day"];
    [self.weatherGridTwoDayButton setTitle:dayTwoTitle forState:UIControlStateNormal];
    NSString *dayThreeTitle = [[self.forecast objectAtIndex:3] objectAtIndex:1][@"day"];
    [self.weatherGridThreeDayButton setTitle:dayThreeTitle forState:UIControlStateNormal];
    NSString *dayFourTitle = [[self.forecast objectAtIndex:4] objectAtIndex:1][@"day"];
    [self.weatherGridFourDayButton setTitle:dayFourTitle forState:UIControlStateNormal];
    NSString *dayFiveTitle = [[self.forecast objectAtIndex:5] objectAtIndex:1][@"day"];
    [self.weatherGridFiveDayButton setTitle:dayFiveTitle forState:UIControlStateNormal];
    NSString *daySixTitle = [[self.forecast objectAtIndex:6] objectAtIndex:1][@"day"];
    [self.weatherGridSixDayButton setTitle:daySixTitle forState:UIControlStateNormal];

    [self.weatherCollectionView reloadData];
}

- (void)generateData
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        //
        //
        NSError* err = nil;
        self.dataArray = [[NSMutableArray alloc] init];
        self.glyphsArray = [[NSMutableArray alloc] init];
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"places" ofType:@"json"];
        NSString *glyphsPath = [[NSBundle mainBundle] pathForResource:@"glyphs" ofType:@"json"];
        NSArray *contents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath] options:kNilOptions error:&err];
        NSArray *glyphContents = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:glyphsPath] options:kNilOptions error:&err];
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"N"], @"DisplayText", [obj objectForKey:@"T"], @"DisplaySubText", obj, @"CustomObject", nil]];
            }];
            [glyphContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [self.glyphsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys: [obj objectForKey:@"var"], @"var", [[obj objectForKey:@"unicode"] substringFromIndex:1], @"unicode", [obj objectForKey:@"icon"], @"icon", nil]];
            }];
        });
    });
}

#pragma mark MPGTextField Delegate Methods

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.placeTextField]) {
        return self.dataArray;
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
            [self save:result[@"CustomObject"]];
            // Call place
            [self callPlace:result[@"CustomObject"][@"U"]];
            [self initLoader];
        }
}

- (void)initLoader
{
    customProgressView = [[CustomProgressView alloc] init];
    customProgressView.delegate = self;
    [self.view addSubview:customProgressView];

    [self performSelector:@selector(setProgress:) withObject:[NSNumber numberWithFloat:1.0] afterDelay:0.1];
}

-(void)setProgress:(NSNumber*)value
{
    [customProgressView performSelectorOnMainThread:@selector(setProgress:) withObject:value waitUntilDone:NO];
}

- (void)didFinishAnimation:(CustomProgressView*)progressView
{
    [progressView removeFromSuperview];

    [self performSelector:@selector(animateTitles:) withObject:nil afterDelay:0.2];
}

-(void)animateTitles:(BOOL)reverse
{

    if (![self.findMeView isHidden] && ![self.underlineView isHidden]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.underlineView.alpha = reverse ? 1 : 0;
            self.titleLabel.alpha = reverse ? 1 : 0;
            self.findMeView.alpha = reverse ? 1 : 0;
        }];
    } else {
        self.searchPlaceView.hidden = NO;
        self.searchCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.38));
        self.titleLabel.alpha = reverse ? 1 : 0;
        [self.view layoutIfNeeded];
    }

    [UIView animateWithDuration:0.6 animations:^{

        int initialWidth = self.placeTextField.frame.size.width;

        [self.placeTextField sizeToFit];
        [self.placeTextField setEnabled:reverse];

        int newWidth = self.placeTextField.frame.size.width;

        if (reverse) {
            self.searchCenterYConstraint.centerOffset(CGPointMake(0, 0));
            self.searchCenterXConstraint.centerOffset(CGPointMake(0, 0));
        } else {
            self.searchCenterYConstraint.centerOffset(CGPointMake(0, -self.screenHeight*0.38));
            self.searchCenterXConstraint.centerOffset(CGPointMake(((initialWidth-newWidth)/2)-17, 0));
        }

        self.cancelButtonXConstraint.centerOffset(CGPointMake((self.placeTextField.frame.size.width/2)+10, 0));

        self.cancelButton.alpha = reverse ? 0 : 1;

        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];

    }];

    if (reverse) {
        [self performSelector:@selector(resetTextField) withObject:nil afterDelay:0.3];
        [self performSelector:@selector(animateWeatherViews:) withObject:[NSNumber numberWithBool:YES] afterDelay:0];
    } else {
        [self performSelector:@selector(animateWeatherViews:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.8];
    }
}

- (void)animateWeatherViews:(NSNumber *)reverse
{
    BOOL isReverse = [reverse boolValue];
    [UIView animateWithDuration:0.6 animations:^{
        self.weatherCollectionView.alpha = isReverse ? 0 : 1;
        self.weatherGridView.alpha = isReverse ? 0 : 1;
    }];
}

-(void)resetTextField
{
    self.placeTextField.text = defaultSearchString;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [self.collectionViewArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WeatherCollectionViewCell *weatherCell = [self.weatherCollectionView dequeueReusableCellWithReuseIdentifier:@"WeatherCell" forIndexPath:indexPath];

    [weatherCell.weatherIcon812Label setText:[self.collectionViewArray objectAtIndex:indexPath.row][@"unicode"]];

    weatherCell.degreeLabel.text = [self.collectionViewArray objectAtIndex:indexPath.row][@"temperature"][@"value"];

    NSString *minMaxRain = @"0 - 0";
    if ([[self.collectionViewArray objectAtIndex:indexPath.row][@"precipitation"] objectForKey:@"minvalue"] != nil) {
        minMaxRain = [NSString stringWithFormat:@"%@ - %@", [self.collectionViewArray objectAtIndex:indexPath.row][@"precipitation"][@"minvalue"], [self.collectionViewArray objectAtIndex:indexPath.row][@"precipitation"][@"maxvalue"]];
    }

    weatherCell.rainLabel.text = minMaxRain;

    weatherCell.timeLabel.text = [NSString stringWithFormat:@"Kl. %@", [self.collectionViewArray objectAtIndex:indexPath.row][@"time"]];

    return weatherCell;
}

- (void)save:(NSDictionary *)place
{
    [self.savedPlacesArray addObject:place];
    if ([self.savedPlacesArray count] > 4) {
        self.savedPlacesArray = (NSMutableArray *) [self.savedPlacesArray subarrayWithRange:NSMakeRange(0, 5)];
    }

    NSURL *places = [[self documentsDirectory] URLByAppendingPathComponent:@"vaeret.plist"];
    [self.savedPlacesArray writeToURL:places atomically:YES];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kLatestUpdatekey];
    [defaults synchronize];
}

- (void)load
{
    [self setRightTime];

    NSURL *places = [[self documentsDirectory] URLByAppendingPathComponent:@"vaeret.plist"];
    self.savedPlacesArray = [NSMutableArray arrayWithContentsOfURL:places];
    if (!self.savedPlacesArray)
    {
        self.savedPlacesArray = [NSMutableArray array];
        // No last searches

    } else {
        // Exists
        NSDictionary *lastPlaceSearched = [self.savedPlacesArray lastObject];
        self.placeTextField.text = lastPlaceSearched[@"N"];
        [self callPlace:lastPlaceSearched[@"U"]];
        // Show some stuff
        self.searchPlaceView.hidden = YES;
        self.titleLabel.hidden = YES;
        self.findMeView.hidden = YES;
        self.underlineView.hidden = YES;
        [self initLoader];
    }
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
}

- (void)setRightTime
{
    NSDateComponents *currentTime = [self currentTime];
    NSInteger hour = [currentTime hour];
    if (hour) {
        if (hour > 5 && hour < 12) {
            self.period = 1;
        } else if (hour > 11 && hour < 18) {
            self.period = 2;
        } else if (hour > 17 && hour < 00) {
            self.period = 3;
        } else {
            self.period = 0;
        }
    }
}

- (NSDateComponents *)currentTime
{
    //Get current time
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    return dateComponents;
}

- (IBAction)weatherGridOneDayButtonPressed:(id)sender {
}
- (IBAction)weatherGridTwoDayButtonPressed:(id)sender {
}
- (IBAction)weatherGridThreeDayButtonPressed:(id)sender {
}
- (IBAction)weatherGridFourDayButtonPressed:(id)sender {
}
- (IBAction)weatherGridFiveDayButtonPressed:(id)sender {
}
- (IBAction)weatherGridSixDayButtonPressed:(id)sender {
}


@end
