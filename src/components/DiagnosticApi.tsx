import React, { useState, useEffect } from 'react';
import { CheckCircle, XCircle, RefreshCw, Activity } from 'lucide-react';
import { DonneesCapteursService } from '../services/donneesCapteursService';
import { auth, db } from '../firebase-config';

const DiagnosticFirebase: React.FC = () => {
  const [tests, setTests] = useState({
    auth: { status: 'pending', message: '', time: 0 },
    firestore: { status: 'pending', message: '', time: 0 },
    createTestData: { status: 'pending', message: '', time: 0 },
  });

  const testFirebaseService = async (name: string, testFunc: () => Promise<any>) => {
    const startTime = Date.now();
    try {
      await testFunc();
      const endTime = Date.now();
      return {
        status: 'success' as const,
        message: '✅ Connexion réussie',
        time: endTime - startTime,
      };
    } catch (error: any) {
      const endTime = Date.now();
      return {
        status: 'error' as const,
        message: `❌ ${error.message}`,
        time: endTime - startTime,
      };
    }
  };

  const runTests = async () => {
    setTests({
      auth: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
      firestore: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
      createTestData: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
    });

    // Test 1: Authentification Firebase
    const authResult = await testFirebaseService('auth', async () => {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }
      return currentUser;
    });

    // Test 2: Connectivité Firestore
    const firestoreResult = await testFirebaseService('firestore', async () => {
      const isConnected = await DonneesCapteursService.testConnectivite();
      if (!isConnected) {
        throw new Error('Impossible de se connecter à Firestore');
      }
      return true;
    });

    // Test 3: Test de création de données
    let createTestResult = {
      status: 'error' as const,
      message: '⏭️ Ignoré (utilisateur non connecté)',
      time: 0,
    };

    if (authResult.status === 'success' && firestoreResult.status === 'success') {
      createTestResult = await testFirebaseService('createTestData', async () => {
        const nombreMesures = await DonneesCapteursService.creerDonneesTest('test-ruche-diagnostic', 1, 2);
        return `${nombreMesures} mesures créées`;
      });
    }

    setTests({
      auth: authResult,
      firestore: firestoreResult,
      createTestData: createTestResult,
    });
  };

  useEffect(() => {
    runTests();
  }, []);

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-5 h-5 text-green-500" />;
      case 'error':
        return <XCircle className="w-5 h-5 text-red-500" />;
      default:
        return <Activity className="w-5 h-5 text-yellow-500 animate-pulse" />;
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-medium text-gray-900">🔧 Diagnostic Firebase</h3>
        <button
          onClick={runTests}
          className="flex items-center space-x-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
        >
          <RefreshCw className="w-4 h-4" />
          <span>Relancer</span>
        </button>
      </div>

      <div className="space-y-3">
        <div className="text-sm text-gray-600 mb-3">
          <strong>Utilisateur actuel:</strong> {auth.currentUser?.email || 'Non connecté'}
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.auth.status)}
          <div className="flex-1">
            <p className="font-medium">Authentification Firebase</p>
            <p className="text-sm text-gray-600">Vérification de l'utilisateur connecté</p>
            <p className="text-sm">{tests.auth.message}</p>
            {tests.auth.time > 0 && (
              <p className="text-xs text-gray-500">⏱️ {tests.auth.time}ms</p>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.firestore.status)}
          <div className="flex-1">
            <p className="font-medium">Connectivité Firestore</p>
            <p className="text-sm text-gray-600">Test de connexion à la base de données</p>
            <p className="text-sm">{tests.firestore.message}</p>
            {tests.firestore.time > 0 && (
              <p className="text-xs text-gray-500">⏱️ {tests.firestore.time}ms</p>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.createTestData.status)}
          <div className="flex-1">
            <p className="font-medium">Création de données de test</p>
            <p className="text-sm text-gray-600">Test d'écriture dans Firestore</p>
            <p className="text-sm">{tests.createTestData.message}</p>
            {tests.createTestData.time > 0 && (
              <p className="text-xs text-gray-500">⏱️ {tests.createTestData.time}ms</p>
            )}
          </div>
        </div>
      </div>

      <div className="mt-4 pt-4 border-t border-gray-200">
        <div className="text-sm text-gray-600">
          <p><strong>💡 Instructions:</strong></p>
          <ul className="list-disc list-inside space-y-1 mt-1">
            <li>Assurez-vous d'être connecté avec un compte Firebase valide</li>
            <li>Si Firestore ne fonctionne pas, vérifiez la configuration Firebase</li>
            <li>Le test de création de données vous permet de vérifier les permissions d'écriture</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default DiagnosticFirebase; 