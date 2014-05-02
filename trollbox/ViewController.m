//
//  ViewController.m
//  trollbox
//
//  Created by Chris Rebel on 4/12/14.
//  Copyright (c) 2014 Chris Rebel. All rights reserved.
//

#import "ViewController.h"
#import "ChatMessage.h"
#import <MBProgressHUD.h>

// ticker url
// https://btc-e.com/api/2/btc_usd/ticker


@interface ViewController ()

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSMutableArray *chatMessages;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat totalHeightOfMessages;
@property (nonatomic, assign) BOOL isTableLocked;
@property (nonatomic, assign) BOOL isTouchingTableView;
@property (nonatomic, assign) BOOL unlockTableAfterDecelerate;
@property (nonatomic, assign) BOOL ignoreScroll;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) int connectionAttempts;
@property (nonatomic, copy) NSString *locale;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chatMessages = [@[] mutableCopy];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
    [self.view insertSubview:self.tableView atIndex:1];
    
    self.englishLanguageButton.backgroundColor = [UIColor clearColor];
    [self.englishLanguageButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [self.englishLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.englishLanguageButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateHighlighted];
    [self.englishLanguageButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    
    self.russianLanguageButton.backgroundColor = [UIColor clearColor];
    [self.russianLanguageButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [self.russianLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.russianLanguageButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateHighlighted];
    [self.russianLanguageButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    
    self.chineseLanguageButton.backgroundColor = [UIColor clearColor];
    [self.chineseLanguageButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    [self.chineseLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.chineseLanguageButton setTitleColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateHighlighted];
    [self.chineseLanguageButton addTarget:self action:@selector(highlightButton:) forControlEvents:UIControlEventTouchDown];
    
    self.autoRefreshLabel.hidden = YES;
    self.autoRefreshBG.hidden = YES;
}

- (void)highlightButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.highlighted = YES;
}

- (void)start {
    self.locale = [[NSUserDefaults standardUserDefaults] objectForKey:@"locale"];
    
    BOOL hasSetLanguage = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSetLanguage"];
    
    [self.tableView reloadData];
    
    if(self.locale.length && hasSetLanguage) {
        self.chooseLanguageView.hidden = YES;
        [self.tickerView lookupDataForLocale:self.locale];
        [self loadCurrentChatMessages];
    } else {
        self.chooseLanguageView.hidden = NO;
        [self setLanguageEnglish:self.englishLanguageButton];
    }
}

- (void)stop {
    self.socket.delegate = nil;
    [self.socket close];
    self.socket = nil;
    
    self.totalHeightOfMessages = 0;
    self.tickerView.continueAnimation = NO;
    [self.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1, 1) animated:NO];
    [self.chatMessages removeAllObjects];
    [self.tableView reloadData];
}

- (void)loadCurrentChatMessages {
    if(!self.hud) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"Connecting to chat...";
        self.hud.removeFromSuperViewOnHide = YES;
    }
    
    NSString *localizedURL = [NSString stringWithFormat:@"http://afternoon-peak-4995.herokuapp.com/%@", self.locale];
    NSURL *url = [[NSURL alloc] initWithString:localizedURL];
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!error) {
            NSError *error = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if(error) { return; }
            
            NSArray *chatMessages = [responseDictionary objectForKey:@"chatmessages"];
        
            if(chatMessages) {
                for(int i = 0; i < chatMessages.count; i++) {
                    ChatMessage *message = [[ChatMessage alloc] init];
                    message.data = [chatMessages objectAtIndex:i];
                    message.locale = self.locale;
                    message.hasAnimated = YES;
                    [self.chatMessages addObject:message];
                    self.totalHeightOfMessages += message.cellHeight;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ignoreScroll = YES;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            self.ignoreScroll = NO;
            [self reconnect];
        });
    }];
}

- (void)reconnect {
    self.connectionAttempts++;
    self.socket.delegate = nil;
    [self.socket close];
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"wss://ws.pusherapp.com/app/4e0ebd7a8b66fa3554a4?protocol=6&client=js&version=2.0.0&flash=false"]]];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)reconnectAfterDelay {
    [self performSelector:@selector(reconnect) withObject:nil afterDelay:5.0];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSError* error;
    NSString *localizedChannel = [NSString stringWithFormat:@"chat_%@", self.locale];
    NSDictionary *handshake = @{@"event": @"pusher:subscribe",
                                @"data": @{@"channel": localizedChannel}};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:handshake options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [webSocket send:jsonString];
    
    [self.hud hide:YES];
    self.hud = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    if(self.connectionAttempts < 5) {
        [self reconnectAfterDelay];
    } else {
        [self showErrorMessage];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSError* error;
    NSDictionary *messageDictionary = [NSJSONSerialization JSONObjectWithData: [message dataUsingEncoding:NSUTF8StringEncoding] options: kNilOptions error: &error];
    if([messageDictionary objectForKey:@"data"]) {
        NSString *dataString = [messageDictionary objectForKey:@"data"];
        if([[dataString substringToIndex:1] isEqualToString:@"\""]) {
            dataString = [dataString substringFromIndex:1];
            dataString = [dataString substringToIndex:dataString.length - 1];
        };
        
        dataString = [dataString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData: [dataString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        
        if([dataDictionary objectForKey:@"msg"]) {
            ChatMessage *chatMessage = [[ChatMessage alloc] init];
            chatMessage.locale = self.locale;
            chatMessage.data = dataDictionary;
            [self.chatMessages addObject:chatMessage];
            
            self.totalHeightOfMessages += chatMessage.cellHeight;
            [self.tableView reloadData];
            
            if(!self.isTableLocked && !self.isTouchingTableView) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    self.socket = nil;
}

- (void)showErrorMessage {
    self.hud.labelText = @"Error connecting to service";
}

#pragma mark - UITableViewDelegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMessages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((ChatMessage *)[self.chatMessages objectAtIndex:indexPath.row]).cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"chatCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    ChatMessage *message = (ChatMessage *)[self.chatMessages objectAtIndex:indexPath.row];
    cell.textLabel.attributedText = message.formattedMessage;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatMessage *message = (ChatMessage *)[self.chatMessages objectAtIndex:indexPath.row];
    if(!message.hasAnimated) {
        message.hasAnimated = YES;
        
        float originalLayerY = cell.layer.position.y;

        cell.layer.position = CGPointMake(cell.layer.position.x, originalLayerY + 10.0);
        cell.alpha = 0;
        
        [UIView beginAnimations:@"displayChatMessage" context:NULL];
        [UIView setAnimationDuration:0.8];
        cell.layer.position = CGPointMake(cell.layer.position.x, originalLayerY);
        cell.alpha = 1;
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.ignoreScroll) {
        ChatMessage *message = (ChatMessage *)[self.chatMessages lastObject];
        self.isTableLocked = self.tableView.contentOffset.y + self.tableView.frame.size.height - 70.0 < self.totalHeightOfMessages - message.cellHeight;
        
        if(self.tableView.frame.size.height > self.totalHeightOfMessages) {
            self.isTableLocked = NO;
        }
        
        self.autoRefreshLabel.hidden = !self.isTableLocked;
        self.autoRefreshBG.hidden = !self.isTableLocked;
        self.tableView.showsVerticalScrollIndicator = self.isTableLocked;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTouchingTableView = YES;
    self.unlockTableAfterDecelerate = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.unlockTableAfterDecelerate = decelerate;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isTouchingTableView = !self.unlockTableAfterDecelerate;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)setLanguageEnglish:(id)sender {
    self.locale = @"en";
    [[NSUserDefaults standardUserDefaults] setObject:self.locale forKey:@"locale"];
    self.englishLanguageButton.selected = YES;
    self.russianLanguageButton.selected = NO;
    self.chineseLanguageButton.selected = NO;
    self.englishFlag.alpha = 1.0;
    self.russianFlag.alpha = 0.2;
    self.chineseFlag.alpha = 0.2;
    CGRect checkmarkFrame = self.selectedLanguageCheckmark.frame;
    checkmarkFrame.origin.y = self.englishLanguageButton.frame.origin.y + 5;
    self.selectedLanguageCheckmark.frame = checkmarkFrame;
}

- (IBAction)setLanguageRussian:(id)sender {
    self.locale = @"ru";
    [[NSUserDefaults standardUserDefaults] setObject:self.locale forKey:@"locale"];
    self.englishLanguageButton.selected = NO;
    self.russianLanguageButton.selected = YES;
    self.chineseLanguageButton.selected = NO;
    self.englishFlag.alpha = 0.2;
    self.russianFlag.alpha = 1.0;
    self.chineseFlag.alpha = 0.2;
    CGRect checkmarkFrame = self.selectedLanguageCheckmark.frame;
    checkmarkFrame.origin.y = self.russianLanguageButton.frame.origin.y + 5;
    self.selectedLanguageCheckmark.frame = checkmarkFrame;
}

- (IBAction)setLanguageChinese:(id)sender {
    self.locale = @"cn";
    [[NSUserDefaults standardUserDefaults] setObject:self.locale forKey:@"locale"];
    self.englishLanguageButton.selected = NO;
    self.russianLanguageButton.selected = NO;
    self.chineseLanguageButton.selected = YES;
    self.englishFlag.alpha = 0.2;
    self.russianFlag.alpha = 0.2;
    self.chineseFlag.alpha = 1.0;
    CGRect checkmarkFrame = self.selectedLanguageCheckmark.frame;
    checkmarkFrame.origin.y = self.chineseLanguageButton.frame.origin.y + 5;
    self.selectedLanguageCheckmark.frame = checkmarkFrame;
}

- (IBAction)saveLanguage:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSetLanguage"];
    [self.tickerView lookupDataForLocale:self.locale];
    [self loadCurrentChatMessages];
    
    [UIView animateWithDuration:0.3 animations:^ {
        self.chooseLanguageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.chooseLanguageView.hidden = YES;
    }];
}

@end
