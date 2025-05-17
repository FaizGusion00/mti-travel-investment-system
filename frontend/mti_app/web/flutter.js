// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * This script is responsible for loading the Flutter app.
 * It handles service worker registration and app initialization.
 */
(function() {
  'use strict';

  // The name of the IndexedDB database used to store the Flutter app's data.
  const flutterStorageName = 'flutter_app_storage';
  
  /**
   * Creates a function that returns a promise for loading the Flutter app.
   */
  function loadApp() {
    let flutterScriptLoaded = false;
    
    /**
     * Handles loading the Flutter app.
     * @param {string} entrypointUrl - The URL of the entrypoint script (main.dart.js).
     */
    return function loadEntrypoint(entrypointUrl) {
      if (!flutterScriptLoaded) {
        console.log('[Flutter] Loading main Flutter script: ' + entrypointUrl);
        
        return new Promise((resolve, reject) => {
          try {
            // Load the main.dart.js script
            const scriptTag = document.createElement('script');
            scriptTag.src = entrypointUrl;
            scriptTag.type = 'application/javascript';
            
            // Handle loading errors
            scriptTag.addEventListener('error', (error) => {
              console.error('[Flutter] Failed to load Flutter script:', error);
              reject(new Error(`Failed to load Flutter script: ${entrypointUrl}`));
              document.body.removeChild(scriptTag);
            });

            // Handle successful loading
            scriptTag.addEventListener('load', () => {
              flutterScriptLoaded = true;
              console.log('[Flutter] Script loaded successfully');
              resolve(window._flutter);
            });

            // Add the script to the document
            document.body.appendChild(scriptTag);
          } catch (error) {
            console.error('[Flutter] Error loading Flutter application:', error);
            reject(error);
          }
        });
      } else {
        return Promise.resolve(window._flutter);
      }
    };
  }

  /**
   * Creates an object with the Flutter app's loading functionality.
   */
  const loader = {
    /**
     * Loads the Flutter app's entrypoint.
     * @param {Object} options - Options for loading the app.
     * @returns {Promise} A promise that resolves when the app is loaded.
     */
    loadEntrypoint: function(options) {
      const entrypointUrl = options?.entrypointUrl || 'main.dart.js';
      return loadApp()(entrypointUrl)
        .then(flutter => {
          if (!flutter || !flutter.loader || !flutter.loader.engineInitializer) {
            throw new Error('Flutter engine initializer not available');
          }
          return flutter.loader.engineInitializer.initializeEngine({
            ...options,
            // Pass the proper canvasKitBaseUrl if not provided
            canvasKitBaseUrl: options?.canvasKitBaseUrl || '/canvaskit/'
          });
        })
        .then(appRunner => {
          return appRunner.runApp();
        });
    }
  };

  // Expose the loader globally
  window._flutter = window._flutter || {};
  window._flutter.loader = loader;

  // Create a basic service worker registration function
  function registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function() {
        const serviceWorkerUrl = 'flutter_service_worker.js?v=' + 
          (window.flutterAppVersion || new Date().getTime());
          
        navigator.serviceWorker.register(serviceWorkerUrl)
          .then(function(registration) {
            console.log('[Flutter] Service Worker registered with scope:', registration.scope);
            
            // Handle updates
            if (registration.waiting) {
              registration.waiting.postMessage({ type: 'SKIP_WAITING' });
            }
            
            registration.addEventListener('updatefound', function() {
              const installingWorker = registration.installing;
              installingWorker.addEventListener('statechange', function() {
                if (installingWorker.state === 'installed' && 
                    navigator.serviceWorker.controller) {
                  // New content is available, reload to use it
                  console.log('[Flutter] New service worker available, reloading app...');
                  window.location.reload();
                }
              });
            });
          })
          .catch(function(error) {
            console.error('[Flutter] Service Worker registration failed:', error);
          });
          
        // Check for controller change
        let refreshing = false;
        navigator.serviceWorker.addEventListener('controllerchange', function() {
          if (!refreshing) {
            console.log('[Flutter] Service worker controller changed, reloading...');
            refreshing = true;
            window.location.reload();
          }
        });
      });
    }
  }
  
  // Register service worker
  registerServiceWorker();
  
  console.log('[Flutter] Flutter.js initialized successfully');
})(); 