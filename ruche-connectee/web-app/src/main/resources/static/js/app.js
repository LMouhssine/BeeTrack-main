/**
 * BeeTrack - Application JavaScript moderne et professionnelle
 * Gestion de l'interface utilisateur et des interactions
 */

const BeeTrack = {
    // Configuration de l'application
    config: {
        refreshInterval: 30000, // 30 secondes
        animationDuration: 300,
        chartOptions: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.1)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    },

    // État de l'application
    state: {
        sidebarCollapsed: false,
        charts: new Map(),
        notifications: [],
        currentTheme: 'light'
    },

    // Initialisation de l'application
    init() {
        console.log('🚀 Initialisation de BeeTrack...');
        
        this.initSidebar();
        this.initNotifications();
        this.initAnimations();
        this.initKeyboardShortcuts();
        this.initAutoRefresh();
        
        console.log('✅ BeeTrack initialisé avec succès');
    },

    // Gestion de la sidebar
    initSidebar() {
        const sidebar = document.getElementById('sidebar');
        const sidebarToggle = document.getElementById('sidebar-toggle');
        const overlay = document.getElementById('sidebar-overlay');
        const mainContent = document.querySelector('.main-content');

        if (!sidebar || !sidebarToggle) return;

        // Toggle sidebar sur mobile
        sidebarToggle.addEventListener('click', () => {
            const isVisible = sidebar.classList.contains('mobile-visible');
            
            if (isVisible) {
                this.hideSidebar();
            } else {
                this.showSidebar();
            }
        });

        // Fermer sidebar en cliquant sur l'overlay
        if (overlay) {
            overlay.addEventListener('click', () => {
                this.hideSidebar();
            });
        }

        // Gestion du responsive
        this.handleResponsiveSidebar();
        window.addEventListener('resize', () => {
            this.handleResponsiveSidebar();
        });
    },

    showSidebar() {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');
        
        if (sidebar) {
            sidebar.classList.add('mobile-visible');
        }
        
        if (overlay) {
            overlay.classList.add('visible');
        }
        
        // Mettre à jour l'état du bouton
        const toggle = document.getElementById('sidebar-toggle');
        if (toggle) {
            toggle.setAttribute('aria-expanded', 'true');
        }
    },

    hideSidebar() {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');
        
        if (sidebar) {
            sidebar.classList.remove('mobile-visible');
        }
        
        if (overlay) {
            overlay.classList.remove('visible');
        }
        
        // Mettre à jour l'état du bouton
        const toggle = document.getElementById('sidebar-toggle');
        if (toggle) {
            toggle.setAttribute('aria-expanded', 'false');
        }
    },

    handleResponsiveSidebar() {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.querySelector('.main-content');
        
        if (!sidebar || !mainContent) return;

        if (window.innerWidth <= 768) {
            // Mode mobile
            sidebar.classList.remove('collapsed');
            mainContent.classList.remove('sidebar-collapsed');
        } else {
            // Mode desktop
            if (this.state.sidebarCollapsed) {
                sidebar.classList.add('collapsed');
                mainContent.classList.add('sidebar-collapsed');
            }
        }
    },

    // Gestion des notifications
    initNotifications() {
        // Fermer les alertes
        document.querySelectorAll('.alert .close').forEach(closeBtn => {
            closeBtn.addEventListener('click', (e) => {
                const alert = e.target.closest('.alert');
                if (alert) {
                    this.hideNotification(alert);
                }
            });
        });

        // Auto-hide des notifications après 5 secondes
        document.querySelectorAll('.alert').forEach(alert => {
            setTimeout(() => {
                this.hideNotification(alert);
            }, 5000);
        });
    },

    hideNotification(alert) {
        alert.style.opacity = '0';
        alert.style.transform = 'translateX(100%)';
        
        setTimeout(() => {
            alert.remove();
        }, 300);
    },

    showNotification(options = {}) {
        const {
            type = 'info',
            message = 'Notification',
            icon = 'info',
            duration = 5000
        } = options;

        const notification = document.createElement('div');
        notification.className = `alert alert-${type} fade-in`;
        notification.innerHTML = `
            <div class="alert-content">
                <i data-lucide="${icon}" class="alert-icon" aria-hidden="true"></i>
                <span>${message}</span>
            </div>
            <button type="button" class="close" aria-label="Fermer">
                <i data-lucide="x" aria-hidden="true"></i>
            </button>
        `;

        // Ajouter au container de notifications
        const container = document.getElementById('notifications');
        if (container) {
            container.appendChild(notification);
        }

        // Initialiser les icônes Lucide
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }

        // Auto-hide
        setTimeout(() => {
            this.hideNotification(notification);
        }, duration);

        // Gestion du bouton de fermeture
        const closeBtn = notification.querySelector('.close');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => {
                this.hideNotification(notification);
            });
        }
    },

    // Animations et transitions
    initAnimations() {
        // Animation des cartes au scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-in');
                }
            });
        }, observerOptions);

        // Observer les éléments avec animation
        document.querySelectorAll('.card, .stat-card').forEach(el => {
            observer.observe(el);
        });

        // Animation des compteurs
        this.animateCounters();
    },

    animateCounters() {
        const counters = document.querySelectorAll('[data-stat]');
        
        counters.forEach(counter => {
            const finalValue = parseInt(counter.textContent) || 0;
            this.animateCounter(counter, 0, finalValue, 1000);
        });
    },

    animateCounter(element, start, end, duration) {
        const range = end - start;
        const increment = range / (duration / 16);
        let current = start;
        
        const timer = setInterval(() => {
            current += increment;
            if (current >= end) {
                current = end;
                clearInterval(timer);
            }
            element.textContent = Math.floor(current);
        }, 16);
    },

    // Raccourcis clavier
    initKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Ctrl/Cmd + N : Nouvelle ruche
            if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
                e.preventDefault();
                window.location.href = '/ruches/nouvelle';
            }

            // F5 : Actualiser
            if (e.key === 'F5') {
                e.preventDefault();
                this.refreshData();
            }

            // Échap : Fermer sidebar sur mobile
            if (e.key === 'Escape') {
                this.hideSidebar();
            }
        });
    },

    // Actualisation automatique
    initAutoRefresh() {
        setInterval(() => {
            this.refreshData();
        }, this.config.refreshInterval);
    },

    refreshData() {
        console.log('🔄 Actualisation des données...');
        
        // Actualiser les statistiques
        this.updateStats();
        
        // Actualiser les notifications
        this.updateNotifications();
        
        // Montrer une notification de succès
        this.showNotification({
            type: 'success',
            message: 'Données actualisées',
            icon: 'check-circle',
            duration: 2000
        });
    },

    updateStats() {
        // Simuler une mise à jour des statistiques
        const statElements = document.querySelectorAll('[data-stat]');
        
        statElements.forEach(stat => {
            const currentValue = parseInt(stat.textContent) || 0;
            const newValue = currentValue + Math.floor(Math.random() * 3);
            
            this.animateCounter(stat, currentValue, newValue, 500);
        });
    },

    updateNotifications() {
        // Simuler une mise à jour des notifications
        const notificationCount = document.querySelector('.notification-badge');
        if (notificationCount) {
            const currentCount = parseInt(notificationCount.textContent) || 0;
            const newCount = Math.max(0, currentCount + Math.floor(Math.random() * 3) - 1);
            
            if (newCount > 0) {
                notificationCount.textContent = newCount;
                notificationCount.style.display = 'flex';
            } else {
                notificationCount.style.display = 'none';
            }
        }
    },

    // Utilitaires
    formatNumber(num) {
        return new Intl.NumberFormat('fr-FR').format(num);
    },

    formatDate(date) {
        return new Intl.DateTimeFormat('fr-FR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        }).format(new Date(date));
    },

    // Gestion des erreurs
    handleError(error, context = '') {
        console.error(`❌ Erreur BeeTrack${context ? ` (${context})` : ''}:`, error);
        
        this.showNotification({
            type: 'danger',
            message: 'Une erreur s\'est produite',
            icon: 'alert-circle',
            duration: 5000
        });
    },

    // API helpers
    async apiCall(url, options = {}) {
        try {
            const response = await fetch(url, {
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                },
                ...options
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return await response.json();
        } catch (error) {
            this.handleError(error, 'API Call');
            throw error;
        }
    },

    // Actions spécifiques
    refreshActions() {
        this.showNotification({
            type: 'info',
            message: 'Actualisation des actions...',
            icon: 'refresh-cw',
            duration: 2000
        });
    },

    refreshRuche(rucheId) {
        this.showNotification({
            type: 'info',
            message: `Actualisation de la ruche ${rucheId}...`,
            icon: 'refresh-cw',
            duration: 2000
        });
    }
};

// Export pour utilisation globale
window.BeeTrack = BeeTrack;

// Initialisation automatique quand le DOM est prêt
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        BeeTrack.init();
    });
} else {
    BeeTrack.init();
}
