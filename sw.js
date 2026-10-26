// Neon Keys offline helper for the tablet app.
// The game files are kept on the device so Neon Keys opens without internet.
// When online it always fetches the newest version first, so updates arrive by themselves.
const CACHE = 'neonkeys-v1';
const FILES = ['./', 'NeonKeys.html', 'songs-library.js', 'manifest.webmanifest',
  'icons/icon.svg', 'icons/icon-192.png', 'icons/icon-512.png', 'icons/icon-maskable-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});

// newest from the internet, but never wait more than a few seconds: fall back to the saved copy
function networkFirst(req) {
  return caches.open(CACHE).then(cache => new Promise(resolve => {
    let done = false;
    const fallback = () => cache.match(req, {ignoreSearch:true}).then(r => r || (req.mode === 'navigate' ? cache.match('NeonKeys.html') : null));
    const timer = setTimeout(() => fallback().then(r => { if (r && !done) { done = true; resolve(r); } }), 4000);
    fetch(req).then(res => {
      if (res.ok) cache.put(req, res.clone());
      if (!done) { done = true; clearTimeout(timer); resolve(res); }
    }).catch(() => fallback().then(r => { if (!done) { done = true; clearTimeout(timer); resolve(r || Response.error()); } }));
  }));
}
// fonts never change: use the saved copy if there is one
function cacheFirst(req) {
  return caches.open(CACHE).then(cache => cache.match(req).then(hit => hit || fetch(req).then(res => { if (res.ok || res.type === 'opaque') cache.put(req, res.clone()); return res; })));
}

self.addEventListener('fetch', e => {
  const req = e.request; if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin === location.origin) e.respondWith(networkFirst(req));
  else if (/fonts\.(googleapis|gstatic)\.com$/.test(url.hostname)) e.respondWith(cacheFirst(req));
});
