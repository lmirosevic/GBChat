//
//  GBChat.h
//  World Cup Survival Guide
//
//  Created by Luka Mirosevic on 27/04/2014.
//  Copyright (c) 2014 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GBChatCallCompletionBlock)(enum GBChatResponseStatus status, id result, BOOL cancelled);

@interface GBChat : NSObject

+(instancetype)sharedChat;

-(void)connectToServer:(NSString *)server port:(NSUInteger)port;

-(void)isUsernameAvailable:(NSString *)username completed:(GBChatCallCompletionBlock)block;
-(void)registerUsernameWithUserId:(NSString *)userId username:(NSString *)username completed:(GBChatCallCompletionBlock)block;
-(void)newChatWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBChatCallCompletionBlock)block;
-(void)chatsWithSorting:(enum GBChatChatSorting)chatSorting range:(GBChatRange *)range completed:(GBChatCallCompletionBlock)block;
-(void)chatWithUserId:(NSString *)userId chatId:(NSString *)chatId completed:(GBChatCallCompletionBlock)block;
-(void)newMessageWithUserId:(NSString *)userId chatId:(NSString *)chatId message:(NSString *)content completed:(GBChatCallCompletionBlock)block;
-(void)messagesWithUserId:(NSString *)userId chatId:(NSString *)chatId range:(GBChatRange *)range completed:(GBChatCallCompletionBlock)block;
-(void)setChatOptionsWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBChatCallCompletionBlock)block;
-(void)globalUserCountCompleted:(GBChatCallCompletionBlock)block;

@end
