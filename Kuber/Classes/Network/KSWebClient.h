//
//  KSWebClient.h
//  Kuber
//
//  Created by Asif Kamboh on 5/12/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^KSWebClientCompletionBlock)(BOOL, id);

@interface KSWebClient : NSObject

+ (instancetype)instance;

- (void)GET:(NSString *)uri params:(NSDictionary *)params completion:(KSWebClientCompletionBlock)completionBlock;

- (void)POST:(NSString *)uri data:(NSDictionary *)data completion:(KSWebClientCompletionBlock)completionBlock;

@end

typedef void (^KSWebClientXMLResponseParserCompletionBlock)(id);
@interface KSWebClientXMLResponseParser : NSObject<NSXMLParserDelegate>
{
    KSWebClientXMLResponseParserCompletionBlock _completionBlock;
}

- (BOOL)parseResponse:(NSXMLParser *)response completion:(KSWebClientXMLResponseParserCompletionBlock)completionBlock;

@end

@interface KSWebClientConfig : NSObject

@property (nonatomic, strong, readonly) NSString *baseUrl;
@property (nonatomic, strong, readonly) NSString *serviceUri;
@property (nonatomic, strong, readonly) NSString *format;

@end

