// Custom service worker for better cache control
const CACHE_NAME = 'mti-app-cache';
const APP_VERSION = '0.0.3';  // Hard coded version - must update when app version changes

// Files to cache immediately
const urlsToCache = [
  './',
  './index.html',
  './flutter_bootstrap.js',
  './main.dart.js',
  './flutter_service_worker.js',
  './manifest.json',
  './assets/AssetManifest.json',
  './assets/FontManifest.json',
  './assets/NOTICES.Z',
  './assets/fonts/MaterialIcons-Regular.otf',
  './assets/images/mti_logo.png'
];

// Track if service worker is being updated during hot restart
let isHotRestarting = false;

// Listen for messages from the main page
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  // Handle hot restart messages
  if (event.data && event.data.type === 'HOT_RESTART') {
    isHotRestarting = true;
    console.log('[Service Worker] Hot restart in progress');
  }
});

// Installation event
self.addEventListener('install', event => {
  console.log('[Service Worker] Installing new service worker version');
  self.skipWaiting(); // Force activation on install
  
  event.waitUntil(
    caches.open(CACHE_NAME + '-' + APP_VERSION)
      .then(cache => {
        console.log('[Service Worker] Caching app shell');
        return cache.addAll(urlsToCache);
      })
      .catch(error => {
        console.error('[Service Worker] Cache installation failed:', error);
        // Don't fail the service worker installation on cache error
        return Promise.resolve();
      })
  );
});

// Activation event - clean up old caches
self.addEventListener('activate', event => {
  console.log('[Service Worker] Activating new service worker');
  
  // Claim clients immediately so the new service worker takes over
  event.waitUntil(clients.claim());
  
  // Delete old caches
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.filter(cacheName => {
          // Delete old caches that don't match the current version
          return cacheName.startsWith(CACHE_NAME) && 
                 !cacheName.endsWith(APP_VERSION);
        }).map(cacheName => {
          console.log('[Service Worker] Deleting old cache:', cacheName);
          return caches.delete(cacheName);
        })
      );
    }).catch(error => {
      console.error('[Service Worker] Error cleaning old caches:', error);
      // Don't fail activation on cache cleanup error
      return Promise.resolve();
    })
  );
});

// Fetch event - network first, then cache
self.addEventListener('fetch', event => {
  // Don't handle fetch during hot restart to prevent errors
  if (isHotRestarting) {
    console.log('[Service Worker] Ignoring fetch during hot restart');
    return;
  }
  
  // Skip non-GET requests and non-HTTP/HTTPS URLs
  if (event.request.method !== 'GET' || 
      !event.request.url.startsWith('http')) {
    return;
  }
  
  // Handle main.dart.js specially - always network first
  if (event.request.url.includes('main.dart.js')) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          // Clone the response for caching
          const responseToCache = response.clone();
          
          // Update the cache
          caches.open(CACHE_NAME + '-' + APP_VERSION)
            .then(cache => {
              cache.put(event.request, responseToCache);
            })
            .catch(error => {
              console.error('[Service Worker] Error caching main.dart.js:', error);
            });
          
          return response;
        })
        .catch(error => {
          console.error('[Service Worker] Fetch failed for main.dart.js:', error);
          // If network fails, try the cache
          return caches.match(event.request);
        })
    );
    return;
  }
  
  // For other assets, check cache first, then network
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return from cache if present
        if (response) {
          return response;
        }
        
        // Otherwise fetch from network
        return fetch(event.request)
          .then(networkResponse => {
            // Don't cache if response is not ok
            if (!networkResponse || networkResponse.status !== 200) {
              return networkResponse;
            }
            
            // Clone the response for caching and returning
            const responseToCache = networkResponse.clone();
            
            // Only cache successful responses from our origin
            if (networkResponse.status === 200 && 
                event.request.url.startsWith(self.location.origin)) {
              caches.open(CACHE_NAME + '-' + APP_VERSION)
                .then(cache => {
                  cache.put(event.request, responseToCache);
                })
                .catch(error => {
                  console.error('[Service Worker] Error caching asset:', error);
                });
            }
            
            return networkResponse;
          })
          .catch(error => {
            console.error('[Service Worker] Network fetch failed:', error);
            // If everything fails, return a fallback response
            return new Response('Network error occurred', {
              status: 408,
              headers: new Headers({
                'Content-Type': 'text/plain'
              })
            });
          });
      })
      .catch(error => {
        console.error('[Service Worker] Cache match failed:', error);
        // If cache match throws, fetch from network
        return fetch(event.request);
      })
  );
});

// Handle service worker errors
self.addEventListener('error', event => {
  console.error('[Service Worker] Error:', event.message, event.filename, event.lineno);
});

// Handle unhandled promise rejections
self.addEventListener('unhandledrejection', event => {
  console.error('[Service Worker] Unhandled promise rejection:', event.reason);
});
