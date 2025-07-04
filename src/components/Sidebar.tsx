import React, { useState } from 'react';
import { 
  Home, 
  Box, 
  BarChart3, 
  AlertTriangle, 
  LayoutDashboard,
  Hexagon,
  Activity,
  Settings
} from 'lucide-react';
import Logo from './Logo';

interface SidebarProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  isCollapsed: boolean;
  onToggleCollapse: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ 
  activeTab, 
  onTabChange, 
  isCollapsed,
  onToggleCollapse 
}) => {
  const [hoveredItem, setHoveredItem] = useState<string | null>(null);

  const menuSections = [
    {
      title: 'Tableau de bord',
      items: [
        { id: 'dashboard', label: 'Accueil', icon: LayoutDashboard, description: 'Vue d\'ensemble' }
      ]
    },
    {
      title: 'Gestion',
      items: [
        { id: 'ruchers', label: 'Ruchers', icon: Home, description: 'Gérer les ruchers' },
        { id: 'ruches', label: 'Ruches', icon: Hexagon, description: 'Surveiller les ruches' }
      ]
    },
    {
      title: 'Analyse',
      items: [
        { id: 'statistiques', label: 'Statistiques', icon: BarChart3, description: 'Données et graphiques' },
        { id: 'activity', label: 'Activité', icon: Activity, description: 'Historique des événements' }
      ]
    },
    {
      title: 'Outils',
      items: [
        { id: 'test-api', label: 'Test API', icon: Settings, description: 'Tests de connectivité' },
        { id: 'test-alerte', label: 'Test Alerte', icon: AlertTriangle, description: 'Tests d\'alertes' }
      ]
    }
  ];

  const bottomItems: any[] = [];

  return (
    <div className={`
      bg-white shadow-xl border-r border-amber-100 transition-all duration-500 ease-in-out
      ${isCollapsed ? 'w-16' : 'w-64'}
      h-screen flex flex-col relative z-30 main-scrollbar will-change-transform
      overflow-hidden
    `}>
      {/* Header avec logo */}
      <div className="px-1 py-2 border-b border-amber-100 bg-gradient-to-r from-amber-50 to-yellow-50">
        {!isCollapsed && (
          <div className="px-2 py-2">
            <Logo size="medium" variant="full" className="transition-all duration-500 ease-in-out" />
          </div>
        )}
        {isCollapsed && (
          <div className="flex items-center justify-center px-2 py-2">
            <Logo size="medium" variant="icon-only" className="transition-all duration-500 ease-in-out" />
          </div>
        )}
      </div>

      {/* Navigation principale */}
      <div className="flex-1 overflow-y-auto py-4 sidebar-scrollbar">
        {menuSections.map((section, sectionIndex) => (
          <div key={section.title} className={`mb-6 ${sectionIndex > 0 ? 'mt-8' : ''}`}>
            <div className={`transition-all duration-500 ease-in-out ${isCollapsed ? 'opacity-0 h-0 overflow-hidden' : 'opacity-100 h-auto'}`}>
              {!isCollapsed && (
                <h3 className="px-4 mb-2 text-xs font-semibold text-amber-700 uppercase tracking-wider">
                  {section.title}
                </h3>
              )}
            </div>
            
            <nav className="space-y-1 px-2">
              {section.items.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                const isHovered = hoveredItem === item.id;
                
                return (
                  <div key={item.id} className="relative">
                    <button
                      onClick={() => onTabChange(item.id)}
                      onMouseEnter={() => setHoveredItem(item.id)}
                      onMouseLeave={() => setHoveredItem(null)}
                      className={`
                        w-full flex items-center px-3 py-2.5 rounded-xl text-left transition-all-smooth will-change-transform
                        ${isActive 
                          ? 'bg-gradient-to-r from-amber-500 to-amber-600 text-white shadow-lg transform scale-105 animate-scale-in' 
                          : 'text-gray-700 hover:bg-amber-50 hover:text-amber-700 hover:scale-105 transition-colors-smooth'
                        }
                      `}
                    >
                      <Icon 
                        size={20} 
                        className={`
                          flex-shrink-0 transition-transform duration-200
                          ${isActive ? 'text-white' : 'text-amber-600'}
                          ${isHovered && !isActive ? 'scale-110' : ''}
                        `} 
                      />
                      
                      <div className={`ml-3 transition-all duration-500 ease-in-out overflow-hidden ${isCollapsed ? 'opacity-0 w-0' : 'opacity-100 w-auto'}`}>
                        {!isCollapsed && (
                          <span className={`font-medium transition-colors duration-200 ${
                            isActive ? 'text-white' : ''
                          }`}>
                            {item.label}
                          </span>
                        )}
                      </div>
                      
                      <div className={`ml-auto transition-all duration-500 ease-in-out ${isActive && !isCollapsed ? 'opacity-100 w-2' : 'opacity-0 w-0'}`}>
                        {isActive && !isCollapsed && (
                          <div className="w-2 h-2 bg-white rounded-full"></div>
                        )}
                      </div>
                    </button>
                    
                    {/* Tooltip pour mode collapsed */}
                    {isCollapsed && isHovered && (
                      <div className="fixed left-20 top-1/2 transform -translate-y-1/2 px-3 py-2 bg-gray-800 text-white text-sm rounded-lg shadow-lg z-50 whitespace-nowrap pointer-events-none">
                        <div className="font-medium">{item.label}</div>
                        <div className="text-xs text-gray-300">{item.description}</div>
                        <div className="absolute left-0 top-1/2 transform -translate-y-1/2 -translate-x-1 w-2 h-2 bg-gray-800 rotate-45"></div>
                      </div>
                    )}
                  </div>
                );
              })}
            </nav>
          </div>
        ))}
      </div>

      {/* Menu du bas - maintenant vide, les icônes sont dans le header */}
      {bottomItems.length > 0 && (
        <div className="border-t border-amber-100 p-2 bg-gradient-to-r from-amber-50 to-yellow-50">
          {bottomItems.map((item) => {
            const Icon = item.icon;
            const isHovered = hoveredItem === item.id;
            
            return (
              <div key={item.id} className="relative">
                <button
                  onMouseEnter={() => setHoveredItem(item.id)}
                  onMouseLeave={() => setHoveredItem(null)}
                  className="w-full flex items-center px-3 py-2 rounded-lg text-gray-600 hover:bg-amber-100 hover:text-amber-700 transition-all duration-200 mb-1"
                >
                  <Icon size={18} className="flex-shrink-0 text-amber-600" />
                  {!isCollapsed && (
                    <span className="ml-3 text-sm font-medium">{item.label}</span>
                  )}
                </button>
                
                {/* Tooltip pour mode collapsed */}
                {isCollapsed && isHovered && (
                  <div className="fixed left-20 top-1/2 transform -translate-y-1/2 px-3 py-2 bg-gray-800 text-white text-sm rounded-lg shadow-lg z-50 whitespace-nowrap pointer-events-none">
                    <div className="font-medium">{item.label}</div>
                    <div className="text-xs text-gray-300">{item.description}</div>
                    <div className="absolute left-0 top-1/2 transform -translate-y-1/2 -translate-x-1 w-2 h-2 bg-gray-800 rotate-45"></div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default Sidebar; 