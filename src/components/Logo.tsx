import React from 'react';

interface LogoProps {
  size?: 'small' | 'medium' | 'large' | 'extra-large';
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
      icon: 'w-8 h-8',
      text: 'text-lg font-bold',
      container: 'gap-2'
    },
    medium: {
      icon: 'w-12 h-12',
      text: 'text-2xl font-bold',
      container: 'gap-3'
    },
    large: {
      icon: 'w-20 h-20',
      text: 'text-5xl font-bold',
      container: 'gap-6'
    },
    'extra-large': {
      icon: 'w-32 h-32',
      text: 'text-7xl font-bold',
      container: 'gap-8'
    }
  };

  const currentSize = sizeClasses[size];

  // Logo professionnel avec abeille stylisée dans hexagone
  const HiveIcon = () => (
    <svg
      className={`${currentSize.icon} text-amber-600`}
      viewBox="0 0 100 100"
      fill="currentColor"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Hexagone de fond */}
      <path
        d="M25 25.98L50 10.98L75 25.98L75 59.02L50 74.02L25 59.02Z"
        fill="currentColor"
        stroke="none"
      />
      
      {/* Abeille stylisée */}
      <g fill="#FCD34D" stroke="none">
        {/* Corps principal de l'abeille */}
        <ellipse cx="50" cy="50" rx="8" ry="14" />
        
        {/* Rayures sur le corps */}
        <rect x="44" y="42" width="12" height="2.5" rx="1" fill="#1F2937"/>
        <rect x="44" y="47" width="12" height="2.5" rx="1" fill="#1F2937"/>
        <rect x="44" y="52" width="12" height="2.5" rx="1" fill="#1F2937"/>
        <rect x="44" y="57" width="12" height="2.5" rx="1" fill="#1F2937"/>
        
        {/* Tête */}
        <circle cx="50" cy="35" r="5"/>
        
        {/* Antennes */}
        <line x1="47" y1="32" x2="45" y2="28" stroke="#1F2937" strokeWidth="1.5" strokeLinecap="round"/>
        <line x1="53" y1="32" x2="55" y2="28" stroke="#1F2937" strokeWidth="1.5" strokeLinecap="round"/>
        <circle cx="45" cy="28" r="1.5" fill="#1F2937"/>
        <circle cx="55" cy="28" r="1.5" fill="#1F2937"/>
        
        {/* Aile gauche */}
        <ellipse cx="40" cy="45" rx="6" ry="10" transform="rotate(-20 40 45)" opacity="0.7"/>
        
        {/* Aile droite */}
        <ellipse cx="60" cy="45" rx="6" ry="10" transform="rotate(20 60 45)" opacity="0.7"/>
        
        {/* Détails des ailes */}
        <path d="M38 40 Q42 38 44 42 Q42 46 38 44" fill="#1F2937" opacity="0.3"/>
        <path d="M62 40 Q58 38 56 42 Q58 46 62 44" fill="#1F2937" opacity="0.3"/>
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