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

  // Show modal when successMessage is set
  useEffect(() => {
    if (successMessage) {
      setShowSuccessModal(true);
    }
  }, [successMessage]);

  // Prevent any navigation transitions while the modal is shown
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (showSuccessModal && !isTransitioning) {
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
            throw new Error(`${errorMessage}`);
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
    // Mark that we're intentionally transitioning to prevent beforeunload from blocking
    setIsTransitioning(true);
    // Close the modal first
    setShowSuccessModal(false);
    // Delay navigation slightly to ensure modal is closed properly
    setTimeout(() => {
      // Navigate to homepage
      window.location.href = '/';
    }, 100);
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

      {/* Success Modal - Will stay open until user clicks OK */}
      {showSuccessModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70">
          <div className="bg-gray-900 rounded-2xl shadow-2xl p-8 max-w-sm w-full flex flex-col items-center relative animate-fade-in">
            {/* Luxury Gold Checkmark Animation */}
            <div className="mb-6">
              <svg width="90" height="90" viewBox="0 0 90 90" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="45" cy="45" r="42" stroke="#FFD700" strokeWidth="6" fill="none" filter="url(#glow)" />
                <path d="M28 48L41 61L63 36" stroke="#FFD700" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" fill="none">
                  <animate attributeName="stroke-dasharray" from="0,100" to="40,100" dur="0.7s" fill="freeze" />
                </path>
                <defs>
                  <filter id="glow" x="-10" y="-10" width="110" height="110" filterUnits="userSpaceOnUse">
                    <feGaussianBlur stdDeviation="4" result="coloredBlur" />
                    <feMerge>
                      <feMergeNode in="coloredBlur" />
                      <feMergeNode in="SourceGraphic" />
                    </feMerge>
                  </filter>
                </defs>
              </svg>
            </div>
            <h2 className="text-2xl font-bold text-gold-400 mb-2">Success!</h2>
            <p className="text-lg text-gray-200 mb-4 text-center">{successMessage}</p>
            <button
              onClick={handleSuccessOk}
              className="mt-2 px-6 py-4 rounded-lg bg-gradient-to-r from-yellow-400 to-yellow-600 text-gray-900 font-semibold shadow-lg hover:from-yellow-500 hover:to-yellow-700 transition-all text-lg"
            >
              OK
            </button>
            <p className="mt-4 text-sm text-gray-400">Click OK to continue to the home page</p>
          </div>
        </div>
      )}
    </div>
  );
} 