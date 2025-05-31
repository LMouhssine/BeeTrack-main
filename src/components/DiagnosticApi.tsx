import React, { useState, useEffect } from 'react';
import { CheckCircle, XCircle, RefreshCw, Activity } from 'lucide-react';
import { RucheService } from '../services/rucheService';
import { API_BASE_URL, API_ENDPOINTS, buildApiUrl } from '../config/api-config';

const DiagnosticApi: React.FC = () => {
  const [tests, setTests] = useState({
    devHealth: { status: 'pending', message: '', time: 0 },
    mainHealth: { status: 'pending', message: '', time: 0 },
    createTestData: { status: 'pending', message: '', time: 0 },
  });

  const testEndpoint = async (name: string, url: string, options: RequestInit = {}) => {
    const startTime = Date.now();
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
        ...options,
      });
      
      const endTime = Date.now();
      const responseTime = endTime - startTime;
      
      if (response.ok) {
        const data = await response.json();
        return {
          status: 'success' as const,
          message: `✅ OK (${response.status}) - ${data.message || 'Réponse reçue'}`,
          time: responseTime,
        };
      } else {
        return {
          status: 'error' as const,
          message: `❌ Erreur ${response.status}`,
          time: responseTime,
        };
      }
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
      devHealth: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
      mainHealth: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
      createTestData: { status: 'pending', message: '⏳ Test en cours...', time: 0 },
    });

    // Test 1: Endpoint de développement
    const devHealthResult = await testEndpoint(
      'devHealth',
      buildApiUrl(API_ENDPOINTS.DEV_HEALTH)
    );

    // Test 2: Endpoint principal de test
    const mainHealthResult = await testEndpoint(
      'mainHealth',
      buildApiUrl(API_ENDPOINTS.TEST_HEALTH)
    );

    // Test 3: Test de création de données (uniquement si l'endpoint dev fonctionne)
    let createTestResult = {
      status: 'error' as const,
      message: '⏭️ Ignoré (endpoint dev non disponible)',
      time: 0,
    };

    if (devHealthResult.status === 'success') {
      createTestResult = await testEndpoint(
        'createTestData',
        buildApiUrl(API_ENDPOINTS.DEV_CREATE_TEST_DATA('test-ruche-id')) + '?nombreJours=1&mesuresParJour=2',
        { method: 'POST' }
      );
    }

    setTests({
      devHealth: devHealthResult,
      mainHealth: mainHealthResult,
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
        <h3 className="text-lg font-medium text-gray-900">🔧 Diagnostic API</h3>
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
          <strong>API Base URL:</strong> {API_BASE_URL}
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.devHealth.status)}
          <div className="flex-1">
            <p className="font-medium">Endpoint de développement</p>
            <p className="text-sm text-gray-600">GET /dev/health</p>
            <p className="text-sm">{tests.devHealth.message}</p>
            {tests.devHealth.time > 0 && (
              <p className="text-xs text-gray-500">⏱️ {tests.devHealth.time}ms</p>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.mainHealth.status)}
          <div className="flex-1">
            <p className="font-medium">Endpoint principal de test</p>
            <p className="text-sm text-gray-600">GET /api/test/health</p>
            <p className="text-sm">{tests.mainHealth.message}</p>
            {tests.mainHealth.time > 0 && (
              <p className="text-xs text-gray-500">⏱️ {tests.mainHealth.time}ms</p>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
          {getStatusIcon(tests.createTestData.status)}
          <div className="flex-1">
            <p className="font-medium">Création de données de test</p>
            <p className="text-sm text-gray-600">POST /dev/create-test-data/:id</p>
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
            <li>Si l'endpoint de développement fonctionne, vous pouvez créer des données de test</li>
            <li>Si aucun endpoint ne fonctionne, vérifiez que l'API Spring Boot est démarrée</li>
            <li>En cas d'erreur 401, il y a un problème de configuration de sécurité Spring Boot</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default DiagnosticApi; 