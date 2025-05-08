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
  const [currentStep, setCurrentStep] = useState(0);
  const [fieldsWithErrors, setFieldsWithErrors] = useState<{[key: string]: string}>({});
  const [passwordStrength, setPasswordStrength] = useState({
    score: 0,
    hasMinLength: false,
    hasUppercase: false,
    hasLowercase: false,
    hasNumber: false,
    hasSpecialChar: false
  });
  
  // Read reference code from URL parameters
  useEffect(() => {
    const affiliateCode = searchParams.get('affiliate_code');
    if (affiliateCode) {
      console.log('Affiliate code found in URL:', affiliateCode);
      setFormData(prev => ({ ...prev, reference_code: affiliateCode }));
    } else {
      // Set default reference code to ADMIN01 if no code is provided
      console.log('No affiliate code found, using default: ADMIN01');
      setFormData(prev => ({ ...prev, reference_code: 'ADMIN01' }));
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

  // Field validation functions
  const validateField = (name: string, value: string) => {
    let error = '';
    
    switch(name) {
      case 'email':
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
          error = 'Please enter a valid email address';
        }
        break;
      case 'phonenumber':
        const phoneRegex = /^\+?[0-9]{8,15}$/;
        if (!phoneRegex.test(value.replace(/[\s-]/g, ''))) {
          error = 'Please enter a valid phone number';
        }
        break;
      case 'password':
        // Check password strength and set appropriate error
        if (value.length > 0 && passwordStrength.score < 3) {
          error = 'Password is too weak';
        }
        break;
      case 'password_confirmation':
        if (value !== formData.password) {
          error = 'Passwords do not match';
        }
        break;
    }
    
    // Update fields with errors
    if (error) {
      setFieldsWithErrors(prev => ({ ...prev, [name]: error }));
    } else {
      setFieldsWithErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[name];
        return newErrors;
      });
    }
  };

  // Check password strength
  const checkPasswordStrength = (password: string) => {
    const hasMinLength = password.length >= 8;
    const hasUppercase = /[A-Z]/.test(password);
    const hasLowercase = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSpecialChar = /[^A-Za-z0-9]/.test(password);
    
    let score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;
    
    setPasswordStrength({
      score,
      hasMinLength,
      hasUppercase,
      hasLowercase,
      hasNumber,
      hasSpecialChar
    });
  };

  // Format phone number with spaces
  const formatPhoneNumber = (phone: string) => {
    // Remove all non-digits
    const digits = phone.replace(/\D/g, '');
    // Insert a space after every 3 digits
    return digits.replace(/(.{3})/g, '$1 ').trim();
  };

  // Handle form input changes with validation
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    
    // Special handling for phone formatting
    if (name === 'phonenumber') {
      // Only update if new value doesn't make the field invalid
      const formatted = formatPhoneNumber(value);
      setFormData(prev => ({ ...prev, [name]: formatted }));
    } else if (name === 'password') {
      // Check password strength
      checkPasswordStrength(value);
      setFormData(prev => ({ ...prev, [name]: value }));
      
      // Also validate password confirmation if it exists
      if (formData.password_confirmation) {
        validateField('password_confirmation', formData.password_confirmation);
      }
    } else {
      // Normal field update
      setFormData(prev => ({ ...prev, [name]: value }));
    }
    
    // Validate the field
    validateField(name, name === 'phonenumber' ? formatPhoneNumber(value) : value);
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

  // Steps configuration
  const formSteps = [
    { name: 'Personal Details', fields: ['full_name', 'email', 'phonenumber'] },
    { name: 'Additional Info', fields: ['address', 'date_of_birth', 'reference_code'] },
    { name: 'Security', fields: ['password', 'password_confirmation'] },
    { name: 'Verification', fields: ['profile_image', 'captcha'] }
  ];

  // Function to check if current step is valid to proceed
  const isCurrentStepValid = () => {
    const currentStepFields = formSteps[currentStep].fields;
    
    // Check if any field in the current step has validation errors
    const hasStepErrors = currentStepFields.some(field => 
      field in fieldsWithErrors && !!fieldsWithErrors[field]
    );
    
    if (hasStepErrors) return false;
    
    // Check if all required fields in the current step have values
    const hasEmptyRequiredFields = currentStepFields.some(field => {
      // Skip reference_code as it's optional and captcha (handled separately)
      if (field === 'reference_code' || field === 'captcha' || field === 'profile_image') return false;
      
      return !formData[field as keyof typeof formData];
    });
    
    return !hasEmptyRequiredFields;
  };

  // Handle next step navigation
  const handleNextStep = () => {
    // Validate current step fields
    const currentStepFields = formSteps[currentStep].fields;
    
    // Trigger validation for all fields in current step
    currentStepFields.forEach(field => {
      if (field !== 'captcha' && field !== 'profile_image') {
        validateField(field, formData[field as keyof typeof formData] as string);
      }
    });
    
    // Only proceed if the current step is valid
    if (isCurrentStepValid()) {
      setCurrentStep(prev => Math.min(prev + 1, formSteps.length - 1));
    }
  };

  // Handle previous step navigation
  const handlePrevStep = () => {
    setCurrentStep(prev => Math.max(prev - 1, 0));
  };

  // Handle form submission
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    // Final validation of all fields
    Object.keys(formData).forEach(key => {
      validateField(key, formData[key as keyof typeof formData] as string);
    });
    
    // Check if there are any errors
    if (Object.keys(fieldsWithErrors).length > 0) {
      setError('Please fix all errors before submitting the form.');
      return;
    }
    
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
      
      console.log('Sending registration to:', `${apiUrl}/register`);
      
      const response = await fetch(`${apiUrl}/register`, {
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

  // Helper function to render step indicators
  const renderStepIndicator = () => {
    return (
      <div className="flex justify-center mb-8">
        {formSteps.map((step, index) => (
          <div key={index} className="flex items-center">
            <div 
              className={`flex items-center justify-center w-10 h-10 rounded-full
                ${currentStep === index 
                  ? 'bg-gradient-to-r from-purple-600 to-blue-600 border-2 border-gold-400' 
                  : index < currentStep 
                    ? 'bg-green-600' 
                    : 'bg-gray-800 border border-gray-600'}
                transition-all duration-300`}
            >
              {index < currentStep ? (
                <svg className="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
              ) : (
                <span className="text-white font-semibold">{index + 1}</span>
              )}
            </div>
            {index < formSteps.length - 1 && (
              <div 
                className={`w-12 h-1 ${index < currentStep ? 'bg-green-600' : 'bg-gray-700'} transition-all duration-300`}
              />
            )}
          </div>
        ))}
      </div>
    );
  };

  // Helper function to render step title
  const renderStepTitle = () => {
    return (
      <div className="mb-6">
        <h2 className="text-xl font-semibold text-white">
          {formSteps[currentStep].name}
        </h2>
        <div className="w-20 h-1 bg-gradient-to-r from-purple-600 to-indigo-500 mt-2"></div>
      </div>
    );
  };

  return (
    <>
      <Header />
      <div className="min-h-screen flex flex-col justify-center items-center p-4 pt-24 bg-gray-900">
        <div className="w-full max-w-md bg-gray-900/60 p-8 rounded-xl shadow-2xl border border-gray-800 backdrop-blur-sm">
          <div className="text-center mb-6">
            <Link href="/">
              <div className="inline-block">
                <Image 
                  src="/logo.png" 
                  alt="MTI Logo" 
                  width={80} 
                  height={80} 
                  className="mx-auto"
                />
              </div>
            </Link>
            <h1 className="mt-4 text-2xl font-bold text-white">Create an Account</h1>
            <p className="mt-1 text-amber-400">Join Meta Travel International</p>
          </div>
          
          {renderStepIndicator()}

          {error && (
            <div className="mb-6 p-4 bg-red-900/50 border border-red-500 rounded-lg text-red-200">
              {error}
            </div>
          )}
          
          {renderStepTitle()}

          <form onSubmit={handleSubmit} className="space-y-6 relative">
            {/* Step 1: Personal Details */}
            <div className={`space-y-6 transition-opacity duration-300 ${currentStep === 0 ? 'opacity-100' : 'absolute opacity-0 -z-10 top-0 left-0 right-0'}`}>
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
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.full_name ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="Enter your full name"
                />
                {fieldsWithErrors.full_name && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.full_name}</p>
                )}
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
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.email ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="your.email@example.com"
                />
                {fieldsWithErrors.email && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.email}</p>
                )}
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
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.phonenumber ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="Enter your phone number"
                />
                {fieldsWithErrors.phonenumber && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.phonenumber}</p>
                )}
              </div>
            </div>

            {/* Step 2: Additional Info */}
            <div className={`space-y-6 transition-opacity duration-300 ${currentStep === 1 ? 'opacity-100' : 'absolute opacity-0 -z-10 top-0 left-0 right-0'}`}>
              <div>
                <label htmlFor="address" className="block text-sm font-medium text-gray-200">
                  Address
                </label>
                <textarea
                  id="address"
                  name="address"
                  value={formData.address}
                  onChange={(e) => {
                    setFormData(prev => ({ ...prev, address: e.target.value }));
                    validateField('address', e.target.value);
                  }}
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.address ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="Enter your address"
                  rows={3}
                />
                {fieldsWithErrors.address && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.address}</p>
                )}
              </div>

              <div>
                <label htmlFor="date_of_birth" className="block text-sm font-medium text-gray-200">
                  Date of Birth <span className="text-amber-400">(18+ years old only)</span>
                </label>
                <input
                  id="date_of_birth"
                  name="date_of_birth"
                  type="date"
                  required
                  value={formData.date_of_birth}
                  onChange={handleChange}
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.date_of_birth ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                />
                {fieldsWithErrors.date_of_birth && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.date_of_birth}</p>
                )}
              </div>

              <div>
                <label htmlFor="reference_code" className="block text-sm font-medium text-gray-200">
                  Reference Code <span className="text-xs text-gray-400">(Auto-filled from link)</span>
                </label>
                <input
                  id="reference_code"
                  name="reference_code"
                  type="text"
                  value={formData.reference_code}
                  onChange={handleChange}
                  className="mt-1 block w-full px-3 py-2 bg-gray-900/70 border border-gray-700 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-colors"
                  placeholder="Enter reference code (if any)"
                />
              </div>
            </div>

            {/* Step 3: Security */}
            <div className={`space-y-6 transition-opacity duration-300 ${currentStep === 2 ? 'opacity-100' : 'absolute opacity-0 -z-10 top-0 left-0 right-0'}`}>
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
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.password ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="Enter a secure password"
                />
                
                {/* Password strength indicator */}
                {formData.password && (
                  <div className="mt-3">
                    <div className="flex justify-between mb-1">
                      <span className="text-xs text-gray-400">Password strength:</span>
                      <span className="text-xs">
                        {passwordStrength.score < 2 && <span className="text-red-400">Weak</span>}
                        {passwordStrength.score >= 2 && passwordStrength.score < 4 && <span className="text-amber-400">Medium</span>}
                        {passwordStrength.score >= 4 && <span className="text-green-400">Strong</span>}
                      </span>
                    </div>
                    <div className="w-full h-1.5 bg-gray-700 rounded-full overflow-hidden">
                      <div 
                        className={`h-full ${passwordStrength.score < 2 ? 'bg-red-500' : passwordStrength.score < 4 ? 'bg-amber-500' : 'bg-green-500'}`}
                        style={{ width: `${(passwordStrength.score / 5) * 100}%` }}
                      ></div>
                    </div>
                    
                    <div className="grid grid-cols-2 gap-2 mt-2">
                      <div className={`text-xs flex items-center ${passwordStrength.hasMinLength ? 'text-green-400' : 'text-gray-500'}`}>
                        <span className="mr-1">{passwordStrength.hasMinLength ? '✓' : '○'}</span> 8+ characters
                      </div>
                      <div className={`text-xs flex items-center ${passwordStrength.hasUppercase ? 'text-green-400' : 'text-gray-500'}`}>
                        <span className="mr-1">{passwordStrength.hasUppercase ? '✓' : '○'}</span> Uppercase
                      </div>
                      <div className={`text-xs flex items-center ${passwordStrength.hasLowercase ? 'text-green-400' : 'text-gray-500'}`}>
                        <span className="mr-1">{passwordStrength.hasLowercase ? '✓' : '○'}</span> Lowercase
                      </div>
                      <div className={`text-xs flex items-center ${passwordStrength.hasNumber ? 'text-green-400' : 'text-gray-500'}`}>
                        <span className="mr-1">{passwordStrength.hasNumber ? '✓' : '○'}</span> Number
                      </div>
                      <div className={`text-xs flex items-center ${passwordStrength.hasSpecialChar ? 'text-green-400' : 'text-gray-500'}`}>
                        <span className="mr-1">{passwordStrength.hasSpecialChar ? '✓' : '○'}</span> Special character
                      </div>
                    </div>
                  </div>
                )}
                
                {fieldsWithErrors.password && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.password}</p>
                )}
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
                  className={`mt-1 block w-full px-3 py-2 bg-gray-900/70 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 transition-colors ${fieldsWithErrors.password_confirmation ? 'border-red-500' : 'border-gray-700 focus:border-purple-500'}`}
                  placeholder="Confirm your password"
                />
                {fieldsWithErrors.password_confirmation && (
                  <p className="mt-1 text-xs text-red-400">{fieldsWithErrors.password_confirmation}</p>
                )}
              </div>
            </div>

            {/* Step 4: Verification */}
            <div className={`space-y-6 transition-opacity duration-300 ${currentStep === 3 ? 'opacity-100' : 'absolute opacity-0 -z-10 top-0 left-0 right-0'}`}>
              {/* Profile Image Upload */}
              <div className="flex flex-col items-center">
                <label className="block text-sm font-medium text-gray-200 self-start mb-2">
                  Profile Image
                </label>
                <div 
                  onClick={handleImageClick}
                  className={`w-32 h-32 rounded-full border-2 flex items-center justify-center overflow-hidden cursor-pointer transition-all duration-300 ${selectedImage ? 'border-purple-500 shadow-lg shadow-purple-900/30' : 'border-dashed border-gray-400 hover:border-purple-400'}`}
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

              {/* Captcha Verification */}
              <div className="flex flex-col items-center">
                <label className="block text-sm font-medium text-gray-200 self-start mb-2">
                  Verify you are human
                </label>
                <div className={`w-full flex justify-center p-4 bg-gray-900/30 rounded-md ${!captchaToken ? 'border border-gray-700' : 'border border-green-500'}`}>
                  <Turnstile
                    sitekey={Environment.turnstileSiteKey}
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
            </div>
            
            {/* Form Navigation */}
            <div className="mt-8 pt-4 border-t border-gray-800 flex justify-between">
              {currentStep > 0 && (
                <button
                  type="button"
                  onClick={handlePrevStep}
                  className="px-4 py-2 bg-gray-800 text-white rounded-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors"
                >
                  Previous
                </button>
              )}
              
              {currentStep < formSteps.length - 1 ? (
                <button
                  type="button"
                  onClick={handleNextStep}
                  disabled={!isCurrentStepValid()}
                  className={`ml-auto px-4 py-2 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors ${
                    isCurrentStepValid()
                      ? 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 focus:ring-purple-500'
                      : 'bg-gray-700 cursor-not-allowed'
                  }`}
                >
                  Next
                </button>
              ) : (
                <button
                  type="submit"
                  disabled={isLoading || !captchaToken || !selectedImage}
                  className={`ml-auto px-6 py-2.5 rounded-md shadow-sm text-white font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 transition-all duration-200 ${
                    (!captchaToken || !selectedImage) 
                      ? 'bg-gray-700 cursor-not-allowed' 
                      : 'bg-gradient-to-r from-purple-600 to-indigo-600 hover:from-purple-700 hover:to-indigo-700 shadow-lg hover:shadow-purple-900/20 focus:ring-purple-500'
                  }`}
                >
                  {isLoading && (
                    <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  )}
                  {isLoading ? 'Processing...' : 'Create Account'}
                </button>
              )}
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