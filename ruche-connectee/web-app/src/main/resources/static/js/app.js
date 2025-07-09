/**
 * Application JavaScript moderne pour BeeTrack
 * Interface utilisateur moderne avec animations et interactions avancées
 */

// Configuration globale modernisée et améliorée
const BeeTrack = {
    config: {
        apiBase: '/api',
        refreshInterval: 30000,
        charts: {},
        sidebarId: 'sidebar',
        sidebarToggleId: 'sidebar-toggle',
        sidebarOverlayId: 'sidebar-overlay',
        notificationsContainerId: 'notifications',
        mainContentId: 'main-content',
        themes: {
            light: 'light',
            dark: 'dark'
        },
        animations: {
            duration: {
                fast: 150,
                normal: 300,
                slow: 500
            },
            easing: {
                smooth: 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
                bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
                elastic: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)'
            }
        },
        chartOptions: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                intersect: false,
                mode: 'index'
            },
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 20,
                        usePointStyle: true,
                        font: {
                            family: "'Inter', sans-serif",
                            size: 12
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    borderColor: '#f59e0b',
                    borderWidth: 1,
                    cornerRadius: 8,
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    padding: 12,
                    titleFont: {
                        size: 14,
                        weight: 'bold'
                    },
                    bodyFont: {
                        size: 12
                    }
                }
            },
            animations: {
                tension: {
                    duration: 1000,
                    easing: 'easeInOutElastic',
                    from: 1,
                    to: 0.4,
                    loop: false
                }
            }
        }
    },
    
    state: {
        currentPage: 'dashboard',
        currentTheme: localStorage.getItem('beetrack-theme') || 'light',
        sidebarCollapsed: localStorage.getItem('beetrack-sidebar-collapsed') === 'true',
        notifications: [],
        isSidebarOpen: window.innerWidth >= 768,
        charts: new Map(),
        eventListeners: new Map(),
        isOnline: navigator.onLine,
        lastUpdate: new Date(),
        touchDevice: 'ontouchstart' in window || navigator.maxTouchPoints > 0,
        reducedMotion: window.matchMedia('(prefers-reduced-motion: reduce)').matches,
        performance: {
            lastFrameTime: 0,
            fps: 60
        }
    },

    // Initialisation complète de l'application avec améliorations
    init: function() {
        console.log('🐝 BeeTrack Application initializing...');
        
        // Détection des préférences utilisateur
        this.detectUserPreferences();
        
        // Appliquer le thème sauvegardé
        this.applyTheme(this.state.currentTheme);
        
        // Initialiser tous les composants avec priorisation
        this.initThemeToggle();
        this.initSidebar();
        this.initNotifications();
        this.initModals();
        this.initCharts();
        this.initDataRefresh();
        this.initDropdowns();
        this.initFormValidation();
        this.initAccessibility();
        this.initAnimations();
        this.initServiceWorker();
        this.initKeyboardShortcuts();
        this.initScrollEffects();
        this.initNetworkStatus();
        this.initPerformanceMonitoring();
        this.initGestures();
        this.initLazyLoading();
        
        // Initialiser Lucide Icons avec optimisation
        this.initIcons();
        
        // Gestionnaires d'événements globaux
        this.bindGlobalEvents();
        
        // Précharger les ressources critiques
        this.preloadCriticalResources();
        
        // Marquer l'application comme initialisée
        document.body.classList.add('app-initialized');
        
        // Démarrer les animations d'entrée
        this.startEntranceAnimations();
        
        console.log('✅ BeeTrack Application initialized successfully');
        
        // Afficher un message de bienvenue en mode développement
        if (window.location.hostname === 'localhost') {
            console.log('%c🐝 BeeTrack Dev Mode', 'color: #f59e0b; font-size: 16px; font-weight: bold;');
            console.log('%cPerformance Mode:', this.state.reducedMotion ? 'Reduced Motion' : 'Full Animations');
        }
    },

    // Détection améliorée des préférences utilisateur
    detectUserPreferences: function() {
        // Détecter les préférences d'animation
        const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
        this.state.reducedMotion = reducedMotionQuery.matches;
        
        reducedMotionQuery.addListener((e) => {
            this.state.reducedMotion = e.matches;
            document.documentElement.setAttribute('data-reduced-motion', e.matches);
            console.log('Animation preference changed:', e.matches ? 'Reduced' : 'Full');
        });
        
        // Détecter les préférences de contraste
        const highContrastQuery = window.matchMedia('(prefers-contrast: high)');
        if (highContrastQuery.matches) {
            document.documentElement.setAttribute('data-high-contrast', 'true');
        }
        
        // Détecter les préférences de couleur
        const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
        if (!localStorage.getItem('beetrack-theme')) {
            this.state.currentTheme = darkModeQuery.matches ? 'dark' : 'light';
        }
        
        darkModeQuery.addListener((e) => {
            if (!localStorage.getItem('beetrack-theme')) {
                this.applyTheme(e.matches ? 'dark' : 'light');
            }
        });
    },

    // Système de thème moderne amélioré
    initThemeToggle: function() {
        // Créer le bouton de basculement du thème s'il n'existe pas
        if (!document.querySelector('.theme-toggle')) {
            const themeToggle = document.createElement('button');
            themeToggle.className = 'theme-toggle';
            themeToggle.innerHTML = '<i data-lucide="sun"></i>';
            themeToggle.setAttribute('aria-label', 'Basculer le thème');
            themeToggle.title = 'Basculer entre mode clair et sombre (Ctrl+D)';
            
            // Positioning amélioré
            Object.assign(themeToggle.style, {
                position: 'fixed',
                top: '20px',
                right: '20px',
                zIndex: '1000',
                background: 'var(--glass-bg)',
                backdropFilter: 'var(--glass-backdrop)',
                border: 'var(--glass-border)',
                borderRadius: 'var(--radius-full)',
                width: '48px',
                height: '48px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                transition: 'all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94)',
                boxShadow: 'var(--shadow-lg)'
            });
            
            document.body.appendChild(themeToggle);
            
            themeToggle.addEventListener('click', () => {
                this.toggleTheme();
            });
            
            // Animation d'entrée
            setTimeout(() => {
                themeToggle.style.transform = 'scale(1)';
                themeToggle.style.opacity = '1';
            }, 500);
        }
        
        // Écouter les changements de préférence système
        if (window.matchMedia) {
            const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
            mediaQuery.addListener(() => {
                if (!localStorage.getItem('beetrack-theme')) {
                    this.applyTheme(mediaQuery.matches ? 'dark' : 'light');
                }
            });
        }
    },

    toggleTheme: function() {
        const newTheme = this.state.currentTheme === 'light' ? 'dark' : 'light';
        this.applyTheme(newTheme);
        
        // Animation améliorée du bouton
        const toggle = document.querySelector('.theme-toggle');
        if (toggle) {
            // Animation de rotation avec rebond
            toggle.style.transform = 'scale(0.8) rotate(180deg)';
            
            setTimeout(() => {
                toggle.style.transform = 'scale(1.1)';
                setTimeout(() => {
                    toggle.style.transform = 'scale(1)';
                }, 150);
            }, 200);
        }
        
        // Effet de transition globale
        document.body.style.transition = 'background-color 0.5s ease, color 0.5s ease';
        
        // Notification améliorée du changement
        this.showNotification({
            type: 'info',
            message: `Mode ${newTheme === 'dark' ? 'sombre' : 'clair'} activé`,
            duration: 2000,
            icon: newTheme === 'dark' ? 'moon' : 'sun'
        });
        
        // Vibration légère sur les appareils compatibles
        if (navigator.vibrate && this.state.touchDevice) {
            navigator.vibrate(50);
        }
    },

    applyTheme: function(theme) {
        this.state.currentTheme = theme;
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('beetrack-theme', theme);
        
        // Mettre à jour l'icône du bouton avec animation
        const toggle = document.querySelector('.theme-toggle i');
        if (toggle) {
            // Animation de fondu lors du changement d'icône
            toggle.style.opacity = '0';
            toggle.style.transform = 'scale(0.8)';
            
            setTimeout(() => {
                toggle.setAttribute('data-lucide', theme === 'dark' ? 'moon' : 'sun');
                if (typeof lucide !== 'undefined') {
                    lucide.createIcons();
                }
                toggle.style.opacity = '1';
                toggle.style.transform = 'scale(1)';
            }, 150);
        }
        
        // Mettre à jour les graphiques si nécessaire
        this.updateChartsTheme();
        
        // Mettre à jour la couleur de la barre d'adresse mobile
        this.updateMetaThemeColor(theme);
    },

    updateMetaThemeColor: function(theme) {
        let metaTheme = document.querySelector('meta[name="theme-color"]');
        if (!metaTheme) {
            metaTheme = document.createElement('meta');
            metaTheme.name = 'theme-color';
            document.head.appendChild(metaTheme);
        }
        metaTheme.content = theme === 'dark' ? '#1e293b' : '#f59e0b';
    },

    updateChartsTheme: function() {
        const isDark = this.state.currentTheme === 'dark';
        this.state.charts.forEach(chart => {
            if (chart.options.scales) {
                const textColor = isDark ? '#e2e8f0' : '#334155';
                const gridColor = isDark ? '#475569' : '#e2e8f0';
                
                Object.keys(chart.options.scales).forEach(scaleKey => {
                    chart.options.scales[scaleKey].ticks.color = textColor;
                    chart.options.scales[scaleKey].grid.color = gridColor;
                });
                
                chart.update('none');
            }
        });
    },

    // Sidebar améliorée avec animations fluides et gestes
    initSidebar: function() {
        const sidebar = document.getElementById(this.config.sidebarId);
        const toggle = document.getElementById(this.config.sidebarToggleId);
        const overlay = document.getElementById(this.config.sidebarOverlayId);
        const mainContent = document.getElementById(this.config.mainContentId);

        if (!sidebar) return;

        // État initial basé sur la taille d'écran
        if (window.innerWidth < 768) {
            sidebar.classList.add('mobile-hidden');
            this.state.isSidebarOpen = false;
        }

        // Fonction de basculement améliorée
        const toggleSidebar = () => {
            const isMobile = window.innerWidth < 768;
            
            if (isMobile) {
                // Mode mobile - overlay
                const isVisible = sidebar.classList.contains('mobile-visible');
                
                if (isVisible) {
                    // Fermer
                    sidebar.classList.remove('mobile-visible');
                    overlay?.classList.remove('visible');
                    document.body.style.overflow = '';
                    this.state.isSidebarOpen = false;
                } else {
                    // Ouvrir
                    sidebar.classList.add('mobile-visible');
                    overlay?.classList.add('visible');
                    document.body.style.overflow = 'hidden';
                    this.state.isSidebarOpen = true;
                }
            } else {
                // Mode desktop - push/collapse
                const isCollapsed = sidebar.classList.contains('collapsed');
                
                if (isCollapsed) {
                    sidebar.classList.remove('collapsed');
                    mainContent?.classList.remove('sidebar-collapsed');
                    this.state.sidebarCollapsed = false;
                } else {
                    sidebar.classList.add('collapsed');
                    mainContent?.classList.add('sidebar-collapsed');
                    this.state.sidebarCollapsed = true;
                }
                
                localStorage.setItem('beetrack-sidebar-collapsed', this.state.sidebarCollapsed);
            }
            
            // Mise à jour de l'état du bouton
            if (toggle) {
                toggle.setAttribute('aria-expanded', this.state.isSidebarOpen);
            }
            
            // Vibration légère
            if (navigator.vibrate && this.state.touchDevice) {
                navigator.vibrate(30);
            }
        };

        // Gestionnaire de clic du bouton
        if (toggle) {
            toggle.addEventListener('click', (e) => {
                e.preventDefault();
                toggleSidebar();
            });
        }

        // Gestionnaire de clic sur l'overlay
        if (overlay) {
            overlay.addEventListener('click', () => {
                if (this.state.isSidebarOpen && window.innerWidth < 768) {
                    toggleSidebar();
                }
            });
        }

        // Gestion du redimensionnement avec debounce
        const handleResize = this.debounce(() => {
            const isMobile = window.innerWidth < 768;
            
            if (isMobile) {
                // Mode mobile
                sidebar.classList.remove('collapsed');
                sidebar.classList.add('mobile-hidden');
                mainContent?.classList.remove('sidebar-collapsed');
                overlay?.classList.remove('visible');
                document.body.style.overflow = '';
                this.state.isSidebarOpen = false;
            } else {
                // Mode desktop
                sidebar.classList.remove('mobile-hidden', 'mobile-visible');
                overlay?.classList.remove('visible');
                document.body.style.overflow = '';
                
                // Restaurer l'état de collapse
                if (this.state.sidebarCollapsed) {
                    sidebar.classList.add('collapsed');
                    mainContent?.classList.add('sidebar-collapsed');
                } else {
                    sidebar.classList.remove('collapsed');
                    mainContent?.classList.remove('sidebar-collapsed');
                }
            }
        }, 250);

        window.addEventListener('resize', handleResize);
        
        // Gestion des gestes de balayage pour mobile
        if (this.state.touchDevice) {
            this.initSidebarGestures(sidebar, toggleSidebar);
        }

        // Animation d'entrée du sidebar
        setTimeout(() => {
            sidebar.classList.add('sidebar-loaded');
        }, 100);
    },

    // Gestes tactiles pour la sidebar
    initSidebarGestures: function(sidebar, toggleFunction) {
        let touchStartX = 0;
        let touchStartY = 0;
        let touchEndX = 0;
        let touchEndY = 0;
        let isSwipeGesture = false;

        const minSwipeDistance = 50;
        const maxVerticalDistance = 100;

        document.addEventListener('touchstart', (e) => {
            touchStartX = e.changedTouches[0].screenX;
            touchStartY = e.changedTouches[0].screenY;
            isSwipeGesture = false;
        }, { passive: true });

        document.addEventListener('touchmove', (e) => {
            if (!isSwipeGesture) {
                const currentX = e.changedTouches[0].screenX;
                const deltaX = currentX - touchStartX;
                
                if (Math.abs(deltaX) > 10) {
                    isSwipeGesture = true;
                }
            }
        }, { passive: true });

        document.addEventListener('touchend', (e) => {
            touchEndX = e.changedTouches[0].screenX;
            touchEndY = e.changedTouches[0].screenY;

            if (isSwipeGesture) {
                this.handleSwipeGesture(touchStartX, touchStartY, touchEndX, touchEndY, toggleFunction);
            }
        }, { passive: true });
    },

    handleSwipeGesture: function(startX, startY, endX, endY, toggleFunction) {
        const deltaX = endX - startX;
        const deltaY = Math.abs(endY - startY);
        const distance = Math.abs(deltaX);
        
        const minSwipeDistance = 50;
        const maxVerticalDistance = 100;

        // Vérifier si c'est un balayage horizontal valide
        if (distance > minSwipeDistance && deltaY < maxVerticalDistance) {
            const isMobile = window.innerWidth < 768;
            const isFromEdge = startX < 50 || startX > window.innerWidth - 50;
            
            if (isMobile && isFromEdge) {
                if (deltaX > 0 && !this.state.isSidebarOpen) {
                    // Balayage vers la droite depuis le bord gauche - ouvrir
                    toggleFunction();
                } else if (deltaX < 0 && this.state.isSidebarOpen) {
                    // Balayage vers la gauche - fermer
                    toggleFunction();
                }
            }
        }
    },

    // Système de notifications amélioré
    initNotifications: function() {
        // Créer le conteneur s'il n'existe pas
        let container = document.getElementById(this.config.notificationsContainerId);
        if (!container) {
            container = document.createElement('div');
            container.id = this.config.notificationsContainerId;
            container.className = 'notifications-container';
            container.setAttribute('role', 'alert');
            container.setAttribute('aria-live', 'polite');
            
            // Positionnement amélioré
            Object.assign(container.style, {
                position: 'fixed',
                top: '20px',
                right: '20px',
                zIndex: '9999',
                maxWidth: '400px',
                width: '100%',
                pointerEvents: 'none'
            });
            
            document.body.appendChild(container);
        }

        // Gestionnaire de fermeture avec délégation d'événement
        container.addEventListener('click', (e) => {
            if (e.target.classList.contains('notification-close')) {
                const notification = e.target.closest('.notification');
                if (notification) {
                    this.hideNotification(notification);
                }
            }
        });
    },

    showNotification: function(options = {}) {
        const {
            type = 'info',
            message = '',
            title = '',
            duration = 5000,
            icon = null,
            persistent = false,
            actions = []
        } = options;

        const container = document.getElementById(this.config.notificationsContainerId);
        if (!container) return;

        // Créer l'élément notification
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.pointerEvents = 'all';
        
        // ID unique pour tracking
        const notificationId = `notification-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        notification.id = notificationId;

        // Contenu de la notification
        let notificationHTML = `
            <div class="notification-content">
                ${icon ? `<div class="notification-icon"><i data-lucide="${icon}"></i></div>` : ''}
                <div class="notification-text">
                    ${title ? `<div class="notification-title">${title}</div>` : ''}
                    <div class="notification-message">${message}</div>
                </div>
                ${!persistent ? '<button class="notification-close" aria-label="Fermer"><i data-lucide="x"></i></button>' : ''}
            </div>
        `;

        // Ajouter les actions si présentes
        if (actions.length > 0) {
            notificationHTML += '<div class="notification-actions">';
            actions.forEach(action => {
                notificationHTML += `<button class="notification-action" data-action="${action.id}">${action.label}</button>`;
            });
            notificationHTML += '</div>';
        }

        notification.innerHTML = notificationHTML;

        // Gestionnaires d'événements pour les actions
        if (actions.length > 0) {
            notification.addEventListener('click', (e) => {
                if (e.target.classList.contains('notification-action')) {
                    const actionId = e.target.getAttribute('data-action');
                    const action = actions.find(a => a.id === actionId);
                    if (action && action.callback) {
                        action.callback();
                    }
                    if (!persistent) {
                        this.hideNotification(notification);
                    }
                }
            });
        }

        // Ajouter au conteneur
        container.appendChild(notification);

        // Initialiser les icônes
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }

        // Animation d'entrée
        requestAnimationFrame(() => {
            notification.style.transform = 'translateX(0)';
            notification.style.opacity = '1';
        });

        // Stocker dans l'état
        this.state.notifications.push({
            id: notificationId,
            element: notification,
            type,
            timestamp: Date.now()
        });

        // Supprimer automatiquement après duration
        if (duration > 0 && !persistent) {
            setTimeout(() => {
                this.hideNotification(notification);
            }, duration);
        }

        // Vibration pour les notifications importantes
        if ((type === 'error' || type === 'warning') && navigator.vibrate && this.state.touchDevice) {
            navigator.vibrate([100, 50, 100]);
        }

        return notificationId;
    },

    hideNotification: function(notification) {
        if (!notification || !notification.parentNode) return;

        // Animation de sortie
        notification.style.transform = 'translateX(100%)';
        notification.style.opacity = '0';

        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
            
            // Retirer de l'état
            this.state.notifications = this.state.notifications.filter(
                n => n.element !== notification
            );
        }, this.config.animations.duration.normal);
    },

    // Initialisation améliorée des icônes
    initIcons: function() {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
            
            // Observer les changements DOM pour les nouvelles icônes
            const observer = new MutationObserver((mutations) => {
                let shouldUpdate = false;
                mutations.forEach((mutation) => {
                    if (mutation.type === 'childList') {
                        mutation.addedNodes.forEach((node) => {
                            if (node.nodeType === 1) { // Element node
                                if (node.querySelector && node.querySelector('[data-lucide]')) {
                                    shouldUpdate = true;
                                }
                            }
                        });
                    }
                });
                
                if (shouldUpdate) {
                    lucide.createIcons();
                }
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
        }
    },

    // Gestion améliorée des modales
    initModals: function() {
        // Gestionnaire global pour toutes les modales
        document.addEventListener('click', (e) => {
            // Ouvrir une modale
            if (e.target.hasAttribute('data-bs-toggle') && e.target.getAttribute('data-bs-toggle') === 'modal') {
                const modalId = e.target.getAttribute('data-bs-target');
                const modal = document.querySelector(modalId);
                if (modal) {
                    this.showModal(modal);
                }
            }
            
            // Fermer une modale
            if (e.target.classList.contains('modal-close') || e.target.closest('.modal-close')) {
                const modal = e.target.closest('.modal');
                if (modal) {
                    this.hideModal(modal);
                }
            }
            
            // Fermer en cliquant sur l'overlay
            if (e.target.classList.contains('modal')) {
                this.hideModal(e.target);
            }
        });

        // Fermer avec Escape
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                const openModal = document.querySelector('.modal.show');
                if (openModal) {
                    this.hideModal(openModal);
                }
            }
        });
    },

    showModal: function(modal) {
        modal.classList.add('show');
        modal.style.display = 'block';
        document.body.style.overflow = 'hidden';
        
        // Focus sur le premier élément focusable
        setTimeout(() => {
            const focusable = modal.querySelector('input, button, select, textarea, [tabindex]:not([tabindex="-1"])');
            if (focusable) {
                focusable.focus();
            }
        }, 100);
    },

    hideModal: function(modal) {
        modal.classList.remove('show');
        setTimeout(() => {
            modal.style.display = 'none';
            document.body.style.overflow = '';
        }, this.config.animations.duration.normal);
    },

    // Animations et microinteractions
    initAnimations: function() {
        // Observer d'intersection pour les animations d'entrée
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-in');
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);
        
        // Observer les éléments animables
        document.querySelectorAll('.card, .stat-card, .ruche-card').forEach(el => {
            observer.observe(el);
        });
        
        // Animation des boutons au clic
        document.addEventListener('click', (e) => {
            const button = e.target.closest('.btn');
            if (button && !button.disabled) {
                this.addRippleEffect(button, e);
            }
        });
        
        // Animation de chargement pour les formulaires
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function() {
                const submitBtn = this.querySelector('button[type="submit"]');
                if (submitBtn) {
                    submitBtn.innerHTML = '<i data-lucide="loader-2" class="animate-spin me-2"></i>Chargement...';
                    submitBtn.disabled = true;
                }
            });
        });
    },

    addRippleEffect: function(button, event) {
        const rect = button.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = event.clientX - rect.left - size / 2;
        const y = event.clientY - rect.top - size / 2;
        
        const ripple = document.createElement('span');
        ripple.style.cssText = `
            position: absolute;
            width: ${size}px;
            height: ${size}px;
            left: ${x}px;
            top: ${y}px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            transform: scale(0);
            animation: ripple 0.6s ease-out;
            pointer-events: none;
        `;
        
        button.style.position = 'relative';
        button.style.overflow = 'hidden';
        button.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    },

    // Gestion des raccourcis clavier
    initKeyboardShortcuts: function() {
        document.addEventListener('keydown', (e) => {
            // Ctrl/Cmd + K : Focus sur la recherche
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
                e.preventDefault();
                const searchInput = document.querySelector('#searchRuche, input[type="search"]');
                if (searchInput) {
                    searchInput.focus();
                }
            }
            
            // Ctrl/Cmd + D : Basculer le mode sombre
            if ((e.ctrlKey || e.metaKey) && e.key === 'd') {
                e.preventDefault();
                this.toggleTheme();
            }
            
            // Ctrl/Cmd + B : Basculer la sidebar
            if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
                e.preventDefault();
                const toggle = document.getElementById(this.config.sidebarToggleId);
                if (toggle) toggle.click();
            }
        });
    },

    // Effets de défilement
    initScrollEffects: function() {
        let lastScrollY = window.scrollY;
        const header = document.querySelector('.app-header');
        
        window.addEventListener('scroll', this.debounce(() => {
            const currentScrollY = window.scrollY;
            
            // Masquer/afficher le header selon le défilement
            if (header) {
                if (currentScrollY > lastScrollY && currentScrollY > 100) {
                    header.style.transform = 'translateY(-100%)';
                } else {
                    header.style.transform = 'translateY(0)';
                }
            }
            
            lastScrollY = currentScrollY;
        }, 10));
    },

    // Statut réseau
    initNetworkStatus: function() {
        const updateNetworkStatus = () => {
            this.state.isOnline = navigator.onLine;
            
            if (!this.state.isOnline) {
                this.showNotification({
                    type: 'warning',
                    message: 'Connexion internet perdue',
                    icon: 'wifi-off',
                    duration: 0
                });
            } else {
                // Masquer les notifications de déconnexion
                document.querySelectorAll('.alert-warning').forEach(alert => {
                    if (alert.textContent.includes('Connexion internet')) {
                        this.removeNotification(alert);
                    }
                });
            }
        };
        
        window.addEventListener('online', updateNetworkStatus);
        window.addEventListener('offline', updateNetworkStatus);
    },

    // Service Worker pour le cache
    initServiceWorker: function() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(registration => {
                    console.log('Service Worker enregistré:', registration);
                })
                .catch(error => {
                    console.log('Erreur Service Worker:', error);
                });
        }
    },

    // Gestion des dropdowns améliorée
    initDropdowns: function() {
        document.querySelectorAll('[data-dropdown]').forEach(trigger => {
            const menu = document.getElementById(trigger.dataset.dropdown);
            if (!menu) return;
            
            const toggleDropdown = (show) => {
                menu.classList.toggle('visible', show);
                trigger.setAttribute('aria-expanded', show);
                
                if (show) {
                    menu.style.animation = 'scaleIn 0.2s ease-out';
                    const closeOnClickOutside = (e) => {
                        if (!menu.contains(e.target) && !trigger.contains(e.target)) {
                            toggleDropdown(false);
                            document.removeEventListener('click', closeOnClickOutside);
                        }
                    };
                    setTimeout(() => document.addEventListener('click', closeOnClickOutside), 0);
                } else {
                    menu.style.animation = 'fadeOut 0.2s ease-out';
                }
            };
            
            trigger.addEventListener('click', (e) => {
                e.preventDefault();
                const isVisible = menu.classList.contains('visible');
                toggleDropdown(!isVisible);
            });
        });
    },

    // Validation de formulaires améliorée
    initFormValidation: function() {
        document.querySelectorAll('form').forEach(form => {
            const inputs = form.querySelectorAll('input, textarea, select');
            
            inputs.forEach(input => {
                input.addEventListener('blur', () => {
                    this.validateField(input);
                });
                
                input.addEventListener('input', () => {
                    if (input.classList.contains('is-invalid')) {
                        this.validateField(input);
                    }
                });
            });
        });
    },

    validateField: function(field) {
        const isValid = field.checkValidity();
        field.classList.toggle('is-valid', isValid);
        field.classList.toggle('is-invalid', !isValid);
        
        // Animation de feedback
        if (!isValid) {
            field.style.animation = 'shake 0.5s ease-in-out';
            setTimeout(() => {
                field.style.animation = '';
            }, 500);
        }
    },

    // Accessibilité améliorée
    initAccessibility: function() {
        // Gestion du focus visible
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Tab') {
                document.body.classList.add('keyboard-navigation');
            }
        });
        
        document.addEventListener('mousedown', () => {
            document.body.classList.remove('keyboard-navigation');
        });
        
        // Annonces pour les lecteurs d'écran
        this.createAriaLiveRegion();
    },

    createAriaLiveRegion: function() {
        const liveRegion = document.createElement('div');
        liveRegion.setAttribute('aria-live', 'polite');
        liveRegion.setAttribute('aria-atomic', 'true');
        liveRegion.className = 'sr-only';
        liveRegion.id = 'aria-live-region';
        document.body.appendChild(liveRegion);
    },

    announceToScreenReader: function(message) {
        const liveRegion = document.getElementById('aria-live-region');
        if (liveRegion) {
            liveRegion.textContent = message;
        }
    },

    // Gestionnaires d'événements globaux
    bindGlobalEvents: function() {
        // Redimensionnement avec debounce
        window.addEventListener('resize', this.debounce(() => {
            this.handleResize();
        }, 250));
        
        // Gestion de la visibilité de la page
        document.addEventListener('visibilitychange', () => {
            if (document.hidden) {
                console.log('Application mise en pause');
            } else {
                console.log('Application reprise');
                this.refreshData();
            }
        });
        
        // Nettoyage lors du déchargement
        window.addEventListener('beforeunload', () => {
            this.cleanup();
        });
    },

    handleResize: function() {
        this.state.charts.forEach(chart => {
            chart.resize();
        });
        
        // Ajuster la sidebar sur mobile
        if (window.innerWidth >= 768 && this.state.isSidebarOpen) {
            document.body.style.overflow = '';
            const overlay = document.getElementById(this.config.sidebarOverlayId);
            overlay?.classList.remove('visible');
        }
    },

    cleanup: function() {
        // Nettoyer les graphiques
        this.state.charts.forEach(chart => {
            chart.destroy();
        });
        this.state.charts.clear();
        
        // Nettoyer les écouteurs d'événements
        this.state.eventListeners.forEach((listener, element) => {
            element.removeEventListener(listener.type, listener.handler);
        });
        this.state.eventListeners.clear();
        
        console.log('🧹 BeeTrack Application cleaned up');
    },

    // Utilitaires
    debounce: function(func, wait, immediate) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                timeout = null;
                if (!immediate) func(...args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func(...args);
        };
    },

    throttle: function(func, limit) {
        let inThrottle;
        return function(...args) {
            if (!inThrottle) {
                func.apply(this, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        };
    },

    // ... existing code ...
};

// Styles CSS pour les animations en JavaScript
const styleSheet = document.createElement('style');
styleSheet.textContent = `
    @keyframes ripple {
        to {
            transform: scale(2);
            opacity: 0;
        }
    }
    
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-2px); }
        20%, 40%, 60%, 80% { transform: translateX(2px); }
    }
    
    @keyframes fadeOut {
        from { opacity: 1; transform: translateY(0); }
        to { opacity: 0; transform: translateY(-10px); }
    }
    
    .animate-spin {
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
    
    .animate-in {
        animation: fadeIn 0.6s ease-out;
    }
    
    .keyboard-navigation *:focus {
        outline: 2px solid #f59e0b !important;
        outline-offset: 2px !important;
    }
    
    .sr-only {
        position: absolute !important;
        width: 1px !important;
        height: 1px !important;
        padding: 0 !important;
        margin: -1px !important;
        overflow: hidden !important;
        clip: rect(0, 0, 0, 0) !important;
        white-space: nowrap !important;
        border: 0 !important;
    }
`;
document.head.appendChild(styleSheet);

// Auto-initialisation quand le DOM est prêt
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => BeeTrack.init());
} else {
    BeeTrack.init();
}
