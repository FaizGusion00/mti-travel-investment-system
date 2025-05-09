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

// Installation event
self.addEventListener('install', event => {
  self.skipWaiting(); // Force activation on install
  event.waitUntil(
    caches.open(CACHE_NAME + '-' + APP_VERSION)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
});

// Activation event - clean up old caches
self.addEventListener('activate', event => {
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
          console.log('Deleting old cache:', cacheName);
          return caches.delete(cacheName);
        })
      );
    })
  );
});

// Fetch event - network first, then cache
self.addEventListener('fetch', event => {
  // Skip non-GET requests
  if (event.request.method !== 'GET') return;
  
  // Handle main.dart.js specially - always network first
  if (event.request.url.includes('main.dart.js')) {
    return event.respondWith(
      fetch(event.request)
        .then(response => {
          // Clone the response for caching
          const responseToCache = response.clone();
          
          // Update the cache
          caches.open(CACHE_NAME + '-' + APP_VERSION)
            .then(cache => {
              cache.put(event.request, responseToCache);
            });
          
          return response;
        })
        .catch(() => {
          // If network fails, try the cache
          return caches.match(event.request);
        })
    );
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
            // Clone the response for caching and returning
            const responseToCache = networkResponse.clone();
            
            // Only cache successful responses from our origin
            if (networkResponse.status === 200 && 
                event.request.url.startsWith(self.location.origin)) {
              caches.open(CACHE_NAME + '-' + APP_VERSION)
                .then(cache => {
                  cache.put(event.request, responseToCache);
                });
            }
            
            return networkResponse;
          });
      })
  );
});

// Message event - handle update notifications
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
