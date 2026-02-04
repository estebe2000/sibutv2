import React, { useState, useEffect } from 'react';
import { PasswordInput, Center, Container, AppShell, Text, Group, Title, Paper, Stack, Button, ThemeIcon, Loader, TextInput, Divider, Alert } from '@mantine/core';
import { IconUsers, IconSettings, IconDatabase, IconShieldCheck, IconBook, IconFileText, IconCategory, IconSparkles, IconLayoutDashboard, IconLock, IconDownload, IconKey, IconBriefcase, IconInfoCircle, IconCalendarPlus, IconCalendar, IconMail, IconMessages, IconCloud, IconLamp, IconMessageDots, IconSearch, IconSchool, IconBrandAsana, IconPencil, IconStar, IconBuilding, IconSend, IconFilter } from '@tabler/icons-react';
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
import { ProfessorPortfolioView } from './views/ProfessorPortfolioView';
import { AiAssistantView } from './views/AiAssistantView';
import { AdminDashboardView } from './views/AdminDashboardView';
import { PublicEvaluationView } from './views/PublicEvaluationView';
import { InternshipManagementView } from './views/InternshipManagementView';
import { InternshipSearchView } from './views/InternshipSearchView';
import { CompanyCodexView } from './views/CompanyCodexView';
import { AcademicPathView } from './views/AcademicPathView';
import { StudentOdooView } from './views/StudentOdooView';
import { StudentPortfolioView } from './views/StudentPortfolioView';
import { LiveBookPreviewView } from './views/LiveBookPreviewView';
import { GovernanceReportView } from './views/GovernanceReportView';
import { AdminPortfolioBrowserView } from './views/AdminPortfolioBrowserView';
import { NewYearTransitionView } from './views/NewYearTransitionView';
import { ExternalServicesProposalsView } from './views/ExternalServicesProposalsView';
import { CalendarView } from './views/CalendarView';
import { FeedbackHubView } from './views/FeedbackHubView';
import { LearningOutcomeEditorView } from './views/LearningOutcomeEditorView';
import { useMediaQuery } from '@mantine/hooks';
import './Login.css';

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
  const [publicConfig, setPublicConfig] = useState<any>({ APP_PRIMARY_COLOR: '#1971c2', APP_LOGO_URL: '' });

  useEffect(() => {
    if (publicConfig.APP_PRIMARY_COLOR) {
      document.documentElement.style.setProperty('--mantine-primary-color-filled', publicConfig.APP_PRIMARY_COLOR);
      // On force aussi la couleur sur les boutons Mantine par defaut
      const style = document.createElement('style');
      style.innerHTML = `.mantine-Button-root[data-variant="filled"] { background-color: ${publicConfig.APP_PRIMARY_COLOR} !important; }`;
      document.head.appendChild(style);
    }
  }, [publicConfig.APP_PRIMARY_COLOR]);

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

  if (!token) {
    const primaryColor = publicConfig?.APP_PRIMARY_COLOR || '#1971c2';
    const logoUrl = publicConfig?.APP_LOGO_URL || '';
    const welcomeMsg = publicConfig?.APP_WELCOME_MESSAGE || 'Bienvenue sur le Hub';

    if (!publicConfig) return <Center h="100vh"><Loader /></Center>;

    return (
      <div className={`login-wrapper ${loginLoading ? 'form-success' : ''}`} style={{ background: `linear-gradient(to bottom right, ${primaryColor} 0%, #53e3a6 100%)` }}>
        <div className="login-container">
          {(logoUrl && logoUrl.trim() !== "") ? (
              <img 
                src={logoUrl} 
                alt="Logo" 
                style={{ maxHeight: 120, marginBottom: 20, maxWidth: '100%', objectFit: 'contain', display: 'block', margin: '0 auto 20px' }} 
                onError={(e) => {
                    console.error("Logo failed to load:", logoUrl);
                    e.currentTarget.style.display = 'none';
                }}
              />
          ) : (
              <ThemeIcon size={60} radius="xl" color="white" mb="md" variant="light">
                  <IconShieldCheck size={40} color="white" />
              </ThemeIcon>
          )}
          <h1>{welcomeMsg}</h1>
          <form className="login-form" onSubmit={(e) => { e.preventDefault(); handleLogin(); }}>
            <input 
              type="text" 
              name="username"
              placeholder="Identifiant" 
              autoComplete="username"
              value={loginUsername} 
              onChange={(e) => setLoginUsername(e.target.value)} 
              required 
              style={{ borderColor: 'rgba(255,255,255,0.4)' }}
            />
            <input 
              type="password" 
              name="password"
              placeholder="Mot de passe" 
              autoComplete="current-password"
              value={loginPassword} 
              onChange={(e) => setLoginPassword(e.target.value)} 
              required 
              style={{ borderColor: 'rgba(255,255,255,0.4)' }}
            />
            <button type="submit" className="login-button" disabled={loginLoading} style={{ color: primaryColor }}>
              {loginLoading ? 'Connexion...' : 'Se connecter'}
            </button>
          </form>
        </div>
        
        <ul className="bg-bubbles">
          <li></li><li></li><li></li><li></li><li></li>
          <li></li><li></li><li></li><li></li><li></li>
        </ul>
      </div>
    );
  }

  if (!user) return <Center h="100vh"><Loader /></Center>;

  if (user.role === 'STUDENT') {
    return (
      <AppShell header={{ height: 60 }} navbar={{ width: isMobile ? 0 : 220, breakpoint: 'sm' }} padding="md">
        <AppShell.Header p="md">
          <Group justify="space-between">
            <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>Skills Hub - Étudiant</Title></Group>
            <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
          </Group>
        </AppShell.Header>

        {!isMobile && (
          <AppShell.Navbar p="md">
            <Stack gap="sm">
              <Button variant={activeTab === 'dashboard' ? 'filled' : 'subtle'} onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={18} />} justify="start">Tableau de Bord</Button>
              <Button variant={activeTab === 'stages' ? 'filled' : 'subtle'} onClick={() => setActiveTab('stages')} leftSection={<IconBriefcase size={18} />} justify="start" color="orange">Stages</Button>
              <Button variant={activeTab === 'portfolio' ? 'filled' : 'subtle'} onClick={() => setActiveTab('portfolio')} leftSection={<IconBook size={18} />} justify="start" color="blue">Portfolio</Button>
              <Button variant={activeTab === 'parcours' ? 'filled' : 'subtle'} onClick={() => setActiveTab('parcours')} leftSection={<IconSchool size={18} />} justify="start" color="grape">Parcours Scolaire</Button>
              <Button variant={activeTab === 'odoo' ? 'filled' : 'subtle'} onClick={() => setActiveTab('odoo')} leftSection={<IconDatabase size={18} />} justify="start" color="indigo">Accès Odoo</Button>
            </Stack>
          </AppShell.Navbar>
        )}

        <AppShell.Main bg="gray.0" pb={isMobile ? 80 : 0}>
          {activeTab === 'dashboard' && <StudentDashboard user={user} groups={localGroups} />}
          {activeTab === 'stages' && <InternshipSearchView user={user} />}
          {activeTab === 'portfolio' && <StudentPortfolioView user={user} curriculum={curriculum} groups={localGroups} setGlobalTab={setActiveTab} />}
          {activeTab === 'live-book' && <LiveBookPreviewView user={user} />}
          {activeTab === 'parcours' && <AcademicPathView />}
          {activeTab === 'odoo' && <StudentOdooView />}
        </AppShell.Main>
        {isMobile && (
          <div style={{ position: 'fixed', bottom: 0, left: 0, right: 0, height: 65, background: 'white', borderTop: '2px solid #eee', zIndex: 1000, padding: '10px' }}>
            <Group grow h="100%">
              <Button variant="subtle" onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={20}/>} />
              <Button variant="subtle" onClick={() => setActiveTab('stages')} leftSection={<IconBriefcase size={20}/>} color="orange" />
              <Button variant="subtle" onClick={() => setActiveTab('portfolio')} leftSection={<IconBook size={20}/>} color="blue" />
              <Button variant="subtle" onClick={() => setActiveTab('parcours')} leftSection={<IconSchool size={20}/>} color="grape" />
            </Group>
          </div>
        )}
      </AppShell>
    );
  }

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
          <Stack gap="sm">
            <Paper p={5} radius="sm" bg="blue.0" withBorder style={{ borderColor: 'var(--mantine-color-blue-2)' }}>
              <Text size="10px" fw={700} c="blue.9" px="xs" mb={5} tt="uppercase">Outils Enseignant</Text>
              <Stack gap={2}>
                <Button variant={activeTab === 'dashboard' ? 'filled' : 'subtle'} onClick={() => setActiveTab('dashboard')} leftSection={<IconLayoutDashboard size={18} />} justify="start" size="compact-sm" color="blue">Pilotage</Button>
                <Button variant={activeTab === 'internship-management' ? 'filled' : 'subtle'} onClick={() => setActiveTab('internship-management')} leftSection={<IconBriefcase size={18} />} justify="start" size="compact-sm" color="blue">Tutorat de Stage</Button>
                <Button variant={activeTab === 'companies' ? 'filled' : 'subtle'} onClick={() => setActiveTab('companies')} leftSection={<IconBuilding size={18} />} justify="start" size="compact-sm" color="blue">Codex Entreprises</Button>
                <Button variant={activeTab === 'admin-portfolios' ? 'filled' : 'subtle'} onClick={() => setActiveTab('admin-portfolios')} leftSection={<IconBook size={18} />} justify="start" size="compact-sm" color="blue">Portfolio</Button>
                <Button variant={activeTab === 'ai-assistant' ? 'filled' : 'subtle'} onClick={() => setActiveTab('ai-assistant')} leftSection={<IconSparkles size={18} />} justify="start" size="compact-sm" color="blue">Assistant IA</Button>
                <Button variant={activeTab === 'prof-portfolio' ? 'filled' : 'subtle'} onClick={() => setActiveTab('prof-portfolio')} leftSection={<IconFileText size={18} />} justify="start" size="compact-sm" color="orange">Médiathèque Preuves</Button>
              </Stack>
            </Paper>

            <Paper p={5} radius="sm" bg="yellow.0" withBorder style={{ borderColor: 'var(--mantine-color-yellow-2)' }}>
              <Text size="10px" fw={700} c="yellow.9" px="xs" mb={5} tt="uppercase">Idées & Outils</Text>
              <Stack gap={2}>
                <Button variant={activeTab === 'idea-calendar' ? 'filled' : 'subtle'} onClick={() => setActiveTab('idea-calendar')} leftSection={<IconCalendar size={18} />} justify="start" size="compact-sm" color="yellow">Calendrier</Button>
                <Button variant={activeTab === 'idea-mail' ? 'filled' : 'subtle'} onClick={() => setActiveTab('idea-mail')} leftSection={<IconMail size={18} />} justify="start" size="compact-sm" color="yellow">Mail</Button>
                <Button variant={activeTab === 'idea-chat' ? 'filled' : 'subtle'} onClick={() => setActiveTab('idea-chat')} leftSection={<IconMessages size={18} />} justify="start" size="compact-sm" color="yellow">Chat</Button>
                <Button variant={activeTab === 'idea-cloud' ? 'filled' : 'subtle'} onClick={() => setActiveTab('idea-cloud')} leftSection={<IconCloud size={18} />} justify="start" size="compact-sm" color="yellow">Cloud</Button>
              </Stack>
            </Paper>
            
            {isAdmin && (
              <Paper p={5} radius="sm" bg="gray.1" withBorder style={{ borderColor: 'var(--mantine-color-gray-3)' }}>
                <Text size="10px" fw={700} c="gray.9" px="xs" mb={5} tt="uppercase">Administration</Text>
                <Stack gap={2}>
                  <Button variant={activeTab === 'keycloak' ? 'filled' : 'subtle'} onClick={() => setActiveTab('keycloak')} leftSection={<IconKey size={18} />} justify="start" size="compact-sm" color="gray">Comptes Locaux</Button>
                  <Button variant={activeTab === 'odoo-admin' ? 'filled' : 'subtle'} onClick={() => setActiveTab('odoo-admin')} leftSection={<IconDatabase size={18} />} justify="start" size="compact-sm" color="gray">Gestion Odoo</Button>
                  <Button variant={activeTab === 'new-year' ? 'filled' : 'subtle'} onClick={() => setActiveTab('new-year')} leftSection={<IconCalendarPlus size={18} />} justify="start" size="compact-sm" color="gray">Transition Année</Button>
                  <Button variant={activeTab === 'settings' ? 'filled' : 'subtle'} onClick={() => setActiveTab('settings')} leftSection={<IconSettings size={18} />} justify="start" size="compact-sm" color="gray">Configuration</Button>
                </Stack>
              </Paper>
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
        {activeTab === 'prof-portfolio' && <ProfessorPortfolioView />}
        {activeTab === 'dispatcher' && !isMobile && <DispatcherView fetchData={() => fetchData(user.role)} ldapUsers={ldapUsers} setLdapUsers={setLdapUsers} localGroups={localGroups} assignedUsers={assignedUsers} YEAR_COLORS={YEAR_COLORS} />}
        {activeTab === 'curriculum' && !isMobile && <CompetencyEditor curriculum={curriculum} onRefresh={fetchCurriculum} professors={staffUsers} />}
        {activeTab === 'ac-editor' && !isMobile && <LearningOutcomeEditorView />}
        {activeTab === 'discovery' && <DiscoveryView curriculum={curriculum} />}
        {activeTab === 'repartition' && !isMobile && <RepartitionView curriculum={curriculum} />}
        {activeTab === 'fiches2' && <FichesPDF2View curriculum={curriculum} />}
        {activeTab === 'governance-report' && !isMobile && <GovernanceReportView />}
        {activeTab === 'internship-management' && <InternshipManagementView user={user} />}
        {activeTab === 'companies' && <CompanyCodexView />}
        {activeTab === 'public-eval' && <PublicEvaluationView />}
        {activeTab === 'applications' && <InternshipSearchView user={user} mode="admin" />}
        {activeTab === 'admin-portfolios' && !isMobile && <AdminPortfolioBrowserView />}
        {activeTab === 'odoo-admin' && !isMobile && <OdooAdminView />}
        {activeTab === 'ai-assistant' && !isMobile && <AiAssistantView />}
        {activeTab === 'keycloak' && !isMobile && <KeycloakUserManagement />}
        {activeTab === 'new-year' && !isMobile && <NewYearTransitionView />}
                  {activeTab === 'feedback' && <FeedbackHubView />}
                  {activeTab === 'idea-calendar' && <CalendarView />}
                  {activeTab === 'idea-mail' && <ExternalServicesProposalsView type="mail" />}        {activeTab === 'idea-chat' && <ExternalServicesProposalsView type="chat" />}
        {activeTab === 'idea-cloud' && <ExternalServicesProposalsView type="cloud" />}
        {activeTab === 'idea-alumni' && <ExternalServicesProposalsView type="alumni" />}
        {activeTab === 'settings' && !isMobile && <SettingsView config={config} onSave={(vals) => api.post('/config', vals).then(() => fetchData())} />}
      </AppShell.Main>
    </AppShell>
  );
}

export default App;