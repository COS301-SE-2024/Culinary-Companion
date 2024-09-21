const CACHE_NAME = "pantry-app-cache-v1";
const DATA_CACHE_NAME = "pantry-data-cache-v1";
const FILES_TO_CACHE = [
  '/',
  '/index.html',
  '/main.dart.js',
  '/assets/loading.json',
  // Add more assets as needed
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('Pre-caching offline page');
      return cache.addAll(FILES_TO_CACHE);
    })
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/supabase.co/functions')) {
    event.respondWith(
      caches.open(DATA_CACHE_NAME).then((cache) => {
        return fetch(event.request)
          .then((response) => {
            cache.put(event.request.url, response.clone());
            return response;
          })
          .catch(() => {
            return cache.match(event.request);
          });
      })
    );
    return;
  }

  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});

self.addEventListener('activate', (event) => {
  const cacheWhitelist = [CACHE_NAME, DATA_CACHE_NAME];
  event.waitUntil(
    caches.keys().then((keyList) =>
      Promise.all(
        keyList.map((key) => {
          if (!cacheWhitelist.includes(key)) {
            return caches.delete(key);
          }
        })
      )
    )
  );
});
