import React from 'react';
import { Home, Box, BarChart3, Settings, AlertTriangle } from 'lucide-react';
import Logo from './Logo';

interface NavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

const Navigation: React.FC<NavigationProps> = ({ activeTab, onTabChange }) => {
  const tabs = [
    { id: 'ruchers', label: 'Ruchers', icon: Home },
    { id: 'ruches', label: 'Ruches', icon: Box },
    { id: 'statistiques', label: 'Statistiques', icon: BarChart3 },
    { id: 'test-api', label: 'Test API', icon: Settings },
    { id: 'test-alerte', label: 'Test Alerte', icon: AlertTriangle }
  ];

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200 mb-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between">
          {/* Logo à gauche */}
          <div className="flex-shrink-0">
            <Logo size="medium" variant="full" />
          </div>
          
          {/* Navigation au centre */}
          <div className="flex space-x-8">
            {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            
            return (
              <button
                key={tab.id}
                onClick={() => onTabChange(tab.id)}
                className={`flex items-center space-x-2 py-4 px-1 border-b-2 font-medium text-sm transition duration-200 ${
                  isActive
                    ? 'border-amber-500 text-amber-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Icon size={20} />
                <span>{tab.label}</span>
              </button>
            );
          })}
          </div>
          
          {/* Espace à droite pour équilibrer */}
          <div className="flex-shrink-0 w-32"></div>
        </div>
      </div>
    </nav>
  );
};

export default Navigation; 