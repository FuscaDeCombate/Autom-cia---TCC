// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyD96SOsLl0EELtKhkrpjTliBR846PFqLL0",
  authDomain: "automacia-4ec6b.firebaseapp.com",
  projectId: "automacia-4ec6b",
  storageBucket: "automacia-4ec6b.firebasestorage.app",
  messagingSenderId: "897837676738",
  appId: "1:897837676738:web:f50777ffb8f8b8dade635b",
  measurementId: "G-34GZ8N7CQ1"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);