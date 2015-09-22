//
//  KSWebClient.m
//  Kuber
//
//  Created by Asif Kamboh on 5/12/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "KSWebClient.h"
#import "AFNetworking.h"

#import "NSObject+KSNullRemoval.h"

@implementation KSWebClientConfig

+ (instancetype)config {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *webConfig = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"WebClientConfig"];
        NSString *webServiceUrl = [webConfig valueForKey:@"url"];
        NSString *relativePath = [[NSURL URLWithString:webServiceUrl] relativePath];
        if (relativePath.length) {
            _serviceUri = relativePath;
            _baseUrl = [webServiceUrl componentsSeparatedByString:relativePath][0];
        }
        else {
            _serviceUri = @"";
            _baseUrl = webServiceUrl;
        }
        _format = [webConfig valueForKey:@"format"];
    }
    return self;
}

@end

@interface KSWebClient ()
{
    AFHTTPSessionManager *_sessionManager;
    KSWebClientConfig *_webClientConfig;
}

@end
@implementation KSWebClient

+ (instancetype)instance {
    static KSWebClient *_instance = nil;
    static dispatch_once_t dispatchQueueToken;

    dispatch_once(&dispatchQueueToken, ^{
        _instance = [[KSWebClient alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        NSString *baseUrl = @"http://certappserver.dmc.hct.ac.ae";
        _webClientConfig = [KSWebClientConfig config];

        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_webClientConfig.baseUrl]];

        // TODO: Make it based on format key of WebClientConfig in info.plist
        if ([_webClientConfig.format isEqualToString:@"xml"]) {
            _sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        }
    }
    return self;
}

- (NSString *)completeURI:(NSString *)uri {
    
    BOOL startsWithSlash = ([uri rangeOfString:@"/"].location == 0);
    NSUInteger lastIndex = uri.length - 1;
    BOOL endsWithSlash = [uri rangeOfString:@"/" options:NSBackwardsSearch].location == lastIndex;
    NSString *formatString;
    if (startsWithSlash) {
        formatString = @"%@%@";
    }
    else {
        formatString = @"%@/%@";
    }
    // The API doesn't work without trailing slash
    if (!endsWithSlash) {
        formatString = [formatString stringByAppendingString:@"/"];
    }

    return [NSString stringWithFormat:formatString, _webClientConfig.serviceUri, uri];
}

- (void)sendRequestWithMethod:(NSString *)method uri:(NSString *)uri params:(NSDictionary *)params completion:(KSWebClientCompletionBlock)completionBlock {

        uri = [self completeURI:uri];
        void (^successBlock)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
            //NSLog(@"%@ %@ %@", method, uri, responseObject);
            if ([_webClientConfig.format isEqualToString:@"xml"]) {
                KSWebClientXMLResponseParser *parser = [KSWebClientXMLResponseParser new];
                [parser parseResponse:(NSXMLParser *)responseObject completion:^(id responseData) {
                    completionBlock(YES, [responseData objectIfNotNSNull]);
                }];
            }
            else {
                completionBlock(YES, [responseObject objectIfNotNSNull]);
            }
        };
    
        void (^failBlock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@ %@ %@", method, uri, error);
            if ([error.domain isEqualToString:@"NSURLErrorDomain"] && error.code == -1009) {
                NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:KSAPIStatusNoInternet],@"status", nil];
                completionBlock(YES,response);
            }
            else
            {
                long errorCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
                NSDictionary *response = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:errorCode],@"status", nil];
                
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"HTTP Errors"     // Event category (required)
                                                                      action:@"Server Call"  // Event action (required)
                                                                       label:[NSString stringWithFormat:@"Error Code: %ld",errorCode]         // Event label
                                                                       value:[NSNumber numberWithLong:errorCode]] build]];    // Event value
            
                completionBlock(YES,response);
            }
        };

        // Authentication header
        KSSessionInfo *session = [KSSessionInfo currentSession];
        if (session.sessionId.length) {
            AFHTTPRequestSerializer *serializer = _sessionManager.requestSerializer;
            [serializer setValue:session.sessionId forHTTPHeaderField:@"Session-ID"];
            serializer.timeoutInterval = 20;
        }
    
    
        if ([method isEqualToString:@"DELETE"]) {
            [_sessionManager DELETE:uri parameters:params success:successBlock failure:failBlock];
        }
        else if ([method isEqualToString:@"POST"]) {
            [_sessionManager POST:uri parameters:params success:successBlock failure:failBlock];
        }
        else {
            [_sessionManager GET:uri parameters:params success:successBlock failure:failBlock];
        }
    //}
}

- (void)GET:(NSString *)uri params:(NSDictionary *)params completion:(KSWebClientCompletionBlock)completionBlock {

    [self sendRequestWithMethod:@"GET" uri:uri params:params completion:completionBlock];
}

- (void)POST:(NSString *)uri data:(NSDictionary *)data completion:(KSWebClientCompletionBlock)completionBlock {

    [self sendRequestWithMethod:@"POST" uri:uri params:data completion:completionBlock];
}

- (void)DELETE:(NSString *)uri completion:(KSWebClientCompletionBlock)completionBlock {

    [self sendRequestWithMethod:@"DELETE" uri:uri params:nil completion:completionBlock];
}

@end

@interface KSWebClientXMLResponseParser ()
{
    NSString *_parsedString;
}
@end

@implementation KSWebClientXMLResponseParser

- (BOOL)parseResponse:(NSXMLParser *)response completion:(KSWebClientXMLResponseParserCompletionBlock)completionBlock {
    _completionBlock = completionBlock;
    response.delegate = self;
    return [response parse];
}

#pragma mark -
#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    _parsedString = string;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    _completionBlock(_parsedString);
}

@end

