'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

interface ErrorBoundaryProps {
  children: React.ReactNode;
}

export default function ErrorBoundary({ children }: ErrorBoundaryProps) {
  const [hasError, setHasError] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    // Add global error handler
    const errorHandler = (event: ErrorEvent) => {
      console.error('Global error caught:', event.error);
      setError(event.error);
      setHasError(true);
      // Prevent the default error handling
      event.preventDefault();
    };

    // Add unhandled promise rejection handler
    const rejectionHandler = (event: PromiseRejectionEvent) => {
      console.error('Unhandled Promise rejection:', event.reason);
      setError(new Error(event.reason?.message || 'Unknown promise rejection'));
      setHasError(true);
      // Prevent the default error handling
      event.preventDefault();
    };

    window.addEventListener('error', errorHandler);
    window.addEventListener('unhandledrejection', rejectionHandler);

    return () => {
      window.removeEventListener('error', errorHandler);
      window.removeEventListener('unhandledrejection', rejectionHandler);
    };
  }, []);

  if (hasError) {
    return (
      <div className="min-h-screen flex flex-col justify-center items-center p-6 bg-gray-900">
        <div className="bg-red-900/30 border border-red-500 rounded-lg p-8 max-w-lg w-full text-center">
          <h2 className="text-2xl font-bold text-white mb-4">Something went wrong</h2>
          <p className="text-gray-300 mb-6">
            An unexpected error occurred. Please try refreshing the page or return to the home page.
          </p>
          <div className="space-y-4">
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 bg-red-600 hover:bg-red-700 text-white rounded-lg shadow-lg transition-colors mr-4"
            >
              Refresh Page
            </button>
            <Link
              href="/"
              className="px-6 py-3 bg-gray-700 hover:bg-gray-600 text-white rounded-lg shadow-lg transition-colors"
            >
              Go Home
            </Link>
          </div>
          
          {process.env.NODE_ENV !== 'production' && error && (
            <div className="mt-8 text-left p-4 bg-black/50 rounded-lg overflow-auto max-h-60">
              <p className="text-red-400 font-mono text-sm mb-2">Error details (visible in development only):</p>
              <p className="text-gray-400 font-mono text-xs">{error.message}</p>
              <p className="text-gray-500 font-mono text-xs mt-2">{error.stack}</p>
            </div>
          )}
        </div>
      </div>
    );
  }

  return <>{children}</>;
} 