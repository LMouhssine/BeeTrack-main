/**
 * Application JavaScript pour BeeTrack - Remplace les fonctionnalités React
 * Compatible avec les templates Thymeleaf
 */

// Configuration globale
const BeeTrack = {
    config: {
        apiBase: '/api',
        refreshInterval: 30000, // 30 secondes
        charts: {},
        sidebarId: 'sidebar',
        sidebarToggleId: 'sidebar-toggle',
        sidebarOverlayId: 'sidebar-overlay',
        notificationsContainerId: 'notifications',
        mainContentId: 'main-content',
        chartOptions: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    },
    
    // État global de l'application
    state: {
        currentPage: 'dashboard',
        sidebarCollapsed: false,
        notifications: [],
        isSidebarOpen: window.innerWidth >= 768,
        charts: new Map(),
        eventListeners: new Map()
    },

    // Initialisation de l'application
    init: function() {
        console.log('🐝 BeeTrack Application initializing...');
        
        // Initialiser les composants
        this.initSidebar();
        this.initNotifications();
        this.initModals();
        this.initCharts();
        this.initDataRefresh();
        this.initDropdowns();
        this.initFormValidation();
        this.initAccessibility();
        
        // Initialiser Lucide Icons
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        
        // Gestionnaire de redimensionnement avec debounce
        window.addEventListener('resize', this.debounce(() => {
            this.handleResize();
        }, 250));
        
        // Nettoyage lors du déchargement de la page
        window.addEventListener('unload', () => {
            this.cleanup();
        });
        
        console.log('✅ BeeTrack Application initialized');
    },

    // Gestion de la sidebar
    initSidebar: function() {
        const sidebar = document.getElementById(this.config.sidebarId);
        const toggle = document.getElementById(this.config.sidebarToggleId);
        const overlay = document.getElementById(this.config.sidebarOverlayId);
        
        if (!sidebar || !toggle) return;
        
        const toggleSidebar = () => {
            this.state.isSidebarOpen = !this.state.isSidebarOpen;
            sidebar.classList.toggle('mobile-visible', this.state.isSidebarOpen);
            overlay.classList.toggle('visible', this.state.isSidebarOpen);
            toggle.setAttribute('aria-expanded', this.state.isSidebarOpen);
            
            if (this.state.isSidebarOpen) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        };
        
        toggle.addEventListener('click', toggleSidebar);
        overlay.addEventListener('click', () => {
            if (this.state.isSidebarOpen) toggleSidebar();
        });
        
        // Gestion des touches clavier
        sidebar.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.state.isSidebarOpen) {
                toggleSidebar();
            }
        });
    },

    // Système de notifications
    initNotifications: function() {
        const container = document.getElementById(this.config.notificationsContainerId);
        if (!container) return;
        
        // Fermeture des notifications
        container.addEventListener('click', (e) => {
            if (e.target.closest('.close')) {
                const notification = e.target.closest('.alert');
                this.removeWithAnimation(notification);
            }
        });
    },

    // Gestion des dropdowns
    initDropdowns: function() {
        document.querySelectorAll('[data-dropdown]').forEach(trigger => {
            const menu = document.getElementById(trigger.dataset.dropdown);
            if (!menu) return;
            
            const toggleDropdown = (show) => {
                menu.classList.toggle('visible', show);
                trigger.setAttribute('aria-expanded', show);
                
                if (show) {
                    const closeOnClickOutside = (e) => {
                        if (!menu.contains(e.target) && !trigger.contains(e.target)) {
                            toggleDropdown(false);
                            document.removeEventListener('click', closeOnClickOutside);
                        }
                    };
                    document.addEventListener('click', closeOnClickOutside);
                }
            };
            
            trigger.addEventListener('click', (e) => {
                e.preventDefault();
                const isVisible = menu.classList.contains('visible');
                toggleDropdown(!isVisible);
            });
            
            // Gestion du clavier
            trigger.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') {
                    toggleDropdown(false);
                }
            });
        });
    },

    // Gestion des modales
    initModals: function() {
        // Auto-focus sur les premiers champs des modales
        document.addEventListener('shown.bs.modal', function(event) {
            const modal = event.target;
            const firstInput = modal.querySelector('input, textarea, select');
            if (firstInput) {
                firstInput.focus();
            }
        });
    },

    // Initialisation des graphiques
    initCharts: function() {
        document.querySelectorAll('[data-chart]').forEach(canvas => {
            const ctx = canvas.getContext('2d');
            const data = JSON.parse(canvas.dataset.chartData || '{}');
            const type = canvas.dataset.chartType || 'line';
            
            if (ctx && data) {
                const chart = new Chart(ctx, {
                    type,
                    data,
                    options: this.config.chartOptions
                });
                
                this.state.charts.set(canvas.id, chart);
            }
        });
    },

    // Actualisation automatique des données
    initDataRefresh: function() {
        // Actualiser les données toutes les 30 secondes
        setInterval(() => {
            this.refreshData();
        }, this.config.refreshInterval);
    },

    refreshData: function() {
        // Récupérer les nouvelles données depuis l'API
        fetch('/api/dashboard/data')
            .then(response => response.json())
            .then(data => {
                this.updateDashboardData(data);
            })
            .catch(error => {
                console.warn('Erreur lors de la récupération des données:', error);
            });
    },

    updateDashboardData: function(data) {
        // Mettre à jour les statistiques
        if (data.stats) {
            Object.keys(data.stats).forEach(key => {
                const element = document.querySelector(`[data-stat="${key}"]`);
                if (element) {
                    element.textContent = data.stats[key];
                }
            });
        }

        // Mettre à jour les graphiques
        if (data.charts && this.config.charts) {
            if (data.charts.temperature && this.config.charts.temperature) {
                this.config.charts.temperature.data = data.charts.temperature;
                this.config.charts.temperature.update();
            }
            if (data.charts.humidity && this.config.charts.humidity) {
                this.config.charts.humidity.data = data.charts.humidity;
                this.config.charts.humidity.update();
            }
        }
    },

    // Fonctions utilitaires pour les graphiques
    generateTimeLabels: function(count, type = 'hour') {
        const labels = [];
        const now = new Date();
        
        for (let i = count - 1; i >= 0; i--) {
            const date = new Date(now);
            if (type === 'hour') {
                date.setHours(date.getHours() - i);
                labels.push(date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }));
            } else if (type === 'day') {
                date.setDate(date.getDate() - i);
                labels.push(date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit' }));
            }
        }
        
        return labels;
    },

    generateRandomData: function(count, min, max) {
        const data = [];
        for (let i = 0; i < count; i++) {
            data.push(Math.random() * (max - min) + min);
        }
        return data;
    },

    // Fonctions de validation de formulaires
    initFormValidation: function() {
        document.querySelectorAll('form[data-validate]').forEach(form => {
            form.addEventListener('submit', (e) => {
                if (!form.checkValidity()) {
                    e.preventDefault();
                    this.showFormErrors(form);
                }
            });
            
            // Validation en temps réel
            form.querySelectorAll('input, select, textarea').forEach(field => {
                field.addEventListener('blur', () => {
                    this.validateField(field);
                });
                
                field.addEventListener('input', this.debounce(() => {
                    this.validateField(field);
                }, 300));
            });
        });
    },

    validateField: function(field) {
        const errorElement = field.nextElementSibling;
        
        if (field.validity.valid) {
            field.classList.remove('invalid');
            if (errorElement?.classList.contains('error-message')) {
                errorElement.remove();
            }
        } else {
            field.classList.add('invalid');
            if (!errorElement?.classList.contains('error-message')) {
                const error = document.createElement('div');
                error.className = 'error-message text-sm text-danger mt-1';
                error.textContent = field.validationMessage;
                field.parentNode.insertBefore(error, field.nextSibling);
            }
        }
    },

    showFormErrors: function(form) {
        form.querySelectorAll('input, select, textarea').forEach(field => {
            this.validateField(field);
        });
        
        const firstError = form.querySelector('.invalid');
        if (firstError) {
            firstError.focus();
        }
    },

    removeWithAnimation: function(element) {
        element.style.animation = 'fadeOut 0.3s ease-out forwards';
        element.addEventListener('animationend', () => {
            element.remove();
        }, { once: true });
    },

    debounce: function(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },

    handleResize: function() {
        const sidebar = document.getElementById(this.config.sidebarId);
        const overlay = document.getElementById(this.config.sidebarOverlayId);
        
        if (window.innerWidth >= 768) {
            sidebar?.classList.remove('mobile-visible');
            overlay?.classList.remove('visible');
            document.body.style.overflow = '';
        }
        
        // Redimensionner les graphiques
        this.state.charts.forEach(chart => {
            chart.resize();
        });
    },

    cleanup: function() {
        // Nettoyer les graphiques
        this.state.charts.forEach(chart => {
            chart.destroy();
        });
        this.state.charts.clear();
        
        // Supprimer les écouteurs d'événements
        this.state.eventListeners.forEach((listener, element) => {
            element.removeEventListener(listener.type, listener.handler);
        });
        this.state.eventListeners.clear();
    },

    // Fonctions API
    api: {
        get: function(endpoint) {
            return fetch(BeeTrack.config.apiBase + endpoint)
                .then(response => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.json();
                });
        },

        post: function(endpoint, data) {
            return fetch(BeeTrack.config.apiBase + endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            });
        },

        delete: function(endpoint) {
            return fetch(BeeTrack.config.apiBase + endpoint, {
                method: 'DELETE'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            });
        }
    },

    // Fonctions utilitaires
    utils: {
        formatDate: function(date, options = {}) {
            const defaultOptions = { 
                year: 'numeric', 
                month: '2-digit', 
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit'
            };
            return new Date(date).toLocaleDateString('fr-FR', { ...defaultOptions, ...options });
        },

        formatNumber: function(number, decimals = 1) {
            return parseFloat(number).toFixed(decimals);
        },

        showConfirm: function(message, onConfirm, onCancel) {
            if (confirm(message)) {
                if (onConfirm) onConfirm();
            } else {
                if (onCancel) onCancel();
            }
        }
    }
};

// Initialisation quand le DOM est prêt
document.addEventListener('DOMContentLoaded', function() {
    BeeTrack.init();
});

// Fonctions globales pour les templates Thymeleaf
window.BeeTrack = BeeTrack;
