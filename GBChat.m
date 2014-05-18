//
//  GBChat.m
//  GBChat
//
//  Created by Luka Mirosevic on 27/04/2014.
//  Copyright (c) 2014 Goonbee. All rights reserved.
//

#import "GBChat.h"

#import <malloc/malloc.h>

#import <thrift/TSocketClient.h>
#import <thrift/TBinaryProtocol.h>
#import <thrift/TTransportException.h>
#import <GBToolbox/GBToolbox.h>

@implementation GBChat

//lm need automatic reconnection to server if something goes wrong, with request queing and backoff
//lm need to implement cancellation

#pragma mark - Overrides

+(Class)thriftServiceClass {
    return GBChatGoonbeeChatServiceClient.class;
}

#pragma mark - API calls

-(void)isUsernameAvailable:(NSString *)username completed:(GBThriftCallCompletionBlock)block {
    [self callAPIMethodWithSelector:@selector(isUsernameAvailable:) block:block arguments:&username, nil];
}

-(void)registerUsernameWithUserId:(NSString *)userId username:(NSString *)username completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(registerUsername:username:) block:block arguments:&userId, &username, nil];
}

-(void)newChatWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(newChat:chatId:chatOptions:) block:block arguments:&userId, &chatId, &chatOptions, nil];
}

-(void)chatsWithSorting:(enum GBChatChatSorting)chatSorting range:(GBSharedRange *)range completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(chats:range:) block:block arguments:&chatSorting, &range, nil];
}

-(void)chatWithUserId:(NSString *)userId chatId:(NSString *)chatId completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(chat:chatId:) block:block arguments:&userId, &chatId, nil];
}

-(void)newMessageWithUserId:(NSString *)userId chatId:(NSString *)chatId message:(NSString *)content completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(newMessage:chatId:content:) block:block arguments:&userId, &chatId, &content, nil];
}

-(void)messagesWithUserId:(NSString *)userId chatId:(NSString *)chatId range:(GBSharedRange *)range completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(messages:chatId:range:) block:block arguments:&userId, &chatId, &range, nil];
}

-(void)setChatOptionsWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(setChatOptions:chatId:chatOptions:) block:block arguments:&userId, &chatId, &chatOptions, nil];
}

-(void)globalUserCountCompleted:(GBThriftCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(globalUserCount) block:block arguments:nil];
}

@end
