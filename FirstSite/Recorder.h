@protocol RecorderDelegate <NSObject>
- (void)recordedFreq:(float)freq  debug2Text:(NSString *)debug2Text;
@end
@interface Recorder : NSObject
{
}

@property (nonatomic, weak) id <RecorderDelegate> delegate;

@end
