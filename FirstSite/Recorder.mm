
#import "Recorder.h"

#include <vector>
using namespace std;





// ===================================================================
//  EstimatePeriod
//
//  Returns best estimate of period.
// ===================================================================
double EstimatePeriod(
                      const double    *x,         //  Sample data.
                      const int       n,          //  Number of samples.  Should be at least 2 x maxP
                      const int       minP,       //  Minimum period of interest
                      const int       maxP,       //  Maximum period
                      double&         q )         //  Quality (1= perfectly periodic)
{
    assert( minP > 1 );
    assert( maxP > minP );
    assert( n >= 2*maxP );
    assert( x != NULL );
    
    q = 0;
    
    //  --------------------------------
    //  Compute the normalized autocorrelation (NAC).  The normalization is such that
    //  if the signal is perfectly periodic with (integer) period p, the NAC will be
    //  exactly 1.0.  (Bonus: NAC is also exactly 1.0 for periodic signal
    //  with exponential decay or increase in magnitude).
    
    vector<double> nac(maxP+1);
    
    for ( int p =  minP-1; p <= maxP+1; p++ )
    {
        double ac = 0.0;        // Standard auto-correlation
        double sumSqBeg = 0.0;  // Sum of squares of beginning part
        double sumSqEnd = 0.0;  // Sum of squares of ending part
        
        for ( int i = 0; i < n-p; i++ )
        {
            ac += x[i]*x[i+p];
            sumSqBeg += x[i]*x[i];
            sumSqEnd += x[i+p]*x[i+p];
        }
        nac[p] = ac / sqrt( sumSqBeg * sumSqEnd );
    }
    
    //  ---------------------------------------
    //  Find the highest peak in the range of interest.
    
    //  Get the highest value
    int bestP = minP;
    for ( int p = minP; p <= maxP; p++ )
        if ( nac[p] > nac[bestP] )
            bestP = p;
    
    //  Give up if it's highest value, but not actually a peak.
    //  This can happen if the period is outside the range [minP, maxP]
    if ( nac[bestP] < nac[bestP-1]
        && nac[bestP] < nac[bestP+1] )
    {
        return 0.0;
    }
    
    //  "Quality" of periodicity is the normalized autocorrelation
    //  at the best period (which may be a multiple of the actual
    //  period).
    q = nac[bestP];
    
    
    //  --------------------------------------
    //  Interpolate based on neighboring values
    //  E.g. if value to right is bigger than value to the left,
    //  real peak is a bit to the right of discretized peak.
    //  if left  == right, real peak = mid;
    //  if left  == mid,   real peak = mid-0.5
    //  if right == mid,   real peak = mid+0.5
    
    double mid   = nac[bestP];
    double left  = nac[bestP-1];
    double right = nac[bestP+1];
    
    assert( 2*mid - left - right > 0.0 );
    
    double shift = 0.5*(right-left) / ( 2*mid - left - right );
    
    double pEst = bestP + shift;
    
    //  -----------------------------------------------
    //  If the range of pitches being searched is greater
    //  than one octave, the basic algo above may make "octave"
    //  errors, in which the period identified is actually some
    //  integer multiple of the real period.  (Makes sense, as
    //  a signal that's periodic with period p is technically
    //  also period with period 2p).
    //
    //  Algorithm is pretty simple: we hypothesize that the real
    //  period is some "submultiple" of the "bestP" above.  To
    //  check it, we see whether the NAC is strong at each of the
    //  hypothetical subpeak positions.  E.g. if we think the real
    //  period is at 1/3 our initial estimate, we check whether the
    //  NAC is strong at 1/3 and 2/3 of the original period estimate.
    
    const double k_subMulThreshold = 0.90;  //  If strength at all submultiple of peak pos are
    //  this strong relative to the peak, assume the
    //  submultiple is the real period.
    
    //  For each possible multiple error (starting with the biggest)
    int maxMul = bestP / minP;
    bool found = false;
    for ( int mul = maxMul; !found && mul >= 1; mul-- )
    {
        //  Check whether all "submultiples" of original
        //  peak are nearly as strong.
        bool subsAllStrong = true;
        
        //  For each submultiple
        for ( int k = 1; k < mul; k++ )
        {
            int subMulP = int(k*pEst/mul+0.5);
            //  If it's not strong relative to the peak NAC, then
            //  not all submultiples are strong, so we haven't found
            //  the correct submultiple.
            if ( nac[subMulP] < k_subMulThreshold * nac[bestP] )
                subsAllStrong = false;
            
            //  TODO: Use spline interpolation to get better estimates of nac
            //  magnitudes for non-integer periods in the above comparison
        }
        
        //  If yes, then we're done.   New estimate of
        //  period is "submultiple" of original period.
        if ( subsAllStrong == true )
        {
            found = true;
            pEst = pEst / mul;
        }
    }
    
    return pEst;
}






// Wikipedia: In terms of frequency, human voices are roughly in the range of 
// 80 Hz to 1100 Hz (that is, E2 to C6).
const float MIN_FREQ = 50.0f;
const float MAX_FREQ = 1500.0f;

@interface Recorder (Private)
- (void)setUpAudioFormat;
- (UInt32)numPacketsForTime:(Float64)seconds;
- (UInt32)byteSizeForNumPackets:(UInt32)numPackets;
- (void)primeRecordQueueBuffers;
- (void)setUpRecordQueue;
- (void)setUpRecordQueueBuffers;
@end

@implementation Recorder

@synthesize delegate;
@synthesize recording;
@synthesize trackingPitch;
@synthesize recordQueue;
@synthesize bufferByteSize;
@synthesize bufferNumPackets;

static void recordCallback(
	void* inUserData,
	AudioQueueRef inAudioQueue,
	AudioQueueBufferRef inBuffer,
	const AudioTimeStamp* inStartTime,
	UInt32 inNumPackets,
	const AudioStreamPacketDescription* inPacketDesc)
{
	Recorder* recorder = (__bridge Recorder*) inUserData;
	if (!recorder.recording)
		return;

	if (inNumPackets > 0)  // we have data
		[recorder recordedBuffer:(UInt8*)inBuffer->mAudioData byteSize:inBuffer->mAudioDataByteSize];

	AudioQueueEnqueueBuffer(inAudioQueue, inBuffer, 0, NULL);
}

- (id)init
{
	if ((self = [super init]))
	{
		recording = NO;
		[self setUpAudioFormat];
		[self setUpRecordQueue];
		[self setUpRecordQueueBuffers];
	}
	return self;
}

- (void)setUpAudioFormat
{
	audioFormat.mFormatID         = kAudioFormatLinearPCM;
	audioFormat.mSampleRate       = 44100;
	audioFormat.mChannelsPerFrame = 1;
	audioFormat.mBitsPerChannel   = 16;
	audioFormat.mFramesPerPacket  = 1;
	audioFormat.mBytesPerFrame    = audioFormat.mChannelsPerFrame * sizeof(SInt16); 
	audioFormat.mBytesPerPacket   = audioFormat.mBytesPerFrame * audioFormat.mFramesPerPacket;
	audioFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger 
	                              | kLinearPCMFormatFlagIsPacked;

	bufferNumPackets = 2048*4;  // must be power of 2 for FFT!
	bufferByteSize = [self byteSizeForNumPackets:bufferNumPackets];

	//NSLog(@"Recorder bufferNumPackets %u", bufferNumPackets);
	//NSLog(@"Recorder bufferByteSize %u", bufferByteSize);
	
	//init_fft(bufferNumPackets, audioFormat.mSampleRate);
}

- (UInt32)numPacketsForTime:(Float64)seconds
{
	return (UInt32) (seconds * audioFormat.mSampleRate / audioFormat.mFramesPerPacket);
}

- (UInt32)byteSizeForNumPackets:(UInt32)numPackets
{
	return numPackets * audioFormat.mBytesPerPacket;
}

- (void)setUpRecordQueue
{
	AudioQueueNewInput(
		&audioFormat,
		recordCallback,
		(__bridge void *)(self),                // userData
		CFRunLoopGetMain(),  // run loop
		NULL,                // run loop mode
		0,                   // flags
		&recordQueue);
}

- (void)setUpRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueAllocateBuffer(
			recordQueue,
			bufferByteSize,
			&recordQueueBuffers[t]);
	}
}

- (void)primeRecordQueueBuffers
{
	for (int t = 0; t < NUMBER_AUDIO_DATA_BUFFERS; ++t)
	{
		AudioQueueEnqueueBuffer(
			recordQueue,
			recordQueueBuffers[t],
			0,
			NULL);
	}
}

- (void)startRecording
{
	recording = YES;
	[self primeRecordQueueBuffers];
	AudioQueueStart(recordQueue, NULL);
}

- (void)stopRecording
{
	AudioQueueStop(recordQueue, TRUE);
	recording = NO;
}

- (void)recordedBuffer:(UInt8*)buffer byteSize:(UInt32)byteSize
{
	if (trackingPitch)
	{
        
        
        /*
	//	float freq = find_pitch(buffer, MIN_FREQ, MAX_FREQ);
        
        
        
        const double pi = 4*atan(1);
        
        const double sr = 44100;        //  Sample rate.
        const double minF = 27.5;       //  Lowest pitch of interest (27.5 = A0, lowest note on piano.)
        const double maxF = 4186.0;     //  Highest pitch of interest(4186 = C8, highest note on piano.)
        
        const int minP = int(sr/maxF-1);    //  Minimum period
        const int maxP = int(sr/minF+1);    //  Maximum period
        
        //  Generate a test signal
        
        const double A440 = 440.0;              //  A440
        double f = A440 * pow(2.0,-9.0/12.0);   //  Middle C (9 semitones below A440)
        
        double p  = sr/f;
        double q;
        const int n = 2*maxP;
        double x[100000];
        
        
        
        
        for ( int k = 0; k < byteSize; k+=2 )
        {
            float f;
            UInt8 i1 = buffer[k];
            UInt8 i2 = buffer[k+1];
            
            short i = i1;
            i = i<<8;
            i = i | i2;
            
            f = ((float) i) / (float) 32768;
            if( f > 1 ) f = 1;
            if( f < -1 ) f = -1;
            
            
            x[k/2] = f;

        }
        
        //  TODO: Add low-pass filter to remove very high frequency
        //  energy. Harmonics above about 1/4 of Nyquist tend to mess
        //  things up, as their periods are often nowhere close to
        //  integer numbers of samples.
        
        //  Estimate the period
        double pEst = EstimatePeriod( x, byteSize/2, minP, maxP, q );
        
        //  Compute the fundamental frequency (reciprocal of period)
        double fEst = 0;
        if ( pEst > 0 )
            fEst = sr/pEst;
        
        printf( "Actual freq:         %8.3lf\n", f );
        printf( "Estimated freq:      %8.3lf\n", sr/pEst );
        printf( "Error (cents):       %8.3lf\n", 100*12*log(fEst/f)/log(2) );
        printf( "Periodicity quality: %8.3lf\n", q );
        
        
        double fre = EstimatePeriod(
                              buffer,
                              byteSize,
                              minP,
                              maxP,       //  Maximum period
                                  q );         //  Quality (1= perfectly periodic)
        */
        
        const double pi = 4*atan(1);
        
        const double sr = 44100;        //  Sample rate.
        const double minF = 27.5;       //  Lowest pitch of interest (27.5 = A0, lowest note on piano.)
        const double maxF = 4186.0;     //  Highest pitch of interest(4186 = C8, highest note on piano.)
        
        const int minP = int(sr/maxF-1);    //  Minimum period
        const int maxP = int(sr/minF+1);    //  Maximum period
        
        //  Generate a test signal
        
        const double A440 = 440.0;              //  A440
        double f = A440 * pow(2.0,-9.0/12.0);   //  Middle C (9 semitones below A440)
        
        double p  = sr/f;
        double q;
        const int n = 2*maxP;
        double x[n];
        
        for ( int k = 0; k < n; k++ )
        {
            x[k] = 0;
            x[k] += 1.0*sin(2*pi*1*k/p);    //  First harmonic
            x[k] += 0.6*sin(2*pi*2*k/p);    //  Second harmonic
            x[k] += 0.3*sin(2*pi*3*k/p);    //  Third harmonic
        }
        
        //  TODO: Add low-pass filter to remove very high frequency
        //  energy. Harmonics above about 1/4 of Nyquist tend to mess
        //  things up, as their periods are often nowhere close to
        //  integer numbers of samples.
        
        //  Estimate the period
        double pEst = EstimatePeriod( x, n, minP, maxP, q );
        
        //  Compute the fundamental frequency (reciprocal of period)
        double fEst = 0;
        if ( pEst > 0 )
            fEst = sr/pEst;
        
        printf( "Actual freq:         %8.3lf\n", f );
        printf( "Estimated freq:      %8.3lf\n", sr/pEst );
        printf( "Error (cents):       %8.3lf\n", 100*12*log(fEst/f)/log(2) );
        printf( "Periodicity quality: %8.3lf\n", q );
        
        
		[delegate recordedFreq:f];
	}
}

- (void)dealloc
{
//	done_fft();
	AudioQueueDispose(recordQueue, YES);
}


@end
