//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface GitHTTPConnection : HTTPConnection
{
	NSString* gitService;
	NSFileHandle* packfile;
}

- (BOOL)isBrowseable:(NSString *)path;
- (NSString *)createBrowseableIndex:(NSString *)path;

- (NSObject<HTTPResponse> *)indexPage;
- (NSObject<HTTPResponse> *)plainResponse:(NSString *)project path:(NSString *)path;

- (NSObject<HTTPResponse> *)advertiseRefs:(NSString *)repository;

- (NSObject<HTTPResponse> *)receivePack:(NSString *)project;
- (NSObject<HTTPResponse> *)uploadPack:(NSString *)project;

- (NSString*) prependPacketLine:(NSString*) info;
- (NSData*) packetData:(NSString*) info;

@end