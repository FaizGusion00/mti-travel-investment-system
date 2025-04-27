'use client';

import Link from 'next/link';
import Image from 'next/image';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function RegistrationSuccess() {
  const router = useRouter();

  useEffect(() => {
    // Check if user came from verification
    const email = localStorage.getItem('registrationEmail');
    if (email) {
      // Clear the email from localStorage
      localStorage.removeItem('registrationEmail');
    }
  }, []);

  return (
    <div className="min-h-screen flex flex-col justify-center items-center p-4">
      <div className="w-full max-w-md text-center">
        <div className="mb-8">
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
        </div>

        <div className="bg-green-600/20 border border-green-500 rounded-full w-24 h-24 flex items-center justify-center mx-auto mb-8">
          <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>

        <h1 className="text-3xl font-bold text-white mb-4">Registration Successful!</h1>
        
        <p className="text-gray-300 mb-8">
          Your account has been successfully created and verified. You can now log in to the MTI mobile app with your credentials.
        </p>

        <div className="space-y-4">
          <Link
            href="https://play.google.com/store/apps/details?id=com.mti.travel.investment"
            target="_blank"
            className="inline-block w-full py-3 px-4 border border-transparent rounded-md shadow-sm text-white bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200"
          >
            Download Android App
          </Link>
          
          <Link
            href="https://apps.apple.com/app/mti-travel-investment/id123456789"
            target="_blank"
            className="inline-block w-full py-3 px-4 border border-gray-700 rounded-md shadow-sm text-white bg-transparent hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-all duration-200"
          >
            Download iOS App
          </Link>
        </div>

        <div className="mt-8">
          <Link href="/" className="text-blue-400 hover:text-blue-300 text-sm">
            Return to Home Page
          </Link>
        </div>
      </div>
    </div>
  );
} 