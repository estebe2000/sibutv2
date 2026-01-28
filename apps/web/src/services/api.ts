import axios from 'axios';

// Déterminer l'URL de base
// Si on est en HTTPS, on force l'appel API en HTTPS pour éviter le Mixed Content
// Si on est en dev (localhost), on garde le relatif
const isHttps = window.location.protocol === 'https:';
const API_URL = isHttps 
    ? `https://${window.location.host}/api` 
    : '/api';

const api = axios.create({
  baseURL: API_URL,
});

// Intercepteur pour injecter le token d'authentification
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token'); // On pourrait aussi le passer via le store
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
export { API_URL };
