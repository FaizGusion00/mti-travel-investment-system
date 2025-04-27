'use client';

import { useState, useEffect, FormEvent } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import Environment from '../utils/environment';

export default function VerifyOTP() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState(Environment.isDevelopment ? Environment.testOtp : '');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [countdown, setCountdown] = useState(60);
  const [canResend, setCanResend] = useState(false);

  useEffect(() => {
    // Retrieve email from localStorage
    const storedEmail = localStorage.getItem('registrationEmail');
    if (!storedEmail) {
      // Redirect to registration if email is not found
      router.push('/register');
      return;
    }
    setEmail(storedEmail);

    // In development mode, pre-fill the OTP with test value
    if (Environment.isDevelopment && Environment.testOtp) {
      setOtp(Environment.testOtp);
    }

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

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Validate OTP format
      if (otp.length !== 6 || !/^\d+$/.test(otp)) {
        throw new Error('Please enter a valid 6-digit OTP');
      }

      // Send OTP verification request to API
      const apiUrl = Environment.apiBaseUrl;
      const response = await fetch(`${apiUrl}/api/v1/verify-otp`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ email, otp }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'OTP verification failed');
      }

      setSuccessMessage('Email verified successfully! You can now login through the mobile app.');
      
      // Clear the stored email after successful verification
      setTimeout(() => {
        localStorage.removeItem('registrationEmail');
        router.push('/registration-success');
      }, 3000);
    } catch (err: any) {
      setError(err.message || 'An error occurred during verification.');
      console.error('Verification error:', err);
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
      const response = await fetch(`${apiUrl}/api/v1/resend-otp`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Failed to resend OTP');
      }

      // In development mode, automatically set the test OTP
      if (Environment.isDevelopment && Environment.testOtp) {
        setOtp(Environment.testOtp);
      }

      setSuccessMessage('A new OTP has been sent to your email');
      setCanResend(false);
      setCountdown(60);
    } catch (err: any) {
      setError(err.message || 'An error occurred when resending OTP.');
      console.error('Resend OTP error:', err);
    } finally {
      setIsLoading(false);
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
          {Environment.isDevelopment && (
            <p className="mt-2 text-amber-500 text-sm">
              Development Mode: Using test OTP {Environment.testOtp}
            </p>
          )}
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-900/50 border border-red-500 rounded-lg text-red-200">
            {error}
          </div>
        )}

        {successMessage && (
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
              onChange={(e) => setOtp(e.target.value.replace(/[^0-9]/g, ''))}
              className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-center text-xl tracking-widest"
              placeholder="000000"
            />
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
    </div>
  );
} 