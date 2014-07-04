
#import "Recorder.h"
#import <Novocaine.h>
#import <RingBuffer.h>


#include <vector>
using namespace std;

@implementation Recorder {
    RingBuffer *_ringBuffer;
    Novocaine *_audioManager;

    // shabby, its just whats fastest though
    double _x[100000];
    int _xoffset;
    double _lastEF;


}

@synthesize delegate;

- (id)init
{
	if ((self = [super init]))
	{
        [self setupAudio];
	}
	return self;
}



- (void)setupAudio
{
    _ringBuffer = new RingBuffer(100000, 2);
    _audioManager = [Novocaine audioManager];
    
    __weak Recorder *weakSelf = self;
    
    [_audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        
      //  NSLog(@"%d", numFrames);
        
        if(_xoffset < 10000) {
            for (int i = 0; i < numFrames; i++)
            {
                _x[_xoffset++] = data[i];
            }
        }
        else {
            
            const double sr = 44100;        //  Sample rate.
            const double minF = 27.5;       //  Lowest pitch of interest (27.5 = A0, lowest note on piano.)
            const double maxF = 4186;     //  Highest pitch of interest(4186 = C8, highest note on piano.)
            
            const int minP = int(sr/maxF-1);    //  Minimum period
            const int maxP = int(sr/minF+1);    //  Maximum period
            
            //  Generate a test signal
            
            const double A440 = 440.0;              //  A440
            double f = A440 * pow(2.0,-9.0/12.0);   //  Middle C (9 semitones below A440)
            
            double q;
            
            double pEst = EstimatePeriod( _x, _xoffset, minP, maxP, q );
            double fEst = 0;
            if ( pEst > 0 )
                fEst = sr/pEst;
            
            double ef = sr/pEst;
            
            double error = 100*12*log(fEst/f)/log(2);
            
             NSString *debug2Text = [NSString stringWithFormat:@"Estimated freq:      %8.3lf\nError (cents):       %8.3lf\nPeriodicity quality: %8.3lf\n", sr/pEst,   error, q];
            
            
           _xoffset = 0;
            
           if(error < 3000 && ef > 50) {
                [weakSelf.delegate recordedFreq:ef debug2Text:debug2Text];
            }
            
        }
    }];
    
    [_audioManager play];

    
    
}







double EstimatePeriod(
                      const double    *x,         //  Sample data.
                      const int       n,          //  Number of samples.  Should be at least 2 x maxP
                      const int       minP,       //  Minimum period of interest
                      const int       maxP,       //  Maximum period
                      double&         q )         //  Quality (1= perfectly periodic)
{
  
    
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    
    
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
    
    NSUInteger b = 0;
    NSUInteger c = 0;
    
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
            
            c++;
        }
        
        b++;
        
    //    NSLog(@"%d %d", b, c);
        
        c=0;
        nac[p] = ac / sqrt( sumSqBeg * sumSqEnd );
    }
    
   // NSLog(@"%d", c);
    
    
    NSTimeInterval tie = [[NSDate date] timeIntervalSince1970];
  //  NSLog(@"total time = %f", tie - ti);
    
    
    
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
    
  //  assert( 2*mid - left - right > 0.0 );
    
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






@end
