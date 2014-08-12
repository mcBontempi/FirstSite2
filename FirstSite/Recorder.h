@protocol RecorderDelegate <NSObject>
- (void)recordedFreq:(float)freq  debugText:(NSString *)debug2Text;
- (void)error;
@end
@interface Recorder : NSObject
{
}

@property (nonatomic, weak) id <RecorderDelegate> delegate;

@end
