// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

// Your web app's Firebase configuration
const firebaseConfig = {
  projectId: "ruche-connectee-93eab",
  apiKey: "AIzaSyD5Ut6RTBj0l6PmR0tTFJrD2zvE-hyvJjE",
  authDomain: "ruche-connectee-93eab.firebaseapp.com",
  storageBucket: "ruche-connectee-93eab.appspot.com",
  messagingSenderId: "331852612281",
  appId: "1:331852612281:web:YOUR_WEB_APP_ID",
  measurementId: "G-MEASUREMENT_ID"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

export { app, analytics }; 