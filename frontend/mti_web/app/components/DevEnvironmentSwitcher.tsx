'use client';

import { useState, useEffect } from 'react';
import Environment from '../utils/environment';

/**
 * Development Environment Switcher Component
 * 
 * This component allows developers to easily switch between local and cloud environments
 * during development. It only appears in development mode and is hidden in production.
 */
const DevEnvironmentSwitcher = () => {
  // Initialize state with current environment setting
  const [useCloudApi, setUseCloudApi] = useState(Environment.useCloudApi);
  
  // Update the environment when toggle changes
  const handleToggleChange = () => {
    const newValue = !useCloudApi;
    setUseCloudApi(newValue);
    Environment.useCloudApi = newValue;
    
    // Store preference in localStorage for persistence between refreshes
    localStorage.setItem('mti_use_cloud_api', newValue.toString());
    
    // Reload the page to apply changes
    window.location.reload();
  };
  
  // Load saved preference on component mount
  useEffect(() => {
    const savedPreference = localStorage.getItem('mti_use_cloud_api');
    if (savedPreference !== null) {
      const parsedValue = savedPreference === 'true';
      setUseCloudApi(parsedValue);
      Environment.useCloudApi = parsedValue;
    }
  }, []);
  
  // Only show in development mode
  if (process.env.NODE_ENV === 'production') {
    return null;
  }
  
  return (
    <div className="fixed bottom-4 right-4 z-50 bg-gray-800 p-3 rounded-lg shadow-lg border border-purple-500">
      <div className="flex items-center space-x-2">
        <span className="text-xs text-white">
          {useCloudApi ? 'Cloud API' : 'Local API'}
        </span>
        <label className="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            className="sr-only peer"
            checked={useCloudApi}
            onChange={handleToggleChange}
          />
          <div className="w-9 h-5 bg-gray-600 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-purple-600"></div>
        </label>
      </div>
      <div className="mt-1 text-[10px] text-gray-400">
        {useCloudApi ? 'panel.metatravel.ai' : 'localhost:8000'}
      </div>
    </div>
  );
};

export default DevEnvironmentSwitcher;
