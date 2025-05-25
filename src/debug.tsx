import React from 'react';

const Debug: React.FC = () => {
  console.log('🐝 Debug component loaded!');
  
  return (
    <div className="min-h-screen bg-red-100 flex items-center justify-center">
      <div className="bg-white p-8 rounded-lg shadow-lg">
        <h1 className="text-2xl font-bold text-red-600 mb-4">🔧 Debug Mode</h1>
        <p className="text-gray-700 mb-4">
          Si vous voyez cette page, React fonctionne !
        </p>
        <div className="space-y-2 text-sm">
          <p><strong>Timestamp:</strong> {new Date().toLocaleString()}</p>
          <p><strong>User Agent:</strong> {navigator.userAgent}</p>
          <p><strong>URL:</strong> {window.location.href}</p>
        </div>
      </div>
    </div>
  );
};

export default Debug; 