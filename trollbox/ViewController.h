//
//  ViewController.h
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SRWebSocket.h>
#import "TickerView.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SRWebSocketDelegate>

@property (weak, nonatomic) IBOutlet TickerView *tickerView;
@property (weak, nonatomic) IBOutlet UILabel *autoRefreshLabel;
@property (weak, nonatomic) IBOutlet UIView *autoRefreshBG;
@property (weak, nonatomic) IBOutlet UIView *chooseLanguageView;
@property (weak, nonatomic) IBOutlet UIButton *englishLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton *russianLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton *chineseLanguageButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedLanguageCheckmark;
@property (weak, nonatomic) IBOutlet UIImageView *englishFlag;
@property (weak, nonatomic) IBOutlet UIImageView *russianFlag;
@property (weak, nonatomic) IBOutlet UIImageView *chineseFlag;

- (IBAction)setLanguageEnglish:(id)sender;
- (IBAction)setLanguageRussian:(id)sender;
- (IBAction)setLanguageChinese:(id)sender;
- (IBAction)saveLanguage:(id)sender;

- (void)start;
- (void)stop;

@end
