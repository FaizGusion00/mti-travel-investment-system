// Enhanced service worker with improved caching strategies and offline capabilities
const CACHE_NAME = 'mti-app-cache';
const APP_VERSION = '0.0.4';  // Sync with index.html and manifest.json version
const STATIC_CACHE = `${CACHE_NAME}-static-${APP_VERSION}`;
const DYNAMIC_CACHE = `${CACHE_NAME}-dynamic-${APP_VERSION}`;
const ASSET_CACHE = `${CACHE_NAME}-assets-${APP_VERSION}`;
const API_CACHE = `${CACHE_NAME}-api-${APP_VERSION}`;

// Analytics tracking
const trackEvent = (eventName, eventData = {}) => {
  try {
    const data = {
      event: eventName,
      timestamp: new Date().toISOString(),
      serviceWorker: true,
      version: APP_VERSION,
      ...eventData
    };
    
    // Log event to console in debug mode
    console.log('Service Worker Event:', data);
    
    // In a production app, you would send this to your analytics endpoint
    // fetch('/api/analytics', { method: 'POST', body: JSON.stringify(data) });
  } catch (err) {
    console.error('Failed to track event', err);
  }
};

// Core files needed for app shell - these must be cached for offline functionality
const CORE_ASSETS = [
  './',
  './index.html',
  './flutter_bootstrap.js',
  './manifest.json',
  './favicon.ico'
];

// High priority assets to cache immediately
const PRIORITY_ASSETS = [
  './assets/images/mti_logo.png',
  './assets/fonts/MaterialIcons-Regular.otf',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

// Secondary assets to cache early but not blocking app load
const SECONDARY_ASSETS = [
  './assets/AssetManifest.json',
  './assets/FontManifest.json',
  './assets/NOTICES.Z',
  './main.dart.js',
  './flutter_service_worker.js'
];

// Files that shouldn't be cached
const NO_CACHE_URLS = [
  '/api/auth',
  '/api/login',
  '/api/register'
];

// Helper to check if a request should bypass cache
const shouldBypassCache = (url) => {
  const requestUrl = new URL(url);
  
  // Never cache authentication requests
  if (NO_CACHE_URLS.some(nocacheUrl => requestUrl.pathname.includes(nocacheUrl))) {
    return true;
  }
  
  // Don't cache query params with nocache
  return requestUrl.searchParams.has('nocache');
};

// Enhanced installation event with progressive caching strategy
self.addEventListener('install', event => {
  trackEvent('install_started');
  
  // Force activation on install
  self.skipWaiting();
  
  // Multi-stage caching strategy:
  event.waitUntil(
    Promise.all([
      // 1. Cache core app shell assets (critical for offline functionality)
      caches.open(STATIC_CACHE).then(cache => {
        return cache.addAll(CORE_ASSETS).then(() => {
          trackEvent('core_assets_cached');
        });
      }),
      
      // 2. Cache priority assets
      caches.open(ASSET_CACHE).then(cache => {
        return cache.addAll(PRIORITY_ASSETS).then(() => {
          trackEvent('priority_assets_cached');
        });
      })
    ])
    .then(() => {
      // 3. Cache secondary assets (non-blocking)
      return caches.open(ASSET_CACHE).then(cache => {
        cache.addAll(SECONDARY_ASSETS).then(() => {
          trackEvent('secondary_assets_cached');
        });
      });
    })
    .then(() => {
      trackEvent('install_complete');
    })
    .catch(error => {
      trackEvent('install_error', { error: error.toString() });
    })
  );
});

// Enhanced activation event with better cleanup and client control
self.addEventListener('activate', event => {
  trackEvent('activate_started');
  
  // Claim clients immediately so the new service worker takes over
  event.waitUntil(clients.claim());
  
  // Delete old caches using Promise.all for parallel execution
  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        // Find all outdated caches
        const oldCaches = cacheNames.filter(cacheName => {
          // Keep only current version caches
          return cacheName.startsWith(CACHE_NAME) && 
                 !cacheName.includes(APP_VERSION);
        });
        
        if (oldCaches.length > 0) {
          trackEvent('cleaning_old_caches', { count: oldCaches.length });
          console.log('Removing old caches:', oldCaches);
        }
        
        // Delete old caches in parallel
        return Promise.all(oldCaches.map(oldCache => caches.delete(oldCache)));
      })
      .then(() => {
        trackEvent('activate_complete');
        console.log('Service worker activated and caches cleaned');
      })
      .catch(error => {
        trackEvent('activate_error', { error: error.toString() });
      })
  );
});

// Enhanced fetch event with adaptive caching strategies based on request types
self.addEventListener('fetch', event => {
  // Skip cross-origin requests without credentials to avoid CORS issues
  if (!event.request.url.startsWith(self.location.origin) && !event.request.url.includes('api.metatravel.ai')) {
    return;
  }
  
  // Skip non-GET requests
  if (event.request.method !== 'GET') return;
  
  // Get request URL for analysis
  const requestUrl = new URL(event.request.url);
  
  // Skip requests that should bypass cache
  if (shouldBypassCache(event.request.url)) {
    return;
  }
  
  // Different caching strategies based on content type:
  
  // 1. Strategy for API calls - network first with timed cache fallback
  if (requestUrl.pathname.includes('/api/')) {
    return event.respondWith(apiNetworkFirstStrategy(event));
  }
  
  // 2. Strategy for main.dart.js - network first, fallback to cache
  if (requestUrl.pathname.endsWith('main.dart.js')) {
    return event.respondWith(networkFirstStrategy(event));
  }
  
  // 3. Strategy for core app assets - cache first, network fallback
  if (CORE_ASSETS.some(asset => requestUrl.pathname.endsWith(asset)) || 
      PRIORITY_ASSETS.some(asset => requestUrl.pathname.endsWith(asset))) {
    return event.respondWith(cacheFirstStrategy(event));
  }
  
  // 4. Strategy for images and other assets - stale while revalidate
  if (requestUrl.pathname.includes('/assets/') || 
      requestUrl.pathname.includes('/icons/')) {
    return event.respondWith(staleWhileRevalidateStrategy(event));
  }
  
  // 5. Default strategy - cache first, network fallback
  event.respondWith(cacheFirstStrategy(event));
});

// Strategy implementation - Network First
function networkFirstStrategy(event) {
  return fetch(event.request)
    .then(networkResponse => {
      // Clone the response for caching and returning
      const responseToCache = networkResponse.clone();
      
      // Cache the response if valid
      if (networkResponse.status === 200) {
        caches.open(DYNAMIC_CACHE)
          .then(cache => cache.put(event.request, responseToCache));
      }
      
      return networkResponse;
    })
    .catch(() => {
      // If network fails, try the cache
      return caches.match(event.request)
        .then(cachedResponse => {
          if (cachedResponse) {
            return cachedResponse;
          }
          // If nothing in cache, return offline fallback
          return caches.match('./offline.html');
        });
    });
}

// Strategy implementation - Cache First
function cacheFirstStrategy(event) {
  return caches.match(event.request)
    .then(cacheResponse => {
      // Return cached response if available
      if (cacheResponse) {
        // Revalidate in the background after returning cached response
        fetch(event.request)
          .then(networkResponse => {
            if (networkResponse.status === 200) {
              caches.open(STATIC_CACHE)
                .then(cache => cache.put(event.request, networkResponse));
            }
          })
          .catch(() => {});
        return cacheResponse;
      }
      
      // If not in cache, fetch from network
      return fetch(event.request)
        .then(networkResponse => {
          // Clone the response for caching
          const responseToCache = networkResponse.clone();
          
          // Cache successful responses
          if (networkResponse.status === 200) {
            caches.open(STATIC_CACHE)
              .then(cache => cache.put(event.request, responseToCache));
          }
          
          return networkResponse;
        })
        .catch(() => {
          // Return offline fallback if both cache and network fail
          return caches.match('./offline.html');
        });
    });
}

// Strategy implementation - Stale While Revalidate
function staleWhileRevalidateStrategy(event) {
  return caches.match(event.request)
    .then(cacheResponse => {
      // Start network fetch in parallel
      const fetchPromise = fetch(event.request)
        .then(networkResponse => {
          // Cache the new response
          if (networkResponse.status === 200) {
            const responseToCache = networkResponse.clone();
            caches.open(ASSET_CACHE)
              .then(cache => cache.put(event.request, responseToCache));
          }
          return networkResponse;
        })
        .catch(() => {
          // Swallow network errors - we'll use cache anyway
          return null;
        });
      
      // Return the cached response immediately if available
      return cacheResponse || fetchPromise;
    });
}

// Strategy implementation - API Network First with timeout
function apiNetworkFirstStrategy(event) {
  // For API requests, we'll use a network request with a timeout
  const timeoutPromise = new Promise(resolve => {
    setTimeout(() => {
      resolve(caches.match(event.request));
    }, 3000); // 3 second timeout
  });
  
  const networkPromise = fetch(event.request)
    .then(networkResponse => {
      // For successful API responses, cache them with a 5-minute expiry
      if (networkResponse.status === 200) {
        const clonedResponse = networkResponse.clone();
        
        caches.open(API_CACHE).then(cache => {
          // Add expiration metadata to the response
          const expirationTime = Date.now() + (5 * 60 * 1000); // 5 minutes
          const headers = new Headers(clonedResponse.headers);
          headers.append('sw-cache-expiry', expirationTime);
          
          // Create a new response with the expiry header
          const responseWithExpiry = new Response(clonedResponse.body, {
            status: clonedResponse.status,
            statusText: clonedResponse.statusText,
            headers: headers
          });
          
          cache.put(event.request, responseWithExpiry);
        });
      }
      
      return networkResponse;
    })
    .catch(() => {
      // If the network request fails, try the cache
      return caches.match(event.request).then(cachedResponse => {
        // Check if the cached response has expired
        if (cachedResponse) {
          const expiry = cachedResponse.headers.get('sw-cache-expiry');
          
          if (expiry && parseInt(expiry) > Date.now()) {
            // Not expired yet, return cached response
            return cachedResponse;
          }
          
          // Expired, don't use this response
          // Delete it from the cache in the background
          caches.open(API_CACHE).then(cache => {
            cache.delete(event.request);
          });
        }
        
        // Return fallback response if available
        return caches.match('./api-offline.json');
      });
    });
  
  // Return whichever happens first - the network response or the timeout
  return Promise.race([networkPromise, timeoutPromise]);
}

// Enhanced message handling for better control and communication
self.addEventListener('message', event => {
  const message = event.data;
  
  if (!message) return;
  
  trackEvent('message_received', { type: message.type });
  
  switch (message.type) {
    case 'SKIP_WAITING':
      self.skipWaiting();
      break;
      
    case 'CACHE_URLS':
      // Allows the app to request specific URLs to be cached
      if (message.urls && Array.isArray(message.urls)) {
        event.waitUntil(
          caches.open(DYNAMIC_CACHE).then(cache => {
            return Promise.all(
              message.urls.map(url => {
                return fetch(url)
                  .then(response => {
                    if (response.status === 200) {
                      return cache.put(url, response);
                    }
                  })
                  .catch(error => {
                    trackEvent('cache_url_error', { url, error: error.toString() });
                  });
              })
            );
          })
        );
      }
      break;
      
    case 'CLEAR_CACHE':
      // Allows the app to request cache clearing
      event.waitUntil(
        caches.keys().then(cacheNames => {
          return Promise.all(
            cacheNames.filter(cacheName => {
              return cacheName.startsWith(CACHE_NAME);
            }).map(cacheName => {
              trackEvent('cache_cleared', { cache: cacheName });
              return caches.delete(cacheName);
            })
          );
        })
      );
      break;
      
    case 'GET_VERSION':
      // Respond with current version info
      if (event.ports && event.ports[0]) {
        event.ports[0].postMessage({
          version: APP_VERSION,
          cacheStatus: 'ready'
        });
      }
      break;
  }
});

// Add offline fallback page handling
self.addEventListener('fetch', event => {
  // Only intercept navigate requests
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request)
        .catch(() => {
          // If the main page can't be fetched, show the offline page
          return caches.match('./offline.html')
            .then(response => {
              return response || new Response(
                '<html><body><h1>You are offline</h1><p>Please check your connection and try again.</p></body></html>',
                {
                  headers: { 'Content-Type': 'text/html' }
                }
              );
            });
        })
    );
  }
});
