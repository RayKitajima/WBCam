
#import "PhotoMetaData.h"

@implementation PhotoMetaData
@synthesize iso_day, file_name;
@synthesize photo_orientation;
@synthesize comment;
@synthesize meta;

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:iso_day forKey:@"iso_day"];
    [coder encodeObject:file_name forKey:@"file_name"];
    [coder encodeObject:photo_orientation forKey:@"photo_orientation"];
    [coder encodeObject:comment forKey:@"comment"];
    [coder encodeObject:meta forKey:@"meta"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    iso_day = [decoder decodeObjectForKey:@"iso_day"];
    file_name = [decoder decodeObjectForKey:@"file_name"];
    photo_orientation = [decoder decodeObjectForKey:@"photo_orientation"];
    comment = [decoder decodeObjectForKey:@"comment"];
    meta = [decoder decodeObjectForKey:@"meta"];
    
    return self;
}

@end

