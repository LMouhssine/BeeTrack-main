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

  // Icône SVG de ruche moderne avec design hexagonal
  const HiveIcon = () => (
    <svg
      className={`${currentSize.icon} text-amber-600`}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Ruche principale avec structure hexagonale */}
      <g fill="currentColor">
        {/* Base de la ruche */}
        <path d="M12 20L6 17L6 10L12 7L18 10L18 17L12 20Z" opacity="0.9"/>
        
        {/* Couches hexagonales */}
        <path d="M12 16L8 14L8 11L12 9L16 11L16 14L12 16Z" opacity="0.7"/>
        <path d="M12 13L10 12L10 10.5L12 9.5L14 10.5L14 12L12 13Z" opacity="0.5"/>
        
        {/* Toit de la ruche */}
        <path d="M12 7L8 5L12 3L16 5L12 7Z"/>
        
        {/* Entrée de la ruche */}
        <circle cx="12" cy="15" r="1" fill="currentColor" opacity="0.8"/>
        
        {/* Petits détails hexagonaux */}
        <polygon points="9,12 10,11.5 11,12 10,12.5" opacity="0.6"/>
        <polygon points="13,12 14,11.5 15,12 14,12.5" opacity="0.6"/>
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