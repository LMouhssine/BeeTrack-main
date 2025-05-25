import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import Debug from './debug.tsx';
import './index.css';

console.log('🐝 Main.tsx loaded!');

// Utiliser Debug temporairement pour tester
const isDevelopment = import.meta.env.DEV;
const useDebug = false; // Changez à true pour activer le debug

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    {useDebug ? <Debug /> : <App />}
  </StrictMode>
);
