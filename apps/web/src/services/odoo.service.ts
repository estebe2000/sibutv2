import api from './api';

export interface OdooInstance {
  db_name: string;
  url: string;
  status: 'exists' | 'provisioning' | 'ready';
}

export const odooService = {
  // Provisionner une nouvelle instance
  provision: async (email: string, password: string) => {
    const response = await api.post('/odoo/provision', { email, password });
    return response.data;
  },

  // Lister toutes les bases (Admin/Prof only)
  listDatabases: async () => {
    const response = await api.get('/odoo/list');
    return response.data.databases; // Retourne un tableau de strings (noms de db)
  },

  // Supprimer une base (Admin/Prof only)
  deleteDatabase: async (dbName: string) => {
    const response = await api.delete(`/odoo/${dbName}`);
    return response.data;
  },
  
  // Vérifier si mon instance existe (en checkant la liste ou via une route dédiée si on en faisait une)
  // Pour l'instant on va inférer l'existence côté composant en listant ou en essayant d'accéder.
  // Idéalement il faudrait GET /api/odoo/me ou GET /api/odoo/status/{db_name}
  // On va utiliser le nom de base calculé depuis l'email pour vérifier dans la liste.
};
