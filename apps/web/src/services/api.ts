import axios from 'axios';

const API_URL = '/api';

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
