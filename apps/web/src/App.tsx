import React, { useState, useEffect } from 'react';
import { PasswordInput, Center, Container, AppShell, Text, Group, Title, Paper, Stack, Button, ThemeIcon, Loader, TextInput } from '@mantine/core';
import { IconUsers, IconSettings, IconDatabase, IconShieldCheck, IconBook, IconFileText, IconCategory, IconSparkles, IconLayoutDashboard, IconLock, IconDownload, IconKey, IconBriefcase } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from './services/api';
import { useStore } from './store/useStore';
import { CompetencyEditor } from './views/CompetencyEditor';
import { DiscoveryView } from './views/DiscoveryView';
import { RepartitionView } from './views/RepartitionView';
import { FichesPDF2View } from './views/FichesPDF2View';
import { SettingsView } from './views/SettingsView';
import { KeycloakUserManagement } from './views/KeycloakUserManagement';
import { DispatcherView } from './views/DispatcherView';
import { StudentDashboard } from './views/StudentDashboard';
import { OdooAdminView } from './views/OdooAdminView';
import { ProfessorDashboard } from './views/ProfessorDashboard';
import { AiAssistantView } from './views/AiAssistantView';
import { AdminDashboardView } from './views/AdminDashboardView';
import { PublicEvaluationView } from './views/PublicEvaluationView';
import { InternshipManagementView } from './views/InternshipManagementView';
import { GovernanceReportView } from './views/GovernanceReportView';
import { useMediaQuery } from '@mantine/hooks';
import { IconInfoCircle } from '@tabler/icons-react';
import { Alert } from '@mantine/core';

const YEAR_COLORS: any = { 0: 'gray', 1: 'blue', 2: 'green', 3: 'grape' };

function App() {
  const isMobile = useMediaQuery('(max-width: 62em)');
  const { token, setToken, user, setUser, curriculum, fetchCurriculum, setConfig, config } = useStore();
  const [publicToken, setPublicToken] = useState<string | null>(null);
  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginLoading, setLoginLoading] = useState(false);
  const [isForbidden, setIsForbidden] = useState(false);
  const [activeTab, setActiveTab] = useState<string | null>('dispatcher');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const magicToken = urlParams.get('token');
    if (magicToken) setPublicToken(magicToken);

    const getCookie = (name: string) => {
      const value = `; ${document.cookie}`;
      const parts = value.split(`; ${name}=`);
      if (parts.length === 2) return parts.pop()?.split(';').shift();
      return null;
    };
    const ssoToken = getCookie('auth_token');
    if (ssoToken && !token) setToken(ssoToken);
  }, []);

  const handleLogout = () => {
    setToken(null);
    setUser(null);
    setIsForbidden(false);
    localStorage.removeItem('auth_token');
    document.cookie = "auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
  };

  useEffect(() => {
    if (token) {
      localStorage.setItem('auth_token', token);
      api.get('/users/me')
        .then(res => {
          const fullUser = res.data;
          setUser(fullUser);
          setIsForbidden(false);
          if (fullUser.role === 'STUDENT') setActiveTab('dashboard');
          else if (fullUser.role === 'PROFESSOR') setActiveTab('dashboard');
          else setActiveTab('dispatcher');
          fetchData(fullUser.role);
          fetchCurriculum();
        })
        .catch(e => {
          if (e.response?.status === 403) setIsForbidden(true);
          else handleLogout();
        });
    }
  }, [token]);

  const fetchData = async (userRole?: string) => {
    try {
      const isStudent = userRole === 'STUDENT';
      const calls = [api.get('/groups'), api.get('/config').catch(() => ({ data: [] }))];
      if (!isStudent) {
        calls.push(api.get('/ldap-users'));
        calls.push(api.get('/users'));
      }
      const results = await Promise.all(calls);
      setLocalGroups(Array.isArray(results[0].data) ? results[0].data : []);
      setConfig(results[1].data);
      if (!isStudent && results[2] && results[3]) {
        setLdapUsers(results[2].data);
        setAssignedUsers(results[3].data.filter((u: any) => u.group_id !== null));
      }
    } catch (e: any) {
      if (e.response?.status === 403) setIsForbidden(true);
    }
  };

  const handleLogin = async () => {
    setLoginLoading(true);
    try {
      const formData = new FormData();
      formData.append('username', loginUsername);
      formData.append('password', loginPassword);
      const res = await api.post('/login', formData);
      setToken(res.data.access_token);
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Identifiants incorrects' });
    }
    setLoginLoading(false);
  };

  if (publicToken) return <PublicEvaluationView token={publicToken} />;

  if (isForbidden) return (
    <Center h="100vh" bg="red.0">
      <Paper shadow="xl" p="xl" radius="md" withBorder w={500} ta="center">
        <ThemeIcon size={80} radius="xl" color="red" mb="md"><IconLock size={50} /></ThemeIcon>
        <Title order={2} mb="xs">Accès Refusé</Title>
        <Text c="dimmed" mb="xl">Votre compte n'est pas autorisé. Contactez un administrateur.</Text>
        <Button variant="default" onClick={handleLogout}>Retour à l'accueil</Button>
      </Paper>
    </Center>
  );

  if (!token) return (
    <Center h="100vh" bg="gray.1">
      <Paper shadow="md" p="xl" radius="md" withBorder w={400}>
        <Stack align="center" mb="md">
          <ThemeIcon size={60} radius="xl" color="blue"><IconShieldCheck size={40} /></ThemeIcon>
          <Title order={3}>Skills Hub</Title>
        </Stack>
        <TextInput label="Identifiant" value={loginUsername} onChange={(e) => setLoginUsername(e.target.value)} mb="sm" />
        <PasswordInput label="Mot de passe" value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} mb="lg" />
        <Button fullWidth onClick={handleLogin} loading={loginLoading}>Se connecter</Button>
      </Paper>
    </Center>
  );

  if (!user) return <Center h="100vh"><Loader /></Center>;

  // --- VUE ÉTUDIANT ---
  if (user.role === 'STUDENT') {
    return (
      <AppShell header={{ height: 60 }} padding="md">
        <AppShell.Header p="md">
          <Group justify="space-between">
            <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>Skills Hub - Étudiant</Title></Group>
            <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
          </Group>
        </AppShell.Header>
        <AppShell.Main bg="gray.0" pb={isMobile ? 80 : 0}>
          <StudentDashboard user={user} curriculum={curriculum} groups={localGroups} />
        </AppShell.Main>
        {isMobile && (
          <div style={{ position: 'fixed', bottom: 0, left: 0, right: 0, height: 65, background: 'white', borderTop: '2px solid #eee', zIndex: 1000, padding: '10px' }}>
            <Group grow h="100%">
              <Button variant="subtle" onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={20}/>}>Bord</Button>
              <Button variant="subtle" color="blue" onClick={() => setActiveTab('internships')} leftSection={<IconBriefcase size={20}/>}>Stage</Button>
            </Group>
          </div>
        )}
      </AppShell>
    );
  }

  // --- VUE STAFF ---
  const isEnseignant = user.role === 'PROFESSOR' || user.role === 'STUDY_DIRECTOR';
  const isAdmin = ['ADMIN', 'SUPER_ADMIN', 'DEPT_HEAD', 'ADMIN_STAFF'].includes(user.role);
  const staffUsers = assignedUsers.filter(u => ['PROFESSOR', 'ADMIN', 'SUPER_ADMIN', 'DEPT_HEAD', 'ADMIN_STAFF', 'STUDY_DIRECTOR'].includes(u.role));

  const showMobileMessage = isMobile && !['dashboard', 'internships'].includes(activeTab || '');

  return (
    <AppShell header={{ height: 60 }} navbar={{ width: isMobile ? 0 : 250, breakpoint: 'sm' }} padding="md">
      <AppShell.Header p="md">
        <Group justify="space-between">
          <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>{isMobile ? 'Skills Mobile' : (isAdmin ? 'Skills Hub Admin' : 'Espace Enseignant')}</Title></Group>
          <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
        </Group>
      </AppShell.Header>
      
      {!isMobile && (
        <AppShell.Navbar p="md">
          <Stack gap="xs">
            {/* Menu Complet Desktop */}
            <Button variant={activeTab === 'dashboard' ? 'light' : 'subtle'} onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={20} />} justify="start">Tableau de Bord</Button>
            {isAdmin && <Button variant={activeTab === 'dispatcher' ? 'light' : 'subtle'} onClick={() => setActiveTab('dispatcher')} leftSection={<IconUsers size={20} />} justify="start">Dispatching</Button>}
            <Button variant={activeTab === 'curriculum' ? 'light' : 'subtle'} onClick={() => setActiveTab('curriculum')} leftSection={<IconBook size={20} />} color="grape" justify="start">Référentiel</Button>
            <Button variant={activeTab === 'discovery' ? 'light' : 'subtle'} onClick={() => setActiveTab('discovery')} leftSection={<IconCategory size={20} />} color="teal" justify="start">Découverte</Button>
            <Button variant={activeTab === 'repartition' ? 'light' : 'subtle'} onClick={() => setActiveTab('repartition')} leftSection={<IconDatabase size={20} />} color="orange" justify="start">Répartition</Button>
            <Button variant={activeTab === 'fiches2' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches2')} leftSection={<IconFileText size={20} />} color="cyan" justify="start">Fiches PDF</Button>
            <Button variant={activeTab === 'governance-report' ? 'light' : 'subtle'} onClick={() => setActiveTab('governance-report')} leftSection={<IconShieldCheck size={20} />} color="indigo" justify="start">Rapport Gouvernance</Button>
            <Button variant={activeTab === 'internships' ? 'light' : 'subtle'} onClick={() => setActiveTab('internships')} leftSection={<IconBriefcase size={20} />} color="blue" justify="start">Tutorat de Stage</Button>
            <Button variant={activeTab === 'ai-assistant' ? 'light' : 'subtle'} onClick={() => setActiveTab('ai-assistant')} leftSection={<IconSparkles size={20} />} color="indigo" justify="start">Assistant IA</Button>
            
            {isAdmin && (
              <>
                <Button variant={activeTab === 'keycloak' ? 'light' : 'subtle'} onClick={() => setActiveTab('keycloak')} leftSection={<IconKey size={20} />} color="orange" justify="start">Comptes Locaux</Button>
                <Button variant={activeTab === 'odoo-admin' ? 'light' : 'subtle'} onClick={() => setActiveTab('odoo-admin')} leftSection={<IconDatabase size={20} />} color="indigo" justify="start">Gestion Odoo</Button>
                <Button variant={activeTab === 'settings' ? 'light' : 'subtle'} onClick={() => setActiveTab('settings')} color="gray" leftSection={<IconSettings size={20} />} justify="start">Configuration</Button>
              </>
            )}
          </Stack>
        </AppShell.Navbar>
      )}

      {isMobile && (
        <div style={{ position: 'fixed', bottom: 0, left: 0, right: 0, height: 60, background: 'white', borderTop: '1px solid #eee', zIndex: 100, padding: '10px' }}>
          <Group grow>
            <Button variant={activeTab === 'dashboard' ? 'light' : 'subtle'} onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={18}/>}>Bord</Button>
            <Button variant={activeTab === 'internships' ? 'light' : 'subtle'} onClick={() => setActiveTab('internships')} leftSection={<IconBriefcase size={18}/>}>Stage</Button>
          </Group>
        </div>
      )}

      <AppShell.Main bg="gray.0" pb={isMobile ? 80 : 0}>
        {showMobileMessage && (
          <Alert color="orange" mb="md" icon={<IconInfoCircle />}>
            Cette fonctionnalité nécessite un ordinateur pour une expérience optimale.
          </Alert>
        )}
        {activeTab === 'dashboard' && (isAdmin ? <AdminDashboardView /> : <ProfessorDashboard user={user} curriculum={curriculum} setActiveTab={setActiveTab} />)}
        {activeTab === 'dispatcher' && !isMobile && <DispatcherView fetchData={() => fetchData(user.role)} ldapUsers={ldapUsers} setLdapUsers={setLdapUsers} localGroups={localGroups} assignedUsers={assignedUsers} YEAR_COLORS={YEAR_COLORS} />}
        {activeTab === 'curriculum' && !isMobile && <CompetencyEditor curriculum={curriculum} onRefresh={fetchCurriculum} professors={staffUsers} />}
        {activeTab === 'discovery' && !isMobile && <DiscoveryView curriculum={curriculum} />}
        {activeTab === 'repartition' && !isMobile && <RepartitionView curriculum={curriculum} />}
        {activeTab === 'fiches2' && <FichesPDF2View curriculum={curriculum} />}
        {activeTab === 'governance-report' && !isMobile && <GovernanceReportView />}
        {activeTab === 'internships' && <InternshipManagementView user={user} />}
        {activeTab === 'odoo-admin' && !isMobile && <OdooAdminView />}
        {activeTab === 'ai-assistant' && !isMobile && <AiAssistantView />}
        {activeTab === 'keycloak' && !isMobile && <KeycloakUserManagement />}
        {activeTab === 'settings' && !isMobile && <SettingsView config={config} onSave={(vals) => api.post('/config', vals).then(() => fetchData())} />}
      </AppShell.Main>
    </AppShell>
  );
}

export default App;
