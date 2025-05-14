'use client';

import { useState, useEffect, FormEvent, useRef } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import Environment from '../utils/environment';

export default function VerifyOTP() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [countdown, setCountdown] = useState(60);
  const [canResend, setCanResend] = useState(false);
  const [isInvalidOtp, setIsInvalidOtp] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const countdownInterval = useRef<NodeJS.Timeout | null>(null);
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [otpAttempts, setOtpAttempts] = useState(0); // Track number of failed attempts

  useEffect(() => {
    // Retrieve email from localStorage
    const storedEmail = localStorage.getItem('registrationEmail');
    if (!storedEmail) {
      // Redirect to registration if email is not found
      router.push('/register');
      return;
    }
    setEmail(storedEmail);

    // Countdown for OTP resend
    let timer: NodeJS.Timeout;
    if (countdown > 0 && !canResend) {
      timer = setTimeout(() => setCountdown(countdown - 1), 1000);
    } else {
      setCanResend(true);
    }

    return () => {
      if (timer) clearTimeout(timer);
    };
  }, [countdown, canResend, router]);

  // Use a strong effect to ensure the success modal stays visible
  useEffect(() => {
    // Only run if the success message is set
    if (successMessage) {
      console.log('Success message set, showing modal: ', successMessage);
      
      // Show the modal
      setShowSuccessModal(true);
      
      // Prevent any navigation via history
      const blockNavigation = () => {
        console.log('Navigation blocked while success modal is active');
        // Push current URL back to history to prevent navigation
        window.history.pushState(null, '', window.location.pathname);
        return false;
      };
      
      // Capture all possible navigation events
      window.addEventListener('popstate', blockNavigation);
      window.addEventListener('beforeunload', blockNavigation);
      
      // Push current state to handle the first back button press
      window.history.pushState(null, '', window.location.pathname);
      
      return () => {
        // Clean up event listeners when component unmounts
        window.removeEventListener('popstate', blockNavigation);
        window.removeEventListener('beforeunload', blockNavigation);
      };
    }
  }, [successMessage]); // Only depend on successMessage

  // Prevent any navigation transitions while the modal is shown
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (showSuccessModal && !isTransitioning) {
        console.log('Before unload prevented - success modal is active');
        e.preventDefault();
        e.returnValue = '';
        return '';
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => {
      window.removeEventListener('beforeunload', handleBeforeUnload);
    };
  }, [showSuccessModal, isTransitioning]);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');
    setIsInvalidOtp(false);

    // Check if we've reached max attempts (3)
    if (otpAttempts >= 3) {
      setError('Maximum verification attempts reached. Requesting a new code...');
      setIsInvalidOtp(true);
      setIsLoading(false);
      
      // Auto-resend OTP if we can
      if (canResend) {
        console.log('Auto-requesting new OTP after max attempts reached');
        // Add slight delay before auto-resending
        setTimeout(() => {
          handleResendOTP();
        }, 1500);
      } else {
        setError(`Maximum attempts reached. Please wait ${countdown} seconds to request a new code.`);
      }
      return;
    }

    try {
      // Validate OTP format
      if (otp.length !== 6 || !/^\d+$/.test(otp)) {
        throw new Error('Please enter a valid 6-digit OTP');
      }

      // Add this to show what OTP we're trying to verify
      console.log('Attempting to verify OTP:', otp, 'for email:', email);

      // Send OTP verification request to API
      const apiUrl = Environment.apiBaseUrl;
      const verifyEndpoint = '/api/v1/verify-otp'; // Correct path based on Laravel routes
      console.log('Verifying OTP with:', `${apiUrl}${verifyEndpoint}`);
      console.log('Request data:', { email, otp });
      
      // Improved fetch with better error handling
      try {
        const response = await fetch(`${apiUrl}${verifyEndpoint}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify({ email, otp }),
        });
        
        // Check if we got a response at all
        if (!response) {
          throw new Error('No response received from server');
        }
        
        // Try to parse the JSON response (may fail if server returns invalid JSON)
        let data;
        try {
          data = await response.json();
          console.log('Response data:', data);
          
          // Check if we received an OTP in development mode
          if (Environment.isDevelopment && data.data?.otp) {
            console.log('Development mode OTP received:', data.data.otp);
            // Store OTP for verification
            localStorage.setItem('developmentOtp', data.data.otp);
            alert(`Development mode: Your OTP is ${data.data.otp}`);
          }
          
          // Log additional debug info if available
          if (data.debug_info) {
            console.log('Debug info:', data.debug_info);
          }
        } catch (jsonError) {
          console.error('Failed to parse response JSON:', jsonError);
          throw new Error('Invalid response from server');
        }
        
        // If we got a success response but user_existed flag is true
        if (response.ok && data.user_existed) {
          console.log('User already exists and was verified');
          setSuccessMessage('Account already verified! You can now login through the mobile app.');
          
          // Clear any stored data
          localStorage.removeItem('registrationEmail');
          localStorage.removeItem('registrationBackupData');
          return;
        }
        
        // Handle API error responses
        if (!response.ok) {
          // Check for PHP "Trying to access array offset on null" error
          if (data && (data.message?.includes('array offset on null') || data.error?.includes('array offset on null'))) {
            console.error('Server error: Trying to access array offset on null');
            setIsInvalidOtp(true);
            throw new Error('There was a problem processing your OTP. Please request a new one.');
          }
          
          // Check if the server needs backup registration data
          if (data && data.needs_backup_data) {
            console.log('Server needs backup registration data. Attempting to send backup data...');
            
            // Try to get backup data from localStorage
            const backupDataStr = localStorage.getItem('registrationBackupData');
            if (!backupDataStr) {
              console.error('No backup registration data found in localStorage');
              setIsInvalidOtp(false);
              throw new Error('Your verification code is valid, but we could not find your registration data. Please restart registration.');
            }
            
            try {
              const backupData = JSON.parse(backupDataStr);
              console.log('Found backup data:', backupData);
              
              // Send backup data to the server
              const backupResponse = await fetch(`${apiUrl}/api/v1/backup-registration`, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: JSON.stringify({
                  ...backupData,
                  otp: otp  // Include the OTP for verification
                }),
              });
              
              const backupResult = await backupResponse.json();
              console.log('Backup registration response:', backupResult);
              
              if (backupResponse.ok) {
                // Success with backup data
                setSuccessMessage('Account created successfully using backup data! You can now login through the mobile app.');
                
                // Clear backup data and email
                localStorage.removeItem('registrationBackupData');
                localStorage.removeItem('registrationEmail');
                
                return; // Exit early
              } else {
                throw new Error(backupResult.message || 'Failed to create account with backup data');
              }
            } catch (backupError: any) {
              console.error('Error sending backup data:', backupError);
              throw new Error('Failed to recover your registration data. Please restart registration.');
            }
          }
          
          // Check if this is an invalid/expired OTP error
          const errorMessage = data.message || data.error || 'OTP verification failed';
          const isExpiredOrInvalidOtp = errorMessage.toLowerCase().includes('invalid') || 
                                      errorMessage.toLowerCase().includes('expired') || 
                                      errorMessage.toLowerCase().includes('otp');
          
          if (isExpiredOrInvalidOtp) {
            setIsInvalidOtp(true);
            // Increment failed attempts count
            setOtpAttempts(prev => prev + 1);
            throw new Error(`${errorMessage}. Attempt ${otpAttempts + 1} of 3.`);
          }
          
          throw new Error(errorMessage);
        }
        
        // Success!
        setSuccessMessage('Email verified successfully! You can now login through the mobile app.');
        
        // Clear the stored email after successful verification
        localStorage.removeItem('registrationEmail');
        localStorage.removeItem('registrationBackupData');
        
      } catch (fetchError: any) {
        console.error('Fetch error:', fetchError);
        
        // Check if the error message suggests invalid/expired OTP
        if (fetchError.message && (
            fetchError.message.toLowerCase().includes('invalid') || 
            fetchError.message.toLowerCase().includes('expired') || 
            fetchError.message.toLowerCase().includes('otp'))) {
          setIsInvalidOtp(true);
          setOtpAttempts(prev => prev + 1);
        }
        
        // Try alternative API URL if fetch fails
        if (fetchError.message === 'Failed to fetch') {
          try {
            // Try alternative URL formats
            const fallbackEndpoints = [
              '/verify-otp',              // Try direct endpoint
              '/api/verify-otp',          // Try API prefix
              '/api/v1/verify-otp'        // Try with API version
            ];
            
            let successfulResponse = false;
            
            for (const endpoint of fallbackEndpoints) {
              try {
                console.log(`Trying fallback endpoint: ${apiUrl}${endpoint}`);
                
                const retryResponse = await fetch(`${apiUrl}${endpoint}`, {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                  },
                  credentials: 'same-origin',
                  body: JSON.stringify({ email, otp }),
                });
                
                let retryData;
                try {
                  retryData = await retryResponse.json();
                  console.log(`Response from ${endpoint}:`, retryData);
                } catch (jsonError) {
                  console.error(`Failed to parse JSON from ${endpoint}:`, jsonError);
                  continue; // Skip to next endpoint
                }
                
                // Check for PHP "Trying to access array offset on null" error
                if (retryData && (retryData.message?.includes('array offset on null') || retryData.error?.includes('array offset on null'))) {
                  console.error('Server error: Trying to access array offset on null');
                  setIsInvalidOtp(true);
                  throw new Error('There was a problem processing your OTP. Please request a new one.');
                }
                
                if (retryResponse.ok) {
                  // Success on retry!
                  setSuccessMessage('Email verified successfully! You can now login through the mobile app.');
                  
                  // Clear the stored data
                  localStorage.removeItem('registrationEmail');
                  localStorage.removeItem('registrationBackupData');
                  
                  successfulResponse = true;
                  break;
                }
              } catch (endpointError) {
                console.error(`Error with endpoint ${endpoint}:`, endpointError);
                // Continue to next endpoint
              }
            }
            
            if (!successfulResponse) {
              throw new Error('Could not connect to the server. Please check if the backend server is running at http://localhost:8000');
            }
          } catch (retryError) {
            console.error('All retries failed:', retryError);
            throw new Error('Failed to connect to the verification server. Please contact support or try again later.');
          }
        } else {
          // Rethrow original error if it's not a connectivity issue
          throw fetchError;
        }
      }
    } catch (err: any) {
      console.error('Verification error:', err);
      
      // Check if the error message suggests invalid/expired OTP
      if (err.message && (
          err.message.toLowerCase().includes('invalid') || 
          err.message.toLowerCase().includes('expired') || 
          err.message.toLowerCase().includes('otp'))) {
        setIsInvalidOtp(true);
        setOtpAttempts(prev => prev + 1);
      }
      
      setError(err.message || 'An error occurred during verification.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendOTP = async () => {
    setIsLoading(true);
    setError('');
    setSuccessMessage('');

    try {
      // Send request to resend OTP
      const apiUrl = Environment.apiBaseUrl;
      const resendEndpoint = '/api/v1/resend-otp'; // Correct path based on Laravel routes
      console.log('Resending OTP to:', `${apiUrl}${resendEndpoint}`);
      console.log('Request data:', { email });
      
      try {
        const response = await fetch(`${apiUrl}${resendEndpoint}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
          credentials: 'same-origin',
          body: JSON.stringify({ email }),
        });
        
        // Check if we got a response
        if (!response) {
          throw new Error('No response received from server');
        }
        
        let data;
        try {
          data = await response.json();
          console.log('Resend OTP response:', data);
          
          // Check if we received an OTP in development mode
          if (Environment.isDevelopment && data.data?.otp) {
            console.log('Development mode OTP received:', data.data.otp);
            // Store OTP for verification
            localStorage.setItem('developmentOtp', data.data.otp);
            alert(`Development mode: Your new OTP is ${data.data.otp}`);
          }
        } catch (jsonError) {
          console.error('Failed to parse response JSON:', jsonError);
          throw new Error('Invalid response from server');
        }

        if (!response.ok) {
          throw new Error(data.message || data.error || 'Failed to resend OTP');
        }

        // Clear previous OTP input since it's now invalid
        setOtp('');
        // Reset invalid OTP state
        setIsInvalidOtp(false);
        // Reset attempt counter when requesting a new OTP
        setOtpAttempts(0);
        setSuccessMessage('A new verification code has been sent to your email. Previous codes are no longer valid.');
        setCanResend(false);
        setCountdown(60);
      } catch (fetchError: any) {
        console.error('Fetch error:', fetchError);
        
        // Try alternative API URL if fetch fails
        if (fetchError.message === 'Failed to fetch') {
          try {
            // Try alternative URL formats
            const fallbackEndpoints = [
              '/resend-otp',              // Try direct endpoint
              '/api/resend-otp',          // Try API prefix
              '/api/v1/resend-otp'        // Try with API version
            ];
            
            let successfulResponse = false;
            
            for (const endpoint of fallbackEndpoints) {
              try {
                console.log(`Trying fallback endpoint: ${apiUrl}${endpoint}`);
                
                const retryResponse = await fetch(`${apiUrl}${endpoint}`, {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest',
                  },
                  credentials: 'same-origin',
                  body: JSON.stringify({ email }),
                });
                
                const retryData = await retryResponse.json();
                console.log(`Response from ${endpoint}:`, retryData);
                
                if (retryResponse.ok) {
                  // Clear previous OTP input since it's now invalid
                  setOtp('');
                  // Reset invalid OTP state
                  setIsInvalidOtp(false);
                  // Reset attempt counter when requesting a new OTP
                  setOtpAttempts(0);
                  setSuccessMessage('A new verification code has been sent to your email. Previous codes are no longer valid.');
                  setCanResend(false);
                  setCountdown(60);
                  
                  successfulResponse = true;
                  break;
                }
              } catch (endpointError) {
                console.error(`Error with endpoint ${endpoint}:`, endpointError);
                // Continue to next endpoint
              }
            }
            
            if (!successfulResponse) {
              throw new Error('Could not connect to the server. Please check if the backend server is running at http://localhost:8000');
            }
          } catch (retryError) {
            console.error('All retries failed:', retryError);
            throw new Error('Failed to connect to the server to resend OTP. Please try again later or contact support.');
          }
        } else {
          throw fetchError;
        }
      }
    } catch (err: any) {
      console.error('Resend OTP error:', err);
      setError(err.message || 'An error occurred when resending OTP.');
    } finally {
      setIsLoading(false);
    }
  };

  // Handler for OK button with fixed navigation
  const handleSuccessOk = () => {
    try {
      console.log('Success modal OK button clicked');
      
      // Mark that we're intentionally navigating away
      setIsTransitioning(true);
      
      // Clear any localStorage data
      localStorage.removeItem('registrationEmail');
      localStorage.removeItem('registrationBackupData');
      
      // First update UI to indicate navigation is happening
      setSuccessMessage(successMessage + ' Redirecting...');
      
      // Use a more direct approach to navigation
      window.location.href = '/';
      
    } catch (error) {
      console.error('Navigation error:', error);
      // Force navigation as fallback
      window.location.replace('/');
    }
  };

  return (
    <div className="min-h-screen flex flex-col justify-center items-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-10">
          <Link href="/">
            <div className="inline-block">
              <Image 
                src="/logo.png" 
                alt="MTI Logo" 
                width={100} 
                height={100} 
                className="mx-auto"
              />
            </div>
          </Link>
          <h1 className="mt-6 text-3xl font-bold text-white">Verify Your Email</h1>
          <p className="mt-2 text-gold-400">Enter the 6-digit code sent to your email</p>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-900/50 border border-red-500 rounded-lg text-red-200">
            <p>{error}</p>
            {isInvalidOtp && canResend && (
              <div className="mt-3 flex items-center">
                <button 
                  onClick={handleResendOTP}
                  disabled={isLoading}
                  className="px-4 py-2 bg-amber-700 text-white rounded-md hover:bg-amber-600 focus:outline-none transition-colors"
                >
                  Resend New OTP
                </button>
                <span className="ml-2 text-sm text-amber-300">Click to get a fresh code</span>
              </div>
            )}
            {isInvalidOtp && !canResend && (
              <p className="mt-2 text-amber-300">
                Please wait {countdown} seconds to request a new code.
              </p>
            )}
          </div>
        )}

        {successMessage && !showSuccessModal && (
          <div className="mb-6 p-4 bg-green-900/50 border border-green-500 rounded-lg text-green-200">
            {successMessage}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-200">
              Email
            </label>
            <input
              id="email"
              type="email"
              readOnly
              value={email}
              className="mt-1 block w-full px-3 py-2 bg-gray-800 border border-gray-700 rounded-md shadow-sm text-gray-400"
            />
          </div>

          <div>
            <label htmlFor="otp" className="block text-sm font-medium text-gray-200">
              Verification Code
            </label>
            <input
              id="otp"
              type="text"
              required
              maxLength={6}
              value={otp}
              onChange={(e) => {
                // Only allow numbers and keep it to 6 digits max
                const newValue = e.target.value.replace(/[^0-9]/g, '').slice(0, 6);
                setOtp(newValue);
                
                // Clear any previous error when user starts editing
                if (isInvalidOtp) {
                  setIsInvalidOtp(false);
                }
                if (error) {
                  setError('');
                }
              }}
              className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-center text-xl tracking-widest"
              placeholder="000000"
              autoComplete="off"
            />
            <p className="mt-1 text-xs text-gray-400 text-center">Enter the 6-digit code we sent to your email</p>
            {otpAttempts > 0 && (
              <p className="mt-1 text-xs text-amber-400 text-center">
                You have {3 - otpAttempts} attempt{3 - otpAttempts !== 1 ? 's' : ''} remaining
              </p>
            )}
          </div>

          <div>
            <button
              type="submit"
              disabled={isLoading || otp.length !== 6}
              className="w-full py-3 px-4 border border-transparent rounded-md shadow-sm text-white bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 flex justify-center items-center disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
              ) : ''}
              {isLoading ? 'Verifying...' : 'Verify Email'}
            </button>
          </div>
        </form>

        <div className="mt-6 text-center">
          <p className="text-sm text-gray-400">
            Didn't receive the code?{' '}
            {canResend ? (
              <button 
                onClick={handleResendOTP} 
                disabled={isLoading}
                className="text-blue-400 hover:text-blue-300 focus:outline-none"
              >
                Resend OTP
              </button>
            ) : (
              <span className="text-gray-500">
                Resend in {countdown} seconds
              </span>
            )}
          </p>
        </div>

        <div className="mt-10 text-center">
          <Link href="/register" className="text-sm text-gray-400 hover:text-gray-300">
            Back to Registration
          </Link>
        </div>
      </div>

      {/* Success Modal - Fixed version that won't auto-close */}
      {showSuccessModal && (
        <div className="fixed inset-0 z-[9999] bg-black bg-opacity-80 flex items-center justify-center"
             style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0 }}
             onClick={(e) => e.stopPropagation()}>
          <div className="bg-gray-900 rounded-xl border-2 border-yellow-400 shadow-[0_0_30px_rgba(255,215,0,0.3)] p-8 max-w-md w-full animate-fade-in"
               style={{ position: 'relative', zIndex: 10000 }}
               onClick={(e) => e.stopPropagation()}>
            
            {/* Gold Success Icon */}
            <div className="flex justify-center mb-6">
              <div className="rounded-full bg-gradient-to-br from-yellow-400 to-amber-600 p-3 shadow-lg">
                <svg className="w-16 h-16 text-gray-900" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
            </div>
            
            <h2 className="text-2xl font-bold text-center text-yellow-400 mb-4">Success!</h2>
            
            <div className="border-t border-b border-gray-700 py-4 my-4">
              <p className="text-white text-center text-lg">{successMessage}</p>
            </div>
            
            <div className="flex justify-center mt-6">
              <button
                onClick={handleSuccessOk}
                className="transition-all duration-300 px-10 py-3 bg-gradient-to-r from-yellow-500 to-amber-600 rounded-lg text-gray-900 font-bold text-lg shadow-[0_0_15px_rgba(255,215,0,0.5)] hover:shadow-[0_0_20px_rgba(255,215,0,0.7)] focus:outline-none"
              >
                Okay, Got It!
              </button>
            </div>
            
            <p className="mt-6 text-center text-gray-400 text-sm">
              Click the button above to continue
            </p>
          </div>
        </div>
      )}
    </div>
  );
} 