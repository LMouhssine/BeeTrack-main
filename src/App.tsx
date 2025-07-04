import React, { useState, useEffect } from 'react';
import { signInWithEmailAndPassword, onAuthStateChanged, signOut, User } from 'firebase/auth';
import { auth, db } from './firebase-config';
import { doc, getDoc } from 'firebase/firestore';
import { LogIn, LogOut, User as UserIcon, AlertTriangle, ChevronDown, Settings, Menu, X, Bell, HelpCircle, ChevronLeft, ChevronRight } from 'lucide-react';
import Sidebar from './components/Sidebar';
import Dashboard from './components/Dashboard';
import RuchersList from './components/RuchersList';
import RuchesList from './components/RuchesList';
import RucheDetails from './components/RucheDetails';
import Statistiques from './components/Statistiques';
import TestDerniereMesure from './components/TestDerniereMesure';
import AlerteCouvercleModal from './components/AlerteCouvercleModal';
import NotificationToast from './components/NotificationToast';
import TestAlerteCouvercle from './components/TestAlerteCouvercle';
import Logo from './components/Logo';
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
  console.log('App component initializing...');
  
  const [user, setUser] = useState<User | null>(null);
  const [apiculteur, setApiculteur] = useState<Apiculteur | null>(null);
  const [loading, setLoading] = useState(true);
  const [loginLoading, setLoginLoading] = useState(false);
  const [email, setEmail] = useState(''); // Identifiants de connexion Firebase Auth
  const [password, setPassword] = useState(''); // Créez un compte dans la console Firebase
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isUserDropdownOpen, setIsUserDropdownOpen] = useState(false);
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);
  
  // État pour la navigation vers les détails des ruches
  const [selectedRucheId, setSelectedRucheId] = useState<string | null>(null);

  // Hooks pour les notifications et alertes
  const { notifications, addNotification, removeNotification } = useNotifications();
  const alertes = useAlertesCouvercle({
    apiculteurId: apiculteur?.id || '',
    onNotification: addNotification
  });
  
  console.log('App state initialized');

  useEffect(() => {
    console.log('Setting up auth listener...');
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
      console.log('Ruche supprimée:', rucheId);
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
    // Fermer la sidebar mobile lors du changement d'onglet
    setIsMobileSidebarOpen(false);
  };

  const toggleSidebarCollapse = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  const toggleMobileSidebar = () => {
    setIsMobileSidebarOpen(!isMobileSidebarOpen);
  };

  // Fonction pour rendre le contenu principal
  const renderMainContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard user={user} apiculteur={apiculteur} onNavigate={handleTabChange} />;
      case 'ruchers':
        return <RuchersList user={user} />;
      case 'ruches':
        if (selectedRucheId) {
          return (
            <RucheDetails 
              rucheId={selectedRucheId} 
              onBack={handleBackToRuchesList}
              onDelete={handleDeleteRuche}
            />
          );
        }
        return <RuchesList onViewDetails={handleViewRucheDetails} />;
      case 'statistiques':
        return <Statistiques />;
      case 'test-api':
        return <TestDerniereMesure />;
      case 'test-alerte':
        return <TestAlerteCouvercle />;
      default:
        return <Dashboard user={user} apiculteur={apiculteur} onNavigate={handleTabChange} />;
    }
  };

  if (loading) {
    console.log('Rendering loading state...');
    return (
      <div className="min-h-screen bg-gradient-to-br from-amber-600 to-amber-800 flex items-center justify-center">
        <div className="text-center">
          {/* Logo et titre alignés horizontalement */}
          <div className="animate-bounce mb-12">
            <div className="flex justify-center items-center animate-pulse">
              <Logo 
                size="extra-large" 
                variant="full"
                className="text-white [&>span]:text-white [&>svg]:text-white"
              />
            </div>
          </div>
          
          {/* Sous-titre */}
          <div className="animate-fade-in mb-12">
            <p className="text-white/80 text-xl">
              Gestion de ruches connectées
            </p>
          </div>
          
          {/* Indicateur de chargement */}
          <div className="flex justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-2 border-white border-t-transparent"></div>
          </div>
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
              <div className="flex justify-center mb-4">
                <Logo size="large" />
              </div>
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

  console.log('Rendering main app...');
  return (
    <div className="h-screen bg-gray-50 flex overflow-hidden">
      <style>{`
        body { overflow-x: hidden; }
      `}</style>
      {/* Sidebar pour desktop */}
      <div className="hidden lg:block">
        <Sidebar
          activeTab={activeTab}
          onTabChange={handleTabChange}
          isCollapsed={isSidebarCollapsed}
          onToggleCollapse={toggleSidebarCollapse}
        />
      </div>

      {/* Sidebar mobile overlay */}
      {isMobileSidebarOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="fixed inset-0 bg-black bg-opacity-50" onClick={toggleMobileSidebar} />
          <div className="relative w-64">
            <Sidebar
              activeTab={activeTab}
              onTabChange={handleTabChange}
              isCollapsed={false}
              onToggleCollapse={() => {}}
            />
            <button
              onClick={toggleMobileSidebar}
              className="absolute top-4 right-4 p-2 bg-white rounded-lg shadow-lg"
            >
              <X size={20} />
            </button>
          </div>
        </div>
      )}

      {/* Contenu principal */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header mobile */}
        <div className="lg:hidden bg-white shadow-sm border-b border-gray-200 px-4 py-2">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <button
                onClick={toggleMobileSidebar}
                className="p-2 rounded-lg bg-gray-100 hover:bg-gray-200 text-gray-700"
              >
                <Menu size={20} />
              </button>
            </div>
            
            <Logo size="small" variant="full" />
             
            {/* Icônes d'action mobile */}
            <div className="flex items-center space-x-1">
              <button className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth">
                <Bell size={18} />
              </button>
              <button className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth">
                <HelpCircle size={18} />
              </button>
              <button className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth">
                <Settings size={18} />
              </button>
               
              {/* Menu utilisateur mobile */}
              <div className="relative">
                <button
                  onClick={() => setIsUserDropdownOpen(!isUserDropdownOpen)}
                  className="flex items-center space-x-2 p-2 text-gray-700 hover:bg-gray-50 rounded-lg ml-2"
                >
                  <div className="flex items-center justify-center w-8 h-8 bg-amber-100 rounded-full">
                    <UserIcon size={16} className="text-amber-600" />
                  </div>
                  <ChevronDown 
                    size={16} 
                    className={`text-gray-500 transition-transform duration-200 ${
                      isUserDropdownOpen ? 'rotate-180' : ''
                    }`}
                  />
                </button>

                {/* Dropdown Menu Mobile */}
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
        </div>

        {/* Header desktop */}
        <div className="hidden lg:block bg-white shadow-sm border-b border-gray-200">
          <div className="px-6 py-3">
            <div className="flex items-center justify-between">
              {/* Bouton toggle sidebar */}
              <button
                onClick={toggleSidebarCollapse}
                className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth focus-ring-amber"
                title={isSidebarCollapsed ? "Étendre la sidebar" : "Réduire la sidebar"}
              >
                {isSidebarCollapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
              </button>
              
              <div className="flex items-center space-x-4">
                {/* Icônes d'action desktop */}
                <div className="flex items-center space-x-2">
                  <button 
                    className="relative p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth focus-ring-amber"
                    title="Notifications"
                  >
                    <Bell size={20} />
                    <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full text-xs"></span>
                  </button>
                  <button 
                    className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth focus-ring-amber"
                    title="Aide"
                  >
                    <HelpCircle size={20} />
                  </button>
                  <button 
                    className="p-2 text-gray-600 hover:text-amber-600 hover:bg-amber-50 rounded-lg transition-colors-smooth focus-ring-amber"
                    title="Paramètres"
                  >
                    <Settings size={20} />
                  </button>
                </div>
                
                {/* Séparateur */}
                <div className="h-8 w-px bg-gray-200"></div>
                
                {/* Menu utilisateur desktop */}
                <div className="relative">
                  <button
                    onClick={() => setIsUserDropdownOpen(!isUserDropdownOpen)}
                    className="flex items-center space-x-3 px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-lg border border-gray-200 transition-colors duration-200"
                  >
                    <div className="flex items-center justify-center w-8 h-8 bg-amber-100 rounded-full">
                      <UserIcon size={16} className="text-amber-600" />
                    </div>
                    <div className="text-left">
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

                  {/* Dropdown Menu Desktop */}
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
          </div>
        </div>

        {/* Contenu principal */}
        <main className="flex-1 overflow-y-auto bg-gray-50 main-scrollbar">
          {renderMainContent()}
        </main>
      </div>

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
