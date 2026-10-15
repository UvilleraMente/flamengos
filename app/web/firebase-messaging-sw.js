// Service worker de Firebase Cloud Messaging: muestra las notificaciones push
// cuando la web de Flamengos está cerrada o en segundo plano.
// La configuración es la de lib/firebase_options.dart (web); no es secreta.
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDAnChUot_4936hR02I6p6dwmoPnUsRJy8',
  appId: '1:618098821671:web:850ba8fc57bb674b6a5c02',
  messagingSenderId: '618098821671',
  projectId: 'flamengos-app',
  authDomain: 'flamengos-app.firebaseapp.com',
  storageBucket: 'flamengos-app.firebasestorage.app',
});

// Los mensajes traen `notification`, así que el navegador los muestra solo.
firebase.messaging();
