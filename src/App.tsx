import React, { useState, useEffect } from 'react';
import { signInWithEmailAndPassword, onAuthStateChanged, signOut, User } from 'firebase/auth';
import { auth, db } from './firebase-config';
import { doc, getDoc } from 'firebase/firestore';
import { LogIn, LogOut, User as UserIcon, AlertTriangle, ChevronDown, Settings } from 'lucide-react';
import Navigation from './components/Navigation';
import RuchersList from './components/RuchersList';
import RuchesList from './components/RuchesList';
import RucheDetails from './components/RucheDetails';
import Statistiques from './components/Statistiques';
import TestDerniereMesure from './components/TestDerniereMesure';
import AlerteCouvercleModal from './components/AlerteCouvercleModal';
import NotificationToast from './components/NotificationToast';
import TestAlerteCouvercle from './components/TestAlerteCouvercle';
import { RucheService } from './services/rucheService';
import { useAlertesCouvercle } from './hooks/useAlertesCouvercle';
import { useNotifications } from './hooks/useNotifications';

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
  const [isUserDropdownOpen, setIsUserDropdownOpen] = useState(false);
  
  // État pour la navigation vers les détails des ruches
  const [selectedRucheId, setSelectedRucheId] = useState<string | null>(null);

  // Hooks pour les notifications et alertes
  const { notifications, addNotification, removeNotification } = useNotifications();
  const alertes = useAlertesCouvercle({
    apiculteurId: apiculteur?.id || '',
    onNotification: addNotification
  });
  
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

  // Fonctions de navigation pour les ruches
  const handleViewRucheDetails = (rucheId: string) => {
    setSelectedRucheId(rucheId);
    setActiveTab('ruches'); // S'assurer qu'on est sur l'onglet ruches
  };

  const handleBackToRuchesList = () => {
    setSelectedRucheId(null);
  };

  const handleDeleteRuche = async (rucheId: string) => {
    try {
      await RucheService.supprimerRuche(rucheId);
      console.log('🐝 Ruche supprimée:', rucheId);
      // Retourner à la liste après suppression
      setSelectedRucheId(null);
    } catch (error: any) {
      console.error('Erreur lors de la suppression:', error);
      alert('Erreur lors de la suppression: ' + error.message);
    }
  };

  // Fonction pour changer d'onglet et réinitialiser la navigation
  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    if (tab !== 'ruches') {
      setSelectedRucheId(null); // Réinitialiser la sélection de ruche si on change d'onglet
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
            
            {/* Menu utilisateur avec dropdown */}
            <div className="relative">
              <button
                onClick={() => setIsUserDropdownOpen(!isUserDropdownOpen)}
                className="flex items-center space-x-3 px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-lg border border-gray-200 transition-colors duration-200"
              >
                <div className="flex items-center justify-center w-8 h-8 bg-amber-100 rounded-full">
                  <UserIcon size={16} className="text-amber-600" />
                </div>
                <div className="text-left hidden sm:block">
                  <p className="text-sm font-medium text-gray-900">
                    {apiculteur ? `${apiculteur.prenom} ${apiculteur.nom}` : 'Utilisateur'}
                  </p>
                  <p className="text-xs text-gray-500 truncate max-w-32">
                    {user?.email}
                  </p>
                </div>
                <ChevronDown 
                  size={16} 
                  className={`text-gray-500 transition-transform duration-200 ${
                    isUserDropdownOpen ? 'rotate-180' : ''
                  }`}
                />
              </button>

              {/* Dropdown Menu */}
              {isUserDropdownOpen && (
                <div className="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-lg border border-gray-200 py-2 z-50">
                  {/* Info utilisateur */}
                  <div className="px-4 py-3 border-b border-gray-100">
                    <div className="flex items-center space-x-3">
                      <div className="flex items-center justify-center w-10 h-10 bg-amber-100 rounded-full">
                        <UserIcon size={20} className="text-amber-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold text-gray-900 truncate">
                          {apiculteur ? `${apiculteur.prenom} ${apiculteur.nom}` : 'Utilisateur'}
                        </p>
                        <p className="text-xs text-gray-500 truncate">{user?.email}</p>
                        {apiculteur?.role && (
                          <span className="inline-block mt-1 px-2 py-1 bg-amber-100 text-amber-700 text-xs rounded-full">
                            {apiculteur.role}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Menu Items */}
                  <div className="py-1">
                    <button className="w-full flex items-center space-x-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-200">
                      <UserIcon size={16} />
                      <span>Mon Profil</span>
                    </button>
                    <button className="w-full flex items-center space-x-3 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-200">
                      <Settings size={16} />
                      <span>Paramètres</span>
                    </button>
                    <hr className="my-1" />
                    <button
                      onClick={handleLogout}
                      className="w-full flex items-center space-x-3 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors duration-200"
                    >
                      <LogOut size={16} />
                      <span>Se déconnecter</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <Navigation activeTab={activeTab} onTabChange={handleTabChange} />

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-8">
        {activeTab === 'ruchers' && <RuchersList user={user} />}
        {activeTab === 'ruches' && !selectedRucheId && (
          <RuchesList onViewDetails={handleViewRucheDetails} />
        )}
        {activeTab === 'ruches' && selectedRucheId && (
          <RucheDetails 
            rucheId={selectedRucheId} 
            onBack={handleBackToRuchesList}
            onDelete={handleDeleteRuche}
          />
        )}
        {activeTab === 'statistiques' && <Statistiques />}
        {activeTab === 'test-api' && <TestDerniereMesure />}
        {activeTab === 'test-alerte' && <TestAlerteCouvercle />}
      </main>

      {/* Overlay pour fermer le dropdown */}
      {isUserDropdownOpen && (
        <div 
          className="fixed inset-0 z-40"
          onClick={() => setIsUserDropdownOpen(false)}
        />
      )}

      {/* Système d'alertes couvercle */}
      {alertes.alerteActive && (
        <AlerteCouvercleModal
          isOpen={true}
          rucheId={alertes.alerteActive.rucheId}
          rucheNom={alertes.alerteActive.rucheNom}
          mesure={alertes.alerteActive.mesure}
          onIgnorerTemporairement={alertes.ignorerAlerte}
          onIgnorerSession={alertes.ignorerPourSession}
          onFermer={alertes.fermerAlerte}
        />
      )}

      {/* Notifications toast */}
      {notifications.map(notification => (
        <NotificationToast
          key={notification.id}
          message={notification.message}
          type={notification.type}
          onClose={() => removeNotification(notification.id)}
          duration={notification.duration}
        />
      ))}
    </div>
  );
}

export default App;
