//
//  TickerView.m
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import "TickerView.h"

@interface TickerView()

@property (nonatomic, strong) TickerData *tickerData;
@property (nonatomic, assign) int animationCount;
@property (nonatomic, assign) float prevLast;
@property (nonatomic, copy) NSString *locale;
@property (nonatomic, copy) NSString *currency;

@end

@implementation TickerView

- (void)lookupDataForLocale:(NSString *)locale {
    if(!self.tickerData) {
        self.tickerData = [[TickerData alloc] init];
    }

    self.continueAnimation = YES;
    self.locale = locale;
    
    NSString *path;

    if([locale isEqualToString:@"cn"]) {
        path = @"https://btc-e.com/api/2/btc_cnh/ticker";
        self.currency = @"CNH";
    } else if([locale isEqualToString:@"ru"]) {
        path = @"https://btc-e.com/api/2/btc_rur/ticker";
        self.currency = @"RUR";
    } else {
        path = @"https://btc-e.com/api/2/btc_usd/ticker";
        self.currency = @"USD";
    }

    NSURL *url = [[NSURL alloc] initWithString:path];
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         
        if (!error) {
            NSError *error = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if(error) { return; }
            
            NSDictionary *tickerDictionary = [responseDictionary objectForKey:@"ticker"];
            
            if(tickerDictionary) {
                self.tickerData.last = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"last"], self.currency];
                self.tickerData.high = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"high"], self.currency];
                self.tickerData.low = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"low"], self.currency];
                self.tickerData.avg = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"avg"], self.currency];
                self.tickerData.vol = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"vol"], self.currency];
                self.tickerData.vol_cur = [NSString stringWithFormat:@"%@ BTC", [tickerDictionary objectForKey:@"vol_cur"]];
                self.tickerData.buy = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"buy"], self.currency];
                self.tickerData.sell = [NSString stringWithFormat:@"%@ %@", [tickerDictionary objectForKey:@"sell"], self.currency];
                
                NSString *timeStampString = [tickerDictionary objectForKey:@"updated"];
                NSTimeInterval interval = [timeStampString doubleValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
                self.tickerData.updated = [NSString stringWithFormat:@"%@", date];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.prevLast) {
                if(self.prevLast < [self.tickerData.last floatValue]) {
                    self.backgroundColor = [UIColor colorWithRed:0 green:111.0/255.0 blue:0 alpha:1.0];
                } else if(self.prevLast > [self.tickerData.last floatValue]) {
                    self.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:0.0 blue:8.0/255.0 alpha:1.0];
                } else {
                    self.backgroundColor = [UIColor blackColor];
                }
            }
            
            self.prevLast = [self.tickerData.last floatValue];
            
            if(self.continueAnimation) {
                [self animateTickerLabel];
            } else {
                self.prevLast = 0;
            }
        });
    }];
}

- (void)animateTickerLabel {
    NSLog(@"animate label");
    self.tickerLabel.attributedText = [self.tickerData formattedString];
    [self.tickerLabel sizeToFit];
    self.tickerLabel.layer.shouldRasterize = YES;
    
    CGRect tickerLabelFrame = self.tickerLabel.frame;
    tickerLabelFrame.origin.x = self.frame.size.width;
    self.tickerLabel.frame = tickerLabelFrame;
    [UIView animateWithDuration:self.tickerLabel.text.length * 0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect tickerLabelFrame = self.tickerLabel.frame;
                         tickerLabelFrame.origin.x = -self.tickerLabel.frame.size.width;
                         self.tickerLabel.frame = tickerLabelFrame;
                     } completion:^(BOOL completed) {
                         self.animationCount++;
                         if(self.continueAnimation) {
                             if(self.animationCount > 1) {
                                 self.animationCount = 0;
                                 [self lookupDataForLocale:self.locale];
                             } else {
                                 [self animateTickerLabel];
                             }
                         } else {
                             self.animationCount = 0;
                             self.prevLast = 0;
                         }
                     }];
}

- (void)setContinueAnimation:(BOOL)continueAnimation {
    _continueAnimation = continueAnimation;
    self.prevLast = 0;
    self.backgroundColor = [UIColor blackColor];
}

@end
