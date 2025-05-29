import React, { useState, useEffect } from 'react';
import { signInWithEmailAndPassword, onAuthStateChanged, signOut, User } from 'firebase/auth';
import { auth, db } from './firebase-config';
import { doc, getDoc } from 'firebase/firestore';
import { LogIn, LogOut, User as UserIcon, AlertTriangle } from 'lucide-react';
import Navigation from './components/Navigation';
import RuchersList from './components/RuchersList';
import RuchesList from './components/RuchesList';
import Statistiques from './components/Statistiques';

interface Apiculteur {
  id: string;
  email: string;
  nom: string;
  prenom: string;
  identifiant?: string;
  role: string;
}

function App() {
  console.log('🐝 App component initializing...');
  
  const [user, setUser] = useState<User | null>(null);
  const [apiculteur, setApiculteur] = useState<Apiculteur | null>(null);
  const [loading, setLoading] = useState(true);
  const [loginLoading, setLoginLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('ruchers');
  
  console.log('🐝 App state initialized');

  useEffect(() => {
    console.log('🐝 Setting up auth listener...');
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setUser(user);
        try {
          // Récupérer les données de l'apiculteur depuis Firestore
          const apiculteurDoc = await getDoc(doc(db, 'apiculteurs', user.uid));
          if (apiculteurDoc.exists()) {
            setApiculteur({ id: user.uid, ...apiculteurDoc.data() } as Apiculteur);
          }
        } catch (error) {
          console.error('Erreur lors de la récupération des données utilisateur:', error);
        }
      } else {
        setUser(null);
        setApiculteur(null);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoginLoading(true);
    setError('');

    try {
      await signInWithEmailAndPassword(auth, email, password);
      setEmail('');
      setPassword('');
    } catch (error: any) {
      console.error('Erreur de connexion:', error);
      
      // Messages d'erreur en français, comme dans l'app mobile
      switch (error.code) {
        case 'auth/invalid-credential':
        case 'auth/wrong-password':
        case 'auth/user-not-found':
          setError('Les identifiants sont erronés.');
          break;
        case 'auth/invalid-email':
          setError('Format d\'email invalide.');
          break;
        case 'auth/too-many-requests':
          setError('Trop de tentatives. Réessayez plus tard.');
          break;
        default:
          setError('Erreur d\'authentification. Veuillez réessayer.');
      }
    } finally {
      setLoginLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Erreur lors de la déconnexion:', error);
    }
  };

  if (loading) {
    console.log('🐝 Rendering loading state...');
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 to-yellow-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mx-auto"></div>
          <p className="mt-4 text-amber-800">Chargement...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-50 to-yellow-100 flex items-center justify-center">
        <div className="max-w-md w-full mx-4">
          <div className="bg-white rounded-lg shadow-lg p-8">
            <div className="text-center mb-8">
              <h1 className="text-3xl font-bold text-amber-800 mb-2">🐝 Ruche Connectée</h1>
              <p className="text-gray-600">Application Web</p>
            </div>

            <form onSubmit={handleLogin} className="space-y-6">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                  Email
                </label>
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  required
                  placeholder="votre@email.com"
                />
              </div>

              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                  Mot de passe
                </label>
                <input
                  type="password"
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  required
                  placeholder="••••••••"
                />
              </div>

              {error && (
                <div className="flex items-center space-x-2 text-red-600 bg-red-50 p-3 rounded-md">
                  <AlertTriangle size={20} />
                  <span className="text-sm">{error}</span>
                </div>
              )}

              <button
                type="submit"
                disabled={loginLoading}
                className="w-full flex items-center justify-center space-x-2 bg-amber-600 hover:bg-amber-700 disabled:bg-amber-400 text-white font-medium py-2 px-4 rounded-md transition duration-200"
              >
                {loginLoading ? (
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                ) : (
                  <>
                    <LogIn size={20} />
                    <span>Se connecter</span>
                  </>
                )}
              </button>
            </form>

            <div className="mt-6 text-center text-sm text-gray-600">
              <p>Testez avec :</p>
              <p className="font-mono bg-gray-100 p-2 rounded mt-2">
                jean.dupont@email.com<br />
                Azerty123
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  console.log('🐝 Rendering main app...');
  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 to-yellow-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-amber-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <span className="text-2xl">🐝</span>
              <h1 className="text-xl font-bold text-amber-800">BeeTrack</h1>
            </div>
            
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2 text-gray-700">
                <UserIcon size={20} />
                <span className="font-medium">
                  {apiculteur ? `${apiculteur.prenom} ${apiculteur.nom}` : user.email}
                </span>
              </div>
              
              <button
                onClick={handleLogout}
                className="flex items-center space-x-1 text-red-600 hover:text-red-700 transition duration-200"
              >
                <LogOut size={20} />
                <span>Déconnexion</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <Navigation activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
        {activeTab === 'ruchers' && <RuchersList user={user} />}
        {activeTab === 'ruches' && <RuchesList />}
        {activeTab === 'statistiques' && <Statistiques />}
      </main>
    </div>
  );
}

export default App;
