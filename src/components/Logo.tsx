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
      icon: 'w-10 h-10',
      text: 'text-lg font-bold',
      container: 'gap-2.5'
    },
    medium: {
      icon: 'w-12 h-12',
      text: 'text-xl font-bold',
      container: 'gap-3'
    },
    large: {
      icon: 'w-20 h-20',
      text: 'text-4xl font-bold',
      container: 'gap-4'
    },
    'extra-large': {
      icon: 'w-24 h-24',
      text: 'text-6xl font-bold',
      container: 'gap-5'
    }
  };

  const currentSize = sizeClasses[size];

  // Logo simple et minimaliste - alignement parfait avec les boutons
  const SimpleIcon = () => (
    <div className="flex-shrink-0 flex items-center justify-center">
      <svg
        className={`${currentSize.icon} text-amber-600`}
        viewBox="0 0 24 24"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Hexagone simple */}
        <path
          d="M12 2L20 7v10l-8 5-8-5V7l8-5z"
          fill="currentColor"
        />
        
        {/* Point central pour symboliser l'abeille */}
        <circle cx="12" cy="12" r="3" fill="#FEF3C7" />
        
        {/* Lignes horizontales minimalistes */}
        <rect x="8" y="9" width="8" height="1.2" rx="0.6" fill="#FEF3C7"/>
        <rect x="8" y="13.8" width="8" height="1.2" rx="0.6" fill="#FEF3C7"/>
      </svg>
    </div>
  );

  if (variant === 'icon-only') {
    return (
      <div className={`flex items-center justify-center ${className}`}>
        <SimpleIcon />
      </div>
    );
  }

  if (variant === 'text-only') {
    return (
      <div className={`flex items-center ${className}`}>
        <span className={`${currentSize.text} font-bold tracking-wide text-amber-800 select-none`}>
          BeeTrack
        </span>
      </div>
    );
  }

  return (
    <div className={`flex items-center ${currentSize.container} ${className}`}>
      <SimpleIcon />
      <span className={`${currentSize.text} font-bold tracking-wide text-amber-800 select-none`}>
        BeeTrack
      </span>
    </div>
  );
};

export default Logo; 