'use client';

import { useState, FormEvent, useRef, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { useRouter, useSearchParams } from 'next/navigation';
import Turnstile from 'react-turnstile';
import Header from '../components/Header'; 
import Environment from '../utils/environment';

export default function Register() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  // Read reference code from URL parameters
  useEffect(() => {
    const refCode = searchParams.get('ref');
    if (refCode) {
      console.log('Reference code found in URL:', refCode);
      setFormData(prev => ({ ...prev, reference_code: refCode }));
    }
  }, [searchParams]);
  const [formData, setFormData] = useState({
    full_name: '',
    email: '',
    phonenumber: '',
    address: '',
    date_of_birth: '',
    reference_code: '',
    password: '',
    password_confirmation: '',
  });

  // Handle form input changes
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  // Handle image selection
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setSelectedImage(file);
      
      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  // Trigger file input click
  const handleImageClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  // Handle captcha verification
  const handleCaptchaVerify = (token: string) => {
    setCaptchaToken(token);
  };

  // Handle form submission
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Verify captcha first
      if (!captchaToken) {
        setError('Please complete the captcha verification');
        setIsLoading(false);
        return;
      }

      // Validate profile image
      if (!selectedImage) {
        setError('Please upload a profile image');
        setIsLoading(false);
        return;
      }

      // Current date minus 18 years
      const minDate = new Date();
      minDate.setFullYear(minDate.getFullYear() - 18);
      const dob = new Date(formData.date_of_birth);

      // Validate age (must be at least 18)
      if (dob > minDate) {
        setError('You must be at least 18 years old to register.');
        setIsLoading(false);
        return;
      }

      // Check if passwords match
      if (formData.password !== formData.password_confirmation) {
        setError('Passwords do not match.');
        setIsLoading(false);
        return;
      }

      // Create form data for multipart/form-data to include the image
      const formDataObj = new FormData();
      
      // Add all text fields
      Object.entries(formData).forEach(([key, value]) => {
        formDataObj.append(key, value);
      });
      
      // Add captcha token
      formDataObj.append('captcha_token', captchaToken);
      
      // Add profile image with both field names for compatibility
      formDataObj.append('profile_image', selectedImage);
      formDataObj.append('avatar', selectedImage);

      // Get API URL from environment
      const apiUrl = Environment.apiBaseUrl;
      
      console.log('Sending registration to:', `${apiUrl}/api/v1/register`);
      
      const response = await fetch(`${apiUrl}/api/v1/register`, {
        method: 'POST',
        // Don't set Content-Type when using FormData, browser will set it with boundary
        headers: {
          'Accept': 'application/json',
        },
        // Use FormData for multipart uploads
        body: formDataObj,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || data.error || 'Registration failed');
      }

      // If successful, redirect to OTP verification page
      // We'd store the email in localStorage or pass it as query param
      localStorage.setItem('registrationEmail', formData.email);
      
      // In development, store the test OTP for debugging
      if (Environment.isDevelopment && data.data?.otp) {
        localStorage.setItem('registrationOtp', data.data.otp);
        console.log('Development mode: OTP stored for testing:', data.data.otp);
      }
      
      router.push('/verify-otp');
    } catch (err: any) {
      console.error('Registration error:', err);
      
      if (err.name === 'TypeError' && err.message.includes('Failed to fetch')) {
        setError('Unable to connect to the server. Please check your network connection or try again later.');
      } else {
        setError(err.message || 'An error occurred during registration.');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      <Header />
      <div className="min-h-screen flex flex-col justify-center items-center p-4 pt-24">
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
            <h1 className="mt-6 text-3xl font-bold text-white">Create an Account</h1>
            <p className="mt-2 text-gold-400">Join Meta Travel International</p>
          </div>

          {error && (
            <div className="mb-6 p-4 bg-red-900/50 border border-red-500 rounded-lg text-red-200">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Profile Image Upload */}
            <div className="flex flex-col items-center mb-6">
              <label className="block text-sm font-medium text-gray-200 self-start mb-2">
                Profile Image
              </label>
              <div 
                onClick={handleImageClick}
                className="w-32 h-32 rounded-full border-2 border-dashed border-gray-400 flex items-center justify-center overflow-hidden cursor-pointer hover:border-blue-500 transition-colors"
              >
                {imagePreview ? (
                  <img src={imagePreview} alt="Profile Preview" className="w-full h-full object-cover" />
                ) : (
                  <div className="text-center p-4">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-10 w-10 text-gray-400 mb-2 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                    <p className="text-xs text-gray-400">Upload Photo</p>
                  </div>
                )}
              </div>
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageChange}
                className="hidden"
              />
              <p className="mt-2 text-xs text-gray-400">Click to select a profile image (required)</p>
            </div>

            <div>
              <label htmlFor="full_name" className="block text-sm font-medium text-gray-200">
                Full Name
              </label>
              <input
                id="full_name"
                name="full_name"
                type="text"
                required
                value={formData.full_name}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter your full name"
              />
            </div>

            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-200">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={formData.email}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="your.email@example.com"
              />
            </div>

            <div>
              <label htmlFor="phonenumber" className="block text-sm font-medium text-gray-200">
                Phone Number
              </label>
              <input
                id="phonenumber"
                name="phonenumber"
                type="tel"
                required
                value={formData.phonenumber}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter your phone number"
              />
            </div>

            <div>
              <label htmlFor="address" className="block text-sm font-medium text-gray-200">
                Address
              </label>
              <textarea
                id="address"
                name="address"
                value={formData.address}
                onChange={(e) => setFormData(prev => ({ ...prev, address: e.target.value }))}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter your address"
                rows={3}
              />
            </div>

            <div>
              <label htmlFor="date_of_birth" className="block text-sm font-medium text-gray-200">
                Date of Birth (18+ years old only)
              </label>
              <input
                id="date_of_birth"
                name="date_of_birth"
                type="date"
                required
                value={formData.date_of_birth}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
              />
            </div>

            <div>
              <label htmlFor="reference_code" className="block text-sm font-medium text-gray-200">
                Reference Code (Optional)
              </label>
              <input
                id="reference_code"
                name="reference_code"
                type="text"
                value={formData.reference_code}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter reference code (if any)"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-200">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={formData.password}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Enter a secure password"
              />
              <p className="mt-1 text-xs text-gray-400">
                Password must be at least 8 characters with uppercase, lowercase, numbers, and symbols.
              </p>
            </div>

            <div>
              <label htmlFor="password_confirmation" className="block text-sm font-medium text-gray-200">
                Confirm Password
              </label>
              <input
                id="password_confirmation"
                name="password_confirmation"
                type="password"
                required
                value={formData.password_confirmation}
                onChange={handleChange}
                className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                placeholder="Confirm your password"
              />
            </div>

            {/* Captcha Verification */}
            <div className="flex flex-col items-center">
              <label className="block text-sm font-medium text-gray-200 self-start mb-2">
                Verify you are human
              </label>
              <div className={`w-full flex justify-center p-4 bg-gray-900/30 rounded-md ${!captchaToken ? 'border border-gray-700' : 'border border-green-500'}`}>
                <Turnstile
                  sitekey="1x00000000000000000000AA" // Replace with your actual sitekey
                  onVerify={handleCaptchaVerify}
                  theme="dark"
                />
              </div>
              {captchaToken && (
                <div className="mt-2 text-green-500 text-sm flex items-center">
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                  Verification successful
                </div>
              )}
            </div>

            <div>
              <button
                type="submit"
                disabled={isLoading || !captchaToken}
                className={`w-full py-3 px-4 border border-transparent rounded-md shadow-sm text-white ${
                  !captchaToken 
                    ? 'bg-gray-600 cursor-not-allowed' 
                    : 'bg-gradient-to-r from-blue-600 to-indigo-700 hover:from-blue-700 hover:to-indigo-800'
                } focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200 flex justify-center items-center`}
              >
                {isLoading ? (
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                ) : ''}
                {isLoading ? 'Processing...' : !captchaToken ? 'Please Complete Verification' : 'Create Account'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center">
            <p className="text-sm text-gray-400">
              Already have an account?{' '}
              <Link href="http://mti-app-download-link.com" className="text-blue-400 hover:text-blue-300">
                Download the app to login
              </Link>
            </p>
          </div>
        </div>
      </div>
    </>
  );
} 