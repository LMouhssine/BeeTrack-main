import React, { ReactNode } from 'react';

interface ResponsiveContainerProps {
  children: ReactNode;
  className?: string;
  mobileLayout?: 'stack' | 'scroll' | 'grid';
  breakpoints?: {
    mobile?: string;
    tablet?: string;
    desktop?: string;
  };
}

const ResponsiveContainer: React.FC<ResponsiveContainerProps> = ({
  children,
  className = '',
  mobileLayout = 'stack',
  breakpoints = {
    mobile: 'sm:',
    tablet: 'md:',
    desktop: 'lg:'
  }
}) => {
  const getMobileLayoutClasses = () => {
    switch (mobileLayout) {
      case 'scroll':
        return 'flex flex-col space-y-4 sm:space-y-0 sm:flex-row sm:space-x-4 overflow-x-auto';
      case 'grid':
        return 'grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3';
      case 'stack':
      default:
        return 'flex flex-col space-y-4';
    }
  };

  return (
    <div className={`w-full ${getMobileLayoutClasses()} ${className}`}>
      {children}
    </div>
  );
};

// Composant pour les sections qui doivent s'adapter différemment sur mobile
export const ResponsiveSection: React.FC<{
  children: ReactNode;
  mobileOrder?: number;
  tabletOrder?: number;
  desktopOrder?: number;
  className?: string;
  hiddenOn?: 'mobile' | 'tablet' | 'desktop'[];
}> = ({
  children,
  mobileOrder,
  tabletOrder,
  desktopOrder,
  className = '',
  hiddenOn = []
}) => {
  const getOrderClasses = () => {
    let classes = [];
    
    if (mobileOrder !== undefined) {
      classes.push(`order-${mobileOrder}`);
    }
    if (tabletOrder !== undefined) {
      classes.push(`md:order-${tabletOrder}`);
    }
    if (desktopOrder !== undefined) {
      classes.push(`lg:order-${desktopOrder}`);
    }
    
    return classes.join(' ');
  };

  const getHiddenClasses = () => {
    let classes = [];
    
    if (hiddenOn.includes('mobile')) {
      classes.push('hidden sm:block');
    }
    if (hiddenOn.includes('tablet')) {
      classes.push('sm:hidden lg:block');
    }
    if (hiddenOn.includes('desktop')) {
      classes.push('lg:hidden');
    }
    
    return classes.join(' ');
  };

  return (
    <div className={`${getOrderClasses()} ${getHiddenClasses()} ${className}`}>
      {children}
    </div>
  );
};

// Hook pour détecter la taille d'écran
export const useResponsive = () => {
  const [screenSize, setScreenSize] = React.useState<'mobile' | 'tablet' | 'desktop'>('desktop');

  React.useEffect(() => {
    const checkScreenSize = () => {
      if (window.innerWidth < 768) {
        setScreenSize('mobile');
      } else if (window.innerWidth < 1024) {
        setScreenSize('tablet');
      } else {
        setScreenSize('desktop');
      }
    };

    checkScreenSize();
    window.addEventListener('resize', checkScreenSize);
    
    return () => window.removeEventListener('resize', checkScreenSize);
  }, []);

  return {
    isMobile: screenSize === 'mobile',
    isTablet: screenSize === 'tablet',
    isDesktop: screenSize === 'desktop',
    screenSize
  };
};

export default ResponsiveContainer; 