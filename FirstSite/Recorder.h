@protocol RecorderDelegate <NSObject>
- (void)recordedFreq:(float)freq;
@end
@interface Recorder : NSObject
{
}

@property (nonatomic, weak) id <RecorderDelegate> delegate;

@end
