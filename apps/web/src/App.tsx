import React, { useState, useEffect } from 'react';
import {
  PasswordInput,
  Center,
  Grid,
  Container,
  AppShell,
  Text,
  Group,
  Title,
  Paper,
  Stack,
  Button,
  Badge,
  ScrollArea,
  TextInput,
  Select,
  ActionIcon,
  Modal,
  ThemeIcon
} from '@mantine/core';
import {
  IconUsers,
  IconSettings,
  IconDatabase,
  IconShieldCheck,
  IconBook,
  IconFileText,
  IconCategory
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from './services/api';
import { useStore } from './store/useStore';
import { CompetencyEditor } from './views/CompetencyEditor';
import { DiscoveryView } from './views/DiscoveryView';
import { RepartitionView } from './views/RepartitionView';
import { FichesView } from './views/FichesView';
import { FichesPDF2View } from './views/FichesPDF2View';
import { SettingsView } from './views/SettingsView';
import { KeycloakUserManagement } from './views/KeycloakUserManagement';
import { DispatcherView } from './views/DispatcherView';
import { StudentDashboard } from './views/StudentDashboard';

const YEAR_COLORS: any = {
  0: 'gray',
  1: 'blue',
  2: 'green',
  3: 'grape'
};

function App() {
  console.log("Skills Hub Admin v1.1.0 - Import Modal Active");
  const {
    token, setToken,
    user, setUser,
    curriculum, setCurriculum, fetchCurriculum,
    config, setConfig
  } = useStore();

  // SSO Auto-login via Cookie
  useEffect(() => {
    const getCookie = (name: string) => {
      const value = `; ${document.cookie}`;
      const parts = value.split(`; ${name}=`);
      if (parts.length === 2) return parts.pop()?.split(';').shift();
      return null;
    };

    const ssoToken = getCookie('auth_token');
    if (ssoToken && !token) {
      console.log("SSO Token detected, logging in...");
      setToken(ssoToken);
    }
  }, []);

  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginLoading, setLoginLoading] = useState(false);

  // VIEW STATE
  const [activeTab, setActiveTab] = useState<string | null>('dispatcher');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  // Sync token with localStorage for the API service
  useEffect(() => {
    if (token) {
      localStorage.setItem('auth_token', token);
      
      // Fetch full user profile
      api.get('/users/me').then(res => {
        const fullUser = res.data;
        setUser(fullUser);
        fetchData(fullUser.role);
      }).catch(e => {
        console.error("Error fetching profile", e);
        fetchData();
      });

      fetchCurriculum();
    } else {
      localStorage.removeItem('auth_token');
      setUser(null);
    }
  }, [token]);

  const handleLogin = async () => {
    setLoginLoading(true);
    try {
      const formData = new FormData();
      formData.append('username', loginUsername);
      formData.append('password', loginPassword);
      const res = await api.post('/login', formData);
      setToken(res.data.access_token);
      notifications.show({ title: 'Bienvenue', message: 'Connexion réussie' });
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Identifiants incorrects' });
    }
    setLoginLoading(false);
  };

  const handleLogout = () => {
    setToken(null);
  };

  const fetchData = async (userRole?: string) => {
    try {
      const isStudent = userRole === 'STUDENT';
      
      // On définit les appels en fonction du rôle
      const calls = [
        api.get('/groups'),
        api.get('/config').catch(() => ({ data: [] }))
      ];

      // Seul le staff peut voir l'annuaire et la liste complète des users
      if (!isStudent) {
        calls.push(api.get('/ldap-users'));
        calls.push(api.get('/users'));
      }

      const results = await Promise.all(calls);
      
      setLocalGroups(Array.isArray(results[0].data) ? results[0].data : []);
      setConfig(results[1].data);

      if (!isStudent && results[2] && results[3]) {
        setLdapUsers(Array.isArray(results[2].data) ? results[2].data : []);
        setAssignedUsers(Array.isArray(results[3].data) ? results[3].data.filter((u: any) => u.group_id !== null) : []);
      }
    } catch (error: any) {
      if (error.response && error.response.status === 401) handleLogout();
      else console.error("Data fetching error", error);
    }
  };

  const handleSaveConfig = async (values: any[]) => {
    try {
      await api.post('/config', values);
      notifications.show({ title: 'Succès', message: 'Configuration enregistrée', color: 'green' });
      fetchData();
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
    }
  };

  if (!token) return (
    <Center h="100vh" bg="gray.1">
      <Paper shadow="md" p="xl" radius="md" withBorder w={400}>
        <Stack align="center" mb="md">
          <ThemeIcon size={60} radius="xl" color="blue"><IconShieldCheck size={40} /></ThemeIcon>
          <Title order={3}>Skills Hub Admin</Title>
        </Stack>
        <TextInput label="Identifiant" value={loginUsername} onChange={(e) => setLoginUsername(e.target.value)} mb="sm" />
        <PasswordInput label="Mot de passe" value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} mb="lg" />
        <Button fullWidth onClick={handleLogin} loading={loginLoading}>Se connecter</Button>
      </Paper>
    </Center>
  );

  // Vue Étudiant
  if (user && user.role === 'STUDENT') {
    return (
      <AppShell header={{ height: 60 }} padding="md">
        <AppShell.Header p="md">
          <Group justify="space-between">
            <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>Skills Hub - Espace Étudiant</Title></Group>
            <Group gap="xl">
              <Text size="sm" fw={500}>Bonjour, {user.full_name || user.ldap_uid}</Text>
              <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
            </Group>
          </Group>
        </AppShell.Header>
        <AppShell.Main bg="gray.0">
          <StudentDashboard user={user} groups={localGroups} curriculum={curriculum} />
        </AppShell.Main>
      </AppShell>
    );
  }

  // Vue Administration (Staff)
  return (
    <AppShell header={{ height: 60 }} navbar={{ width: 250, breakpoint: 'sm' }} padding="md">
      <AppShell.Header p="md">
        <Group justify="space-between">
          <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>Skills Hub Admin</Title></Group>
          <Group gap="xl">
            {user && <Text size="sm" fw={500}>Bonjour, {user.username}</Text>}
            <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
          </Group>
        </Group>
      </AppShell.Header>
      <AppShell.Navbar p="md">
        <Stack>
          <Button variant={activeTab === 'dispatcher' ? 'light' : 'subtle'} onClick={() => setActiveTab('dispatcher')} leftSection={<IconUsers size={20} />}>Dispatching</Button>
          <Button variant={activeTab === 'curriculum' ? 'light' : 'subtle'} onClick={() => setActiveTab('curriculum')} leftSection={<IconBook size={20} />} color="grape">Référentiel</Button>
          <Button variant={activeTab === 'discovery' ? 'light' : 'subtle'} onClick={() => setActiveTab('discovery')} leftSection={<IconCategory size={20} />} color="teal">Découverte</Button>
          <Button variant={activeTab === 'repartition' ? 'light' : 'subtle'} onClick={() => setActiveTab('repartition')} leftSection={<IconDatabase size={20} />} color="orange">Répartition</Button>
          {/* <Button variant={activeTab === 'fiches' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches')} leftSection={<IconDownload size={20} />} color="blue">Fiches PDF</Button> */}
          <Button variant={activeTab === 'fiches2' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches2')} leftSection={<IconFileText size={20} />} color="cyan">Fiches PDF 2</Button>
          <Button variant={activeTab === 'keycloak' ? 'light' : 'subtle'} onClick={() => setActiveTab('keycloak')} leftSection={<IconShieldCheck size={20} />} color="orange">Comptes Locaux</Button>
          <Button variant={activeTab === 'settings' ? 'light' : 'subtle'} onClick={() => setActiveTab('settings')} color="gray" leftSection={<IconSettings size={20} />}>Configuration</Button>
        </Stack>
      </AppShell.Navbar>
      <AppShell.Main>
        {activeTab === 'dispatcher' ? (
          <DispatcherView 
            fetchData={fetchData}
            ldapUsers={ldapUsers}
            setLdapUsers={setLdapUsers}
            localGroups={localGroups}
            assignedUsers={assignedUsers}
            YEAR_COLORS={YEAR_COLORS}
          />
        ) : activeTab === 'curriculum' ? (
          <CompetencyEditor 
              curriculum={curriculum} 
              onRefresh={fetchCurriculum}
              professors={assignedUsers.filter(u => u.role === 'PROFESSOR' || u.role === 'ADMIN' || u.role === 'SUPER_ADMIN')} 
          />
        ) : activeTab === 'discovery' ? (
          <DiscoveryView curriculum={curriculum} />
        ) : activeTab === 'repartition' ? (
          <RepartitionView curriculum={curriculum} />
        ) : activeTab === 'fiches' ? (
          <FichesView />
        ) : activeTab === 'fiches2' ? (
          <FichesPDF2View curriculum={curriculum} />
        ) : activeTab === 'keycloak' ? (
          <KeycloakUserManagement />
        ) : <SettingsView config={config} onSave={handleSaveConfig} />}
      </AppShell.Main>
    </AppShell>
  );
}




export default App;
