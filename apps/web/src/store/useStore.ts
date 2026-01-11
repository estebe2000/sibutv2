import { create } from 'zustand';
import axios from 'axios';
import { notifications } from '@mantine/notifications';

interface State {
  token: string | null;
  user: any | null;
  curriculum: any;
  config: any[];
  setToken: (token: string | null) => void;
  setUser: (user: any) => void;
  setConfig: (config: any[]) => void;
  setCurriculum: (curriculum: any) => void;
  fetchCurriculum: (apiUrl: string) => Promise<void>;
  logout: () => void;
}

export const useStore = create<State>((set) => ({
  token: localStorage.getItem('token'),
  user: null,
  curriculum: { competences: [], activities: [], resources: [] },
  config: [],
  setToken: (token) => {
    if (token) localStorage.setItem('token', token);
    else localStorage.removeItem('token');
    set({ token });
  },
  setUser: (user) => set({ user }),
  setConfig: (config) => set({ config }),
  setCurriculum: (curriculum) => set({ curriculum }),
  fetchCurriculum: async (apiUrl) => {
    try {
      const [compRes, actRes, resRes] = await Promise.all([
        axios.get(`${apiUrl}/competencies`),
        axios.get(`${apiUrl}/activities`),
        axios.get(`${apiUrl}/resources`)
      ]);
      set({
        curriculum: {
          competences: Array.isArray(compRes.data) ? compRes.data : [],
          activities: Array.isArray(actRes.data) ? actRes.data : [],
          resources: Array.isArray(resRes.data) ? resRes.data : []
        }
      });
    } catch (e) { console.error("Failed to fetch curriculum", e); }
  },
  logout: () => {
    localStorage.removeItem('token');
    set({ token: null, user: null });
  }
}));
