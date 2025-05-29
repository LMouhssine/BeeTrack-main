import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

// Test d'import Firebase
console.log('🐝 Testing Firebase imports...');
try {
  import('./firebase-config').then(({ auth, db }) => {
    console.log('🐝 Firebase imports successful:', { auth: !!auth, db: !!db });
  });
} catch (error) {
  console.error('🐝 Firebase import error:', error);
}

console.log('🐝 Main.tsx loaded - BeeTrack Application Starting!');

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
