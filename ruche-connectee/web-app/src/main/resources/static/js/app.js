// Configuration de l'API
const API_BASE_URL = '/api';
const RUCHERS_ENDPOINT = `${API_BASE_URL}/ruchers`;

// État de l'application
let currentApiculteurId = null;
let ruchers = [];

// Initialisation de l'application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    loadRuchers();
});

/**
 * Initialise l'application
 */
function initializeApp() {
    console.log('🐝 BeeTrack Web App - Initialisation');
    
    // Récupérer l'ID apiculteur depuis le localStorage ou demander à l'utilisateur
    currentApiculteurId = localStorage.getItem('apiculteurId');
    
    if (!currentApiculteurId) {
        // Pour la démo, on peut utiliser un ID par défaut ou demander à l'utilisateur
        currentApiculteurId = prompt('Veuillez entrer votre ID apiculteur Firebase:');
        if (currentApiculteurId) {
            localStorage.setItem('apiculteurId', currentApiculteurId);
            document.getElementById('apiculteurId').value = currentApiculteurId;
        }
    } else {
        document.getElementById('apiculteurId').value = currentApiculteurId;
    }
}

/**
 * Configure les écouteurs d'événements
 */
function setupEventListeners() {
    // Navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetSection = this.getAttribute('href').substring(1);
            showSection(targetSection);
            
            // Mettre à jour la navigation active
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            this.classList.add('active');
        });
    });

    // Fermer le formulaire en cliquant sur l'overlay
    document.getElementById('addRucherForm').addEventListener('click', function(e) {
        if (e.target === this) {
            hideAddRucherForm();
        }
    });

    // Échapper pour fermer le formulaire
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            hideAddRucherForm();
        }
    });
}

/**
 * Affiche une section spécifique
 */
function showSection(sectionId) {
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
    }
}

/**
 * Affiche le formulaire d'ajout de rucher
 */
function showAddRucherForm() {
    document.getElementById('addRucherForm').classList.remove('hidden');
    document.getElementById('nom').focus();
}

/**
 * Cache le formulaire d'ajout de rucher
 */
function hideAddRucherForm() {
    document.getElementById('addRucherForm').classList.add('hidden');
    document.getElementById('rucherForm').reset();
    
    // Remettre l'ID apiculteur
    if (currentApiculteurId) {
        document.getElementById('apiculteurId').value = currentApiculteurId;
    }
}

/**
 * Soumet le formulaire de création de rucher
 */
async function submitRucher(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const rucherData = {
        nom: formData.get('nom').trim(),
        adresse: formData.get('adresse').trim(),
        description: formData.get('description').trim(),
        idApiculteur: formData.get('apiculteurId').trim()
    };

    // Validation
    if (!rucherData.nom || !rucherData.adresse || !rucherData.description || !rucherData.idApiculteur) {
        showNotification('Veuillez remplir tous les champs obligatoires', 'error');
        return;
    }

    // Sauvegarder l'ID apiculteur
    currentApiculteurId = rucherData.idApiculteur;
    localStorage.setItem('apiculteurId', currentApiculteurId);

    try {
        showLoading(true);
        
        const response = await fetch(`${RUCHERS_ENDPOINT}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                nom: rucherData.nom,
                adresse: rucherData.adresse,
                description: rucherData.description,
                apiculteurId: rucherData.idApiculteur
            })
        });

        if (response.ok) {
            const nouveauRucher = await response.json();
            showNotification(`Rucher "${rucherData.nom}" créé avec succès !`, 'success');
            hideAddRucherForm();
            await loadRuchers(); // Recharger la liste
        } else {
            const errorText = await response.text();
            throw new Error(errorText || 'Erreur lors de la création du rucher');
        }
    } catch (error) {
        console.error('Erreur lors de la création du rucher:', error);
        showNotification(`Erreur: ${error.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

/**
 * Charge la liste des ruchers
 */
async function loadRuchers() {
    if (!currentApiculteurId) {
        showEmptyState();
        return;
    }

    try {
        showLoading(true);
        
        const response = await fetch(`${RUCHERS_ENDPOINT}/apiculteur/${currentApiculteurId}`);
        
        if (response.ok) {
            ruchers = await response.json();
            displayRuchers(ruchers);
        } else {
            throw new Error('Erreur lors du chargement des ruchers');
        }
    } catch (error) {
        console.error('Erreur lors du chargement des ruchers:', error);
        showNotification('Erreur lors du chargement des ruchers', 'error');
        showEmptyState();
    } finally {
        showLoading(false);
    }
}

/**
 * Affiche la liste des ruchers
 */
function displayRuchers(ruchersData) {
    const ruchersGrid = document.getElementById('ruchersList');
    const emptyState = document.getElementById('emptyState');

    if (!ruchersData || ruchersData.length === 0) {
        showEmptyState();
        return;
    }

    // Cacher l'état vide
    emptyState.classList.add('hidden');
    ruchersGrid.classList.remove('hidden');

    // Générer le HTML des ruchers
    ruchersGrid.innerHTML = ruchersData.map(rucher => createRucherCard(rucher)).join('');
}

/**
 * Crée une carte de rucher
 */
function createRucherCard(rucher) {
    const dateCreation = rucher.dateCreation ? 
        new Date(rucher.dateCreation).toLocaleDateString('fr-FR') : 
        'Date inconnue';

    return `
        <div class="rucher-card" data-rucher-id="${rucher.id}">
            <div class="rucher-header">
                <h3 class="rucher-title">${escapeHtml(rucher.nom)}</h3>
                <div class="rucher-actions">
                    <button class="btn btn-secondary" onclick="editRucher('${rucher.id}')" title="Modifier">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-secondary" onclick="deleteRucher('${rucher.id}')" title="Supprimer">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
            
            <div class="rucher-info">
                <i class="fas fa-map-marker-alt"></i>
                ${escapeHtml(rucher.adresse)}
            </div>
            
            <div class="rucher-info">
                <i class="fas fa-file-alt"></i>
                ${escapeHtml(rucher.description)}
            </div>
            
            <div class="rucher-stats">
                <span>
                    <i class="fas fa-hive"></i>
                    ${rucher.nombreRuches || 0} ruche(s)
                </span>
                <span>
                    <i class="fas fa-calendar"></i>
                    ${dateCreation}
                </span>
            </div>
        </div>
    `;
}

/**
 * Affiche l'état vide
 */
function showEmptyState() {
    const ruchersGrid = document.getElementById('ruchersList');
    const emptyState = document.getElementById('emptyState');
    
    ruchersGrid.classList.add('hidden');
    emptyState.classList.remove('hidden');
}

/**
 * Modifie un rucher
 */
function editRucher(rucherId) {
    showNotification('Fonctionnalité de modification en développement', 'info');
}

/**
 * Supprime un rucher
 */
async function deleteRucher(rucherId) {
    const rucher = ruchers.find(r => r.id === rucherId);
    if (!rucher) return;

    if (!confirm(`Êtes-vous sûr de vouloir supprimer le rucher "${rucher.nom}" ?`)) {
        return;
    }

    try {
        showLoading(true);
        
        const response = await fetch(`${RUCHERS_ENDPOINT}/${rucherId}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            showNotification(`Rucher "${rucher.nom}" supprimé avec succès`, 'success');
            await loadRuchers(); // Recharger la liste
        } else {
            throw new Error('Erreur lors de la suppression du rucher');
        }
    } catch (error) {
        console.error('Erreur lors de la suppression:', error);
        showNotification(`Erreur: ${error.message}`, 'error');
    } finally {
        showLoading(false);
    }
}

/**
 * Affiche une notification
 */
function showNotification(message, type = 'info') {
    const notifications = document.getElementById('notifications');
    
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>${escapeHtml(message)}</span>
            <button onclick="this.parentElement.parentElement.remove()" style="background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #6c757d;">
                <i class="fas fa-times"></i>
            </button>
        </div>
    `;
    
    notifications.appendChild(notification);
    
    // Auto-suppression après 5 secondes
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

/**
 * Affiche/cache l'overlay de chargement
 */
function showLoading(show) {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (show) {
        loadingOverlay.classList.remove('hidden');
    } else {
        loadingOverlay.classList.add('hidden');
    }
}

/**
 * Échappe le HTML pour éviter les injections XSS
 */
function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

/**
 * Utilitaire pour formater les dates
 */
function formatDate(dateString) {
    if (!dateString) return 'Date inconnue';
    
    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    } catch (error) {
        return 'Date invalide';
    }
}

/**
 * Rafraîchit la liste des ruchers
 */
function refreshRuchers() {
    loadRuchers();
}

// Fonctions globales pour les événements onclick
window.showAddRucherForm = showAddRucherForm;
window.hideAddRucherForm = hideAddRucherForm;
window.submitRucher = submitRucher;
window.editRucher = editRucher;
window.deleteRucher = deleteRucher;
window.refreshRuchers = refreshRuchers; 