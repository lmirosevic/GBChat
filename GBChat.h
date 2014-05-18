//
//  GBChat.h
//  GBChat
//
//  Created by Luka Mirosevic on 27/04/2014.
//  Copyright (c) 2014 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GBThriftApi/GBThriftApi.h>

#import "GoonbeeChatService.h"

@interface GBChat : GBThriftApi

-(void)isUsernameAvailable:(NSString *)username completed:(GBThriftCallCompletionBlock)block;
-(void)registerUsernameWithUserId:(NSString *)userId username:(NSString *)username completed:(GBThriftCallCompletionBlock)block;
-(void)newChatWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBThriftCallCompletionBlock)block;
-(void)chatsWithSorting:(enum GBChatChatSorting)chatSorting range:(GBSharedRange *)range completed:(GBThriftCallCompletionBlock)block;
-(void)chatWithUserId:(NSString *)userId chatId:(NSString *)chatId completed:(GBThriftCallCompletionBlock)block;
-(void)newMessageWithUserId:(NSString *)userId chatId:(NSString *)chatId message:(NSString *)content completed:(GBThriftCallCompletionBlock)block;
-(void)messagesWithUserId:(NSString *)userId chatId:(NSString *)chatId range:(GBSharedRange *)range completed:(GBThriftCallCompletionBlock)block;
-(void)setChatOptionsWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBThriftCallCompletionBlock)block;
-(void)globalUserCountCompleted:(GBThriftCallCompletionBlock)block;

@end
