import React from 'react';

interface LogoProps {
  size?: 'small' | 'medium' | 'large';
  variant?: 'full' | 'icon-only' | 'text-only';
  className?: string;
}

const Logo: React.FC<LogoProps> = ({ 
  size = 'medium', 
  variant = 'full',
  className = '' 
}) => {
  const sizeClasses = {
    small: {
      icon: 'w-6 h-6',
      text: 'text-lg font-bold',
      container: 'gap-2'
    },
    medium: {
      icon: 'w-8 h-8',
      text: 'text-xl font-bold',
      container: 'gap-3'
    },
    large: {
      icon: 'w-16 h-16',
      text: 'text-4xl font-bold',
      container: 'gap-4'
    }
  };

  const currentSize = sizeClasses[size];

  // Icône SVG de ruche identique à Icons.hive de Flutter
  const HiveIcon = () => (
    <svg
      className={`${currentSize.icon} text-amber-600`}
      viewBox="0 0 24 24"
      fill="currentColor"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Ruche traditionnelle avec couches empilées comme Icons.hive */}
      <g>
        {/* Toit pointu de la ruche */}
        <path d="M12 2L8 6h8l-4-4z"/>
        
        {/* Couches de la ruche empilées */}
        <rect x="7" y="6" width="10" height="2.5" rx="1"/>
        <rect x="6.5" y="8.5" width="11" height="2.5" rx="1"/>
        <rect x="6" y="11" width="12" height="2.5" rx="1"/>
        <rect x="6.5" y="13.5" width="11" height="2.5" rx="1"/>
        <rect x="7" y="16" width="10" height="2.5" rx="1"/>
        <rect x="7.5" y="18.5" width="9" height="2.5" rx="1"/>
        
        {/* Petite entrée au centre */}
        <circle cx="12" cy="15" r="0.8"/>
        
        {/* Lignes de texture sur les couches */}
        <line x1="8" y1="7.25" x2="16" y2="7.25" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
        <line x1="7.5" y1="9.75" x2="16.5" y2="9.75" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
        <line x1="7" y1="12.25" x2="17" y2="12.25" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
        <line x1="7.5" y1="14.75" x2="16.5" y2="14.75" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
        <line x1="8" y1="17.25" x2="16" y2="17.25" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
        <line x1="8.5" y1="19.75" x2="15.5" y2="19.75" stroke="currentColor" strokeWidth="0.3" opacity="0.6"/>
      </g>
    </svg>
  );

  if (variant === 'icon-only') {
    return (
      <div className={`flex items-center ${className}`}>
        <HiveIcon />
      </div>
    );
  }

  if (variant === 'text-only') {
    return (
      <div className={`flex items-center ${className}`}>
        <span className={`${currentSize.text} text-amber-800 font-mono tracking-wider`}>
          BEETRACK
        </span>
      </div>
    );
  }

  return (
    <div className={`flex items-center ${currentSize.container} ${className}`}>
      <HiveIcon />
      <span className={`${currentSize.text} text-amber-800 font-mono tracking-wider`}>
        BEETRACK
      </span>
    </div>
  );
};

export default Logo; 