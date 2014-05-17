//
//  GBChat.m
//  World Cup Survival Guide
//
//  Created by Luka Mirosevic on 27/04/2014.
//  Copyright (c) 2014 Goonbee. All rights reserved.
//

#import "GBChat.h"

#import <malloc/malloc.h>

#import <thrift/TSocketClient.h>
#import <thrift/TBinaryProtocol.h>
#import <thrift/TTransportException.h>

static NSUInteger const kDefaultPort =                              56475;

typedef NS_ENUM(NSInteger, CallTechnicalStatus) {
    CallTechnicalStatusSuccess,
    CallTechnicalStatusRecoverableError,
    CallTechnicalStatusNonRecoverableError,
};

@interface GBChatInvocationResult : NSObject

@property (assign, nonatomic) CallTechnicalStatus                   technicalStatus;
@property (assign, nonatomic) enum GBChatResponseStatus             responseStatus;
@property (strong, nonatomic) id                                    result;

@end

@implementation GBChatInvocationResult

+(instancetype)invocationResultWithTechicalStatus:(CallTechnicalStatus)technicalStatus responseStatus:(enum GBChatResponseStatus)responseStatus result:(id)result {
    GBChatInvocationResult *invocationResult = [self new];
    invocationResult.technicalStatus = technicalStatus;
    invocationResult.responseStatus = responseStatus;
    invocationResult.result = result;
    
    return invocationResult;
}

@end

@interface GBChat ()

@property (strong, nonatomic) GBChatGoonbeeChatServiceClient        *server;
@property (copy, nonatomic) NSString                                *serverUrl;
@property (assign, nonatomic) NSUInteger                            serverPort;

@end

@implementation GBChat

//lm need automatic reconnection to server if something goes wrong, with request queing and backoff
//lm need to implement cancellation

#pragma mark - Mem

+(instancetype)sharedChat {
    static GBChat *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [GBChat new];
    });
    return sharedInstance;
}

#pragma mark - Plumbing

-(void)connectToServer:(NSString *)server port:(NSUInteger)port {
    self.serverUrl = server;
    self.serverPort = port ?: kDefaultPort;
    
    [self _connect];
}

-(void)_connect {
    TSocketClient *transport = [[TSocketClient alloc] initWithHostname:self.serverUrl port:self.serverPort];
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:transport strictRead:YES strictWrite:YES];
    self.server = [[GBChatGoonbeeChatServiceClient alloc] initWithProtocol:protocol];
}


-(GBChatInvocationResult *)_invokeAndProcessInvocation:(NSInvocation *)invocation {
    CallTechnicalStatus technicalStatus;
    enum GBChatResponseStatus responseStatus;
    
    // attempt to make the call
    @try {
        [invocation invoke];
        
        technicalStatus = CallTechnicalStatusSuccess;
        responseStatus = ResponseStatus_SUCCESS;
    }
    @catch (GBChatRequestError *error) {
        technicalStatus = CallTechnicalStatusSuccess;
        responseStatus = (enum GBChatResponseStatus)error.status;
    }
    @catch (TTransportException *transportException) {
        // 61 = couldn't connect
        // 32 = connection severed in the middle
        // ((NSError *)transportException.userInfo[@"error"]).code
        
        technicalStatus = CallTechnicalStatusRecoverableError;
        responseStatus = ResponseStatus_GENERIC;
    }
    @catch (TException *exception) {
        technicalStatus = CallTechnicalStatusNonRecoverableError;
        responseStatus = ResponseStatus_GENERIC;
    }
    
    // attempt to get a result from the call
    id result;
    switch (technicalStatus) {
        case CallTechnicalStatusSuccess: {
            // check whether the return type is an object or not
            Method method = class_getInstanceMethod([invocation.target class], invocation.selector);
            char *methodReturnType = method_copyReturnType(method);
            
            // object type
            if ([@(methodReturnType) isEqualToOneOf:@[@("@")]]) {
                void *buffer;
                [invocation getReturnValue:&buffer];
                
                result = (__bridge id)buffer;
            }
            // primitive type
            else if ([@(methodReturnType) isEqualToOneOf:@[@("c"), @("i"), @("s"), @("l"), @("q"), @("C"), @("I"), @("S"), @("L"), @("Q"), @("f"), @("d"), @("B"), @("*")]]) {
                NSUInteger length = [[invocation methodSignature] methodReturnLength];
                void *buffer = malloc(length);
                [invocation getReturnValue:buffer];
                
                // create an object from the buffer
                id bufferObject;
                if (strcmp(methodReturnType, "c") == 0) {
                    bufferObject = [NSNumber numberWithChar:*(char *)buffer];
                }
                else if (strcmp(methodReturnType, "i") == 0) {
                    bufferObject = [NSNumber numberWithInt:*(int *)buffer];
                }
                else if (strcmp(methodReturnType, "s") == 0) {
                    bufferObject = [NSNumber numberWithShort:*(short *)buffer];
                }
                else if (strcmp(methodReturnType, "l") == 0) {
                    bufferObject = [NSNumber numberWithLong:*(long *)buffer];
                }
                else if (strcmp(methodReturnType, "q") == 0) {
                    bufferObject = [NSNumber numberWithLongLong:*(long long *)buffer];
                }
                else if (strcmp(methodReturnType, "C") == 0) {
                    bufferObject = [NSNumber numberWithUnsignedChar:*(unsigned char *)buffer];
                }
                else if (strcmp(methodReturnType, "I") == 0) {
                    bufferObject = [NSNumber numberWithUnsignedInt:*(unsigned int *)buffer];
                }
                else if (strcmp(methodReturnType, "S") == 0) {
                    bufferObject = [NSNumber numberWithUnsignedShort:*(unsigned short *)buffer];
                }
                else if (strcmp(methodReturnType, "L") == 0) {
                    bufferObject = [NSNumber numberWithUnsignedLong:*(unsigned long *)buffer];
                }
                else if (strcmp(methodReturnType, "Q") == 0) {
                    bufferObject = [NSNumber numberWithUnsignedLongLong:*(unsigned long long *)buffer];
                }
                else if (strcmp(methodReturnType, "f") == 0) {
                    bufferObject = [NSNumber numberWithFloat:*(float *)buffer];
                }
                else if (strcmp(methodReturnType, "d") == 0) {
                    bufferObject = [NSNumber numberWithDouble:*(double *)buffer];
                }
                else if (strcmp(methodReturnType, "B") == 0) {
                    bufferObject = [NSNumber numberWithBool:*(BOOL *)buffer];
                }
                else if (strcmp(methodReturnType, "*") == 0) {
                    bufferObject = [NSString stringWithUTF8String:*(char **)buffer];
                }
                
                // assign the stuff
                result = bufferObject;
                
                // cleanup
                free(buffer);
            }
            // void
            else if ([@(methodReturnType) isEqualToOneOf:@[@("v")]]) {
                result = nil;
            }
            // bad type
            else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:_f(@"The method returned a type which the wrapper was unable to handle: %s", methodReturnType) userInfo:nil];
            }
            
            // cleanup
            free(methodReturnType);
        } break;
            
        case CallTechnicalStatusRecoverableError: {
            result = nil;
        } break;
            
        case CallTechnicalStatusNonRecoverableError: {
            result = nil;
        } break;
    }
    
    // return an object representing what happened
    return [GBChatInvocationResult invocationResultWithTechicalStatus:technicalStatus responseStatus:responseStatus result:result];
}


-(void)callAPIMethodWithSelector:(SEL)selector block:(GBChatCallCompletionBlock)block arguments:(void *)argument, ... NS_REQUIRES_NIL_TERMINATION {
//    [self _connect];//lm kill
    
    if (!self.server) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Must connect to server before making any calls" userInfo:nil];
    
    // prepare the invocation
    va_list argumentList;
    va_start(argumentList, argument);
    NSInvocation *invocation = [NSInvocation invocationWithTarget:self.server selector:selector argument:argument argumentList:argumentList];
    va_end(argumentList);
    
    // invoke and process the invocation
    GBChatInvocationResult *invocationResult = [self _invokeAndProcessInvocation:invocation];
    
    switch (invocationResult.technicalStatus) {
        case CallTechnicalStatusSuccess:
        case CallTechnicalStatusNonRecoverableError: {
            // any specific processing to do for application level response statuses
            switch (invocationResult.responseStatus) {
                case ResponseStatus_SUCCESS: {
                } break;
                    
                case ResponseStatus_GENERIC: {
                } break;
                    
                case ResponseStatus_MALFORMED_REQUEST: {
                } break;
                    
                case ResponseStatus_AUTHENTICATION: {
                } break;
                    
                case ResponseStatus_AUTHORIZATION: {
                } break;
                    
                case ResponseStatus_PHASED_OUT: {
                } break;
            }
            
            // call callback block
            if (block) block(invocationResult.responseStatus, invocationResult.result, NO);
        } break;
            
        case CallTechnicalStatusRecoverableError: {
            // attempt recovery and replay the request a little bit later
            //lm TODO
            
            //lm for now just do the simple thing and fail immediately
            if (block) block(invocationResult.responseStatus, invocationResult.result, NO);
        } break;
    }
}

#pragma mark - API calls

-(void)isUsernameAvailable:(NSString *)username completed:(GBChatCallCompletionBlock)block {
    [self callAPIMethodWithSelector:@selector(isUsernameAvailable:) block:block arguments:&username, nil];
}

-(void)registerUsernameWithUserId:(NSString *)userId username:(NSString *)username completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(registerUsername:username:) block:block arguments:&userId, &username, nil];
}

-(void)newChatWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(newChat:chatId:chatOptions:) block:block arguments:&userId, &chatId, &chatOptions, nil];
}

-(void)chatsWithSorting:(enum GBChatChatSorting)chatSorting range:(GBChatRange *)range completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(chats:range:) block:block arguments:&chatSorting, &range, nil];
}

-(void)chatWithUserId:(NSString *)userId chatId:(NSString *)chatId completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(chat:chatId:) block:block arguments:&userId, &chatId, nil];
}

-(void)newMessageWithUserId:(NSString *)userId chatId:(NSString *)chatId message:(NSString *)content completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(newMessage:chatId:content:) block:block arguments:&userId, &chatId, &content, nil];
}

-(void)messagesWithUserId:(NSString *)userId chatId:(NSString *)chatId range:(GBChatRange *)range completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(messages:chatId:range:) block:block arguments:&userId, &chatId, &range, nil];
}

-(void)setChatOptionsWithUserId:(NSString *)userId chatId:(NSString *)chatId chatOptions:(GBChatChatOptions *)chatOptions completed:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(setChatOptions:chatId:chatOptions:) block:block arguments:&userId, &chatId, &chatOptions, nil];
}

-(void)globalUserCountCompleted:(GBChatCallCompletionBlock)block {
	[self callAPIMethodWithSelector:@selector(globalUserCount) block:block arguments:nil];
}

@end
