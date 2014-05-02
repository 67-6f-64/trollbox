//
//  ChatMessage.h
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL hasAnimated;
@property (nonatomic, copy) NSMutableAttributedString *formattedMessage;
@property (nonatomic, copy) NSString *locale;

@end
