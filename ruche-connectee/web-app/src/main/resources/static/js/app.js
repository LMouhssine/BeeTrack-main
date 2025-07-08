/**
 * Application JavaScript pour BeeTrack - Remplace les fonctionnalités React
 * Compatible avec les templates Thymeleaf
 */

// Configuration globale
const BeeTrack = {
    config: {
        apiBase: '/api',
        refreshInterval: 30000, // 30 secondes
        charts: {}
    },
    
    // État global de l'application
    state: {
        currentPage: 'dashboard',
        sidebarCollapsed: false,
        notifications: []
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
        
        // Initialiser Lucide Icons
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        
        console.log('✅ BeeTrack Application initialized');
    },

    // Gestion de la sidebar
    initSidebar: function() {
        const sidebarToggle = document.getElementById('sidebar-toggle');
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');
        const mainContent = document.getElementById('main-content');

        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                this.toggleSidebar();
            });
        }

        if (overlay) {
            overlay.addEventListener('click', () => {
                this.closeMobileSidebar();
            });
        }

        // Gérer le responsive
        this.handleResponsiveSidebar();
        window.addEventListener('resize', () => {
            this.handleResponsiveSidebar();
        });
    },

    toggleSidebar: function() {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        const overlay = document.getElementById('sidebar-overlay');

        if (window.innerWidth <= 768) {
            // Mobile: toggle visibility
            sidebar.classList.toggle('mobile-visible');
            overlay.classList.toggle('hidden');
        } else {
            // Desktop: toggle collapse
            sidebar.classList.toggle('collapsed');
            mainContent.classList.toggle('sidebar-collapsed');
            this.state.sidebarCollapsed = !this.state.sidebarCollapsed;
        }
    },

    closeMobileSidebar: function() {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');
        
        sidebar.classList.remove('mobile-visible');
        overlay.classList.add('hidden');
    },

    handleResponsiveSidebar: function() {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('sidebar-overlay');
        
        if (window.innerWidth > 768) {
            sidebar.classList.remove('mobile-visible');
            overlay.classList.add('hidden');
        }
    },

    // Système de notifications
    initNotifications: function() {
        // Créer le conteneur de notifications s'il n'existe pas
        if (!document.getElementById('notification-container')) {
            const container = document.createElement('div');
            container.id = 'notification-container';
            container.className = 'notification-container';
            document.body.appendChild(container);
        }
    },

    showNotification: function(message, type = 'info', duration = 5000) {
        const container = document.getElementById('notification-container');
        const notification = document.createElement('div');
        const id = 'notif-' + Date.now();
        
        notification.id = id;
        notification.className = `notification notification-${type} fade-in`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-message">${message}</span>
                <button type="button" class="notification-close" onclick="BeeTrack.removeNotification('${id}')">
                    <span>&times;</span>
                </button>
            </div>
        `;
        
        container.appendChild(notification);
        
        // Auto-remove après duration
        if (duration > 0) {
            setTimeout(() => {
                this.removeNotification(id);
            }, duration);
        }
        
        return id;
    },

    removeNotification: function(id) {
        const notification = document.getElementById(id);
        if (notification) {
            notification.classList.add('fade-out');
            setTimeout(() => {
                notification.remove();
            }, 300);
        }
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
        if (typeof Chart === 'undefined') {
            console.warn('Chart.js non disponible');
            return;
        }

        // Configuration par défaut pour Chart.js
        Chart.defaults.font.family = "'Inter', sans-serif";
        Chart.defaults.color = '#64748b';
        Chart.defaults.borderColor = '#e2e8f0';
        Chart.defaults.backgroundColor = 'rgba(245, 158, 11, 0.1)';
    },

    // Créer un graphique de température
    createTemperatureChart: function(canvasElement, data = null) {
        if (!canvasElement || typeof Chart === 'undefined') return null;

        const defaultData = {
            labels: this.generateTimeLabels(24),
            datasets: [{
                label: 'Température (°C)',
                data: this.generateRandomData(24, 20, 30),
                borderColor: '#ef4444',
                backgroundColor: 'rgba(239, 68, 68, 0.1)',
                tension: 0.1,
                fill: true
            }]
        };

        const chart = new Chart(canvasElement, {
            type: 'line',
            data: data || defaultData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: false,
                        min: 15,
                        max: 35,
                        title: {
                            display: true,
                            text: 'Température (°C)'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Heure'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `Température: ${context.parsed.y}°C`;
                            }
                        }
                    }
                }
            }
        });

        this.config.charts.temperature = chart;
        return chart;
    },

    // Créer un graphique d'humidité
    createHumidityChart: function(canvasElement, data = null) {
        if (!canvasElement || typeof Chart === 'undefined') return null;

        const defaultData = {
            labels: this.generateTimeLabels(24),
            datasets: [{
                label: 'Humidité (%)',
                data: this.generateRandomData(24, 50, 80),
                borderColor: '#3b82f6',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                tension: 0.1,
                fill: true
            }]
        };

        const chart = new Chart(canvasElement, {
            type: 'line',
            data: data || defaultData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        min: 0,
                        max: 100,
                        title: {
                            display: true,
                            text: 'Humidité (%)'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Heure'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `Humidité: ${context.parsed.y}%`;
                            }
                        }
                    }
                }
            }
        });

        this.config.charts.humidity = chart;
        return chart;
    },

    // Créer un graphique de poids
    createWeightChart: function(canvasElement, data = null) {
        if (!canvasElement || typeof Chart === 'undefined') return null;

        const defaultData = {
            labels: this.generateTimeLabels(7, 'day'),
            datasets: [{
                label: 'Poids (kg)',
                data: this.generateRandomData(7, 40, 50),
                borderColor: '#10b981',
                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                tension: 0.1,
                fill: true
            }]
        };

        const chart = new Chart(canvasElement, {
            type: 'line',
            data: data || defaultData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: false,
                        title: {
                            display: true,
                            text: 'Poids (kg)'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Jour'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `Poids: ${context.parsed.y} kg`;
                            }
                        }
                    }
                }
            }
        });

        this.config.charts.weight = chart;
        return chart;
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
    validateForm: function(formElement) {
        const inputs = formElement.querySelectorAll('input[required], textarea[required], select[required]');
        let isValid = true;
        
        inputs.forEach(input => {
            const isFieldValid = this.validateField(input);
            if (!isFieldValid) {
                isValid = false;
            }
        });
        
        return isValid;
    },

    validateField: function(field) {
        const value = field.value.trim();
        let isValid = true;
        let errorMessage = '';
        
        // Validation requise
        if (field.hasAttribute('required') && !value) {
            isValid = false;
            errorMessage = 'Ce champ est requis';
        }
        
        // Validation email
        if (field.type === 'email' && value) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                isValid = false;
                errorMessage = 'Format d\'email invalide';
            }
        }
        
        // Validation numérique
        if (field.type === 'number' && value) {
            const min = field.getAttribute('min');
            const max = field.getAttribute('max');
            const numValue = parseFloat(value);
            
            if (isNaN(numValue)) {
                isValid = false;
                errorMessage = 'Valeur numérique invalide';
            } else if (min && numValue < parseFloat(min)) {
                isValid = false;
                errorMessage = `La valeur doit être supérieure à ${min}`;
            } else if (max && numValue > parseFloat(max)) {
                isValid = false;
                errorMessage = `La valeur doit être inférieure à ${max}`;
            }
        }
        
        // Afficher/masquer le message d'erreur
        this.showFieldError(field, errorMessage);
        
        return isValid;
    },

    showFieldError: function(field, errorMessage) {
        // Supprimer l'ancien message d'erreur
        const existingError = field.parentNode.querySelector('.field-error');
        if (existingError) {
            existingError.remove();
        }
        
        // Supprimer les classes d'erreur
        field.classList.remove('is-invalid');
        
        if (errorMessage) {
            // Ajouter la classe d'erreur
            field.classList.add('is-invalid');
            
            // Créer le message d'erreur
            const errorElement = document.createElement('div');
            errorElement.className = 'field-error text-danger text-sm mt-1';
            errorElement.textContent = errorMessage;
            
            // Insérer après le champ
            field.parentNode.insertBefore(errorElement, field.nextSibling);
        }
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
