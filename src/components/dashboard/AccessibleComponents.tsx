import React, { useRef, useEffect } from 'react';

// Composant pour les annonces live aux lecteurs d'écran
export const LiveRegion: React.FC<{ 
  message: string; 
  priority?: 'polite' | 'assertive' | 'off';
  id?: string;
}> = ({ message, priority = 'polite', id = 'live-region' }) => {
  return (
    <div
      id={id}
      aria-live={priority}
      aria-atomic="true"
      className="sr-only"
      role="status"
    >
      {message}
    </div>
  );
};

// Hook pour gérer le focus au clavier
export const useFocusManagement = () => {
  const focusRef = useRef<HTMLElement | null>(null);

  const setFocus = (element: HTMLElement | null) => {
    if (element) {
      element.focus();
      focusRef.current = element;
    }
  };

  const restoreFocus = () => {
    if (focusRef.current) {
      focusRef.current.focus();
    }
  };

  return { setFocus, restoreFocus };
};

// Composant de bouton accessible
export const AccessibleButton: React.FC<{
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
  loading?: boolean;
  ariaLabel?: string;
  ariaDescribedBy?: string;
  className?: string;
  variant?: 'primary' | 'secondary' | 'danger';
}> = ({
  children,
  onClick,
  disabled = false,
  loading = false,
  ariaLabel,
  ariaDescribedBy,
  className = '',
  variant = 'primary'
}) => {
  const baseClasses = 'inline-flex items-center justify-center px-4 py-2 rounded-lg font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2';
  
  const variantClasses = {
    primary: 'bg-amber-600 text-white hover:bg-amber-700 focus:ring-amber-500 disabled:bg-gray-300',
    secondary: 'bg-gray-200 text-gray-700 hover:bg-gray-300 focus:ring-gray-500 disabled:bg-gray-100',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500 disabled:bg-gray-300'
  };

  return (
    <button
      type="button"
      className={`${baseClasses} ${variantClasses[variant]} ${className}`}
      onClick={onClick}
      disabled={disabled || loading}
      aria-label={ariaLabel}
      aria-describedby={ariaDescribedBy}
      aria-busy={loading}
    >
      {loading ? (
        <>
          <div className="animate-spin -ml-1 mr-2 h-4 w-4 border-2 border-white border-t-transparent rounded-full" />
          Chargement...
        </>
      ) : (
        children
      )}
    </button>
  );
};

// Composant de carte accessible
export const AccessibleCard: React.FC<{
  children: React.ReactNode;
  title?: string;
  description?: string;
  onClick?: () => void;
  className?: string;
  tabIndex?: number;
  role?: string;
}> = ({
  children,
  title,
  description,
  onClick,
  className = '',
  tabIndex,
  role = onClick ? 'button' : 'article'
}) => {
  const isInteractive = Boolean(onClick);
  
  const handleKeyDown = (event: React.KeyboardEvent) => {
    if (isInteractive && (event.key === 'Enter' || event.key === ' ')) {
      event.preventDefault();
      onClick?.();
    }
  };

  return (
    <div
      className={`${className} ${isInteractive ? 'cursor-pointer focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2' : ''}`}
      role={role}
      tabIndex={isInteractive ? (tabIndex ?? 0) : undefined}
      onClick={onClick}
      onKeyDown={handleKeyDown}
      aria-label={title}
      aria-describedby={description ? `${title}-description` : undefined}
    >
      {children}
      {description && (
        <span id={`${title}-description`} className="sr-only">
          {description}
        </span>
      )}
    </div>
  );
};

// Hook pour les raccourcis clavier
export const useKeyboardShortcuts = (shortcuts: { [key: string]: () => void }) => {
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      // Ignorer si l'utilisateur tape dans un champ de saisie
      if (event.target instanceof HTMLInputElement || 
          event.target instanceof HTMLTextAreaElement ||
          event.target instanceof HTMLSelectElement) {
        return;
      }

      const key = event.key.toLowerCase();
      const withCtrl = event.ctrlKey || event.metaKey;
      const withAlt = event.altKey;
      const withShift = event.shiftKey;

      // Construction de la clé de raccourci
      let shortcutKey = '';
      if (withCtrl) shortcutKey += 'ctrl+';
      if (withAlt) shortcutKey += 'alt+';
      if (withShift) shortcutKey += 'shift+';
      shortcutKey += key;

      if (shortcuts[shortcutKey]) {
        event.preventDefault();
        shortcuts[shortcutKey]();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [shortcuts]);
};

// Composant de navigation accessible
export const AccessibleNavigation: React.FC<{
  items: Array<{
    id: string;
    label: string;
    onClick: () => void;
    active?: boolean;
    disabled?: boolean;
  }>;
  ariaLabel?: string;
}> = ({ items, ariaLabel = 'Navigation principale' }) => {
  return (
    <nav aria-label={ariaLabel} role="navigation">
      <ul className="flex space-x-4" role="list">
        {items.map((item) => (
          <li key={item.id} role="listitem">
            <button
              type="button"
              className={`px-4 py-2 rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 ${
                item.active
                  ? 'bg-amber-600 text-white'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
              } ${item.disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
              onClick={item.onClick}
              disabled={item.disabled}
              aria-current={item.active ? 'page' : undefined}
            >
              {item.label}
            </button>
          </li>
        ))}
      </ul>
    </nav>
  );
};

// Composant de formulaire accessible
export const AccessibleFormField: React.FC<{
  label: string;
  id: string;
  type?: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  placeholder?: string;
  helpText?: string;
  className?: string;
}> = ({
  label,
  id,
  type = 'text',
  value,
  onChange,
  error,
  required = false,
  placeholder,
  helpText,
  className = ''
}) => {
  const errorId = `${id}-error`;
  const helpId = `${id}-help`;

  return (
    <div className={`space-y-2 ${className}`}>
      <label htmlFor={id} className="block text-sm font-medium text-gray-700">
        {label}
        {required && <span className="text-red-500 ml-1" aria-label="requis">*</span>}
      </label>
      
      <input
        type={type}
        id={id}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        required={required}
        aria-invalid={error ? 'true' : 'false'}
        aria-describedby={`${helpText ? helpId : ''} ${error ? errorId : ''}`.trim() || undefined}
        className={`block w-full px-3 py-2 border rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-amber-500 ${
          error
            ? 'border-red-300 bg-red-50'
            : 'border-gray-300 bg-white'
        }`}
      />
      
      {helpText && (
        <p id={helpId} className="text-sm text-gray-600">
          {helpText}
        </p>
      )}
      
      {error && (
        <p id={errorId} className="text-sm text-red-600" role="alert">
          {error}
        </p>
      )}
    </div>
  );
};

export default {
  LiveRegion,
  AccessibleButton,
  AccessibleCard,
  AccessibleNavigation,
  AccessibleFormField,
  useFocusManagement,
  useKeyboardShortcuts
}; 