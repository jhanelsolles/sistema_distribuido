importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

const firebaseConfig = {
  apiKey: "AIzaSyAHWcKC6SoJVAE96sSaJZyBgfkDyEfQ16w",
  authDomain: "notificaciones-prueba-2b61c.firebaseapp.com",
  projectId: "notificaciones-prueba-2b61c",
  storageBucket: "notificaciones-prueba-2b61c.firebasestorage.app",
  messagingSenderId: "602591268002",
  appId: "1:602591268002:web:7de8f2e9e027e94f895bfb",
  measurementId: "G-FDREG08FMH"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
