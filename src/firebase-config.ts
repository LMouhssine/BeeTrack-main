// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getAnalytics } from "firebase/analytics";

// Your web app's Firebase configuration
const firebaseConfig = {
  projectId: "ruche-connectee-93eab",
  apiKey: "AIzaSyCtPJSY4K3K7NgqPF3pGHgeICtzn4Wbu5M",
  authDomain: "ruche-connectee-93eab.firebaseapp.com",
  storageBucket: "ruche-connectee-93eab.firebasestorage.app",
  messagingSenderId: "331852612281",
  appId: "1:331852612281:web:7b80072001f8a8ce3d5168",
  measurementId: "G-MEASUREMENT_ID"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
const auth = getAuth(app);
const db = getFirestore(app);
const analytics = getAnalytics(app);

export { app, auth, db, analytics }; 