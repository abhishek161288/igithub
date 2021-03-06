//
//  ObjGitCommit.m
//  ObjGit
//

#import "ObjGitObject.h"
#import "ObjGitCommit.h"

@implementation ObjGitCommit

@synthesize	parentShas;
@synthesize treeSha;
@synthesize author;
@synthesize author_email;
@synthesize	authored_date;
@synthesize committer;
@synthesize committer_email;
@synthesize committed_date;
@synthesize message;
@synthesize git_object;
@synthesize sha;

- (id) initFromGitObject:(ObjGitObject *)gitObject {
	self = [super init];	
	self.sha = [gitObject sha];
	self.git_object = gitObject;
	[self parseContent];
	return self;
}

- (id) initFromRaw:(NSData *)rawData withSha:(NSString *)shaValue
{
	self = [super init];	
	self.git_object = [[ObjGitObject alloc] initFromRaw:rawData withSha:shaValue];
	self.sha = shaValue;
	[self parseContent];
	//[self logObject];
	return self;
}

- (void) logObject
{
	NSLog(@"tree     : %@", treeSha);
	NSLog(@"author   : %@, %@ : %@", author, author_email, authored_date);
	NSLog(@"committer: %@, %@ : %@", committer, committer_email, committed_date);
	NSLog(@"parents  : %@", parentShas);
	NSLog(@"message  : %@", message);
}

- (NSArray *) authorArray 
{
	return [NSArray arrayWithObjects:self.author, self.author_email, self.authored_date, nil];
}

- (void) parseContent
{
	// extract parent shas, tree sha, author/committer info, message
	NSArray			*lines = [self.git_object.contents componentsSeparatedByString:@"\n"];
	NSEnumerator	*enumerator;
	NSMutableArray	*parents;
	NSMutableString *buildMessage;
	NSString		*line, *key, *val;
	int inMessage = 0;

	buildMessage = [NSMutableString new];
	parents		 = [NSMutableArray new];
	
	enumerator = [lines objectEnumerator];
	while ((line = [enumerator nextObject]) != nil) {
		// NSLog(@"line: %@", line);
		if(!inMessage) {
			if([line length] == 0) {
				inMessage = 1;
			} else {
				NSArray *values = [line componentsSeparatedByString:@" "];
				key = [values objectAtIndex: 0];			
				val = [values objectAtIndex: 1];			
				if([key isEqualToString: @"tree"]) {
					self.treeSha = val;
				} else if ([key isEqualToString: @"parent"]) {
					[parents addObject: val];
				} else if ([key isEqualToString: @"author"]) {
					NSArray *name_email_date = [self parseAuthorString:line withType:@"author "];
					self.author		  = [name_email_date objectAtIndex: 0];
					self.author_email  = [name_email_date objectAtIndex: 1];
					self.authored_date = [name_email_date objectAtIndex: 2];
				} else if ([key isEqualToString: @"committer"]) {
					NSArray *name_email_date = [self parseAuthorString:line withType:@"committer "];
					self.committer		 = [name_email_date objectAtIndex: 0];
					self.committer_email  = [name_email_date objectAtIndex: 1];
					self.committed_date   = [name_email_date objectAtIndex: 2];
				}
			}
		} else {
			[buildMessage appendString: line];
			[buildMessage appendString: @"\n"];
		}
    }
	self.message = buildMessage;
	self.parentShas = parents;
}

- (NSArray *) parseAuthorString:(NSString *)authorString withType:(NSString *)typeString
{
	NSArray *name_email_date;
	name_email_date = [authorString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	
	NSString *nameVal  = [name_email_date objectAtIndex: 0];
	NSString *emailVal = [name_email_date objectAtIndex: 1];
	NSString *dateVal  = [name_email_date objectAtIndex: 2];
	NSDate   *dateDateVal;
	dateDateVal = [NSDate dateWithTimeIntervalSince1970:[dateVal doubleValue]];
	
	NSMutableString *tempValue = [[NSMutableString alloc] init];
	[tempValue setString:nameVal];
	[tempValue replaceOccurrencesOfString: typeString
							   withString: @""
								  options: 0
									range: NSMakeRange(0, [tempValue length])];
	
	return [NSArray arrayWithObjects:tempValue, emailVal, dateDateVal, nil];
}

@end
