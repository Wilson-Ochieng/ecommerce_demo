// Give the service worker access to Firebase Messaging.
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: 'AIzaSyD8ryJvFOJy3jo6Fn8Y4iPoQTNzdwKHifk',
     appId: '1:277705410335:web:6661796f592a9d6c0c122a',
     messagingSenderId: '277705410335',
     projectId: 'ecommerce-app-460ef',
     authDomain: 'ecommerce-app-460ef.firebaseapp.com',
     storageBucket: 'ecommerce-app-460ef.firebasestorage.app',
     measurementId: 'G-H2HS9XS570',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title ?? 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body ?? '',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});