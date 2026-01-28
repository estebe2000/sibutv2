import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, TextInput, Table, Switch, ActionIcon, Modal, Button, Badge, Loader, Center, Avatar, Tabs } from '@mantine/core';
import { IconBriefcase, IconSearch, IconEdit, IconCheck, IconX, IconPhone, IconMail, IconWorld, IconHistory, IconTrash, IconMap2, IconList } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';
import { CompanyMapView } from '../components/CompanyMapView';

export function CompanyCodexView() {
    const [companies, setCompanies] = useState<any[]>([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);
    const [editingCompany, setEditingCompany] = useState<any | null>(null);
    const [stats, setStats] = useState<Record<number, number>>({});
    const [activeTab, setActiveTab] = useState<string | null>('list');
    const [focusedCompany, setFocusedCompany] = useState<any | null>(null);
    
    // États pour l'historique
    const [historyCompany, setHistoryCompany] = useState<any | null>(null);
    const [historyData, setHistoryData] = useState<any[]>([]);
    const [historyLoading, setHistoryLoading] = useState(false);

    // États pour la mise à jour Sirene
    const [sireneSearch, setSireneSearch] = useState('');
    const [sireneResults, setSireneResults] = useState<any[]>([]);
    const [sireneLoading, setSireneLoading] = useState(false);
    const [showSireneSearch, setShowSireneSearch] = useState(false);

    const CompanyLogo = ({ website }: { website?: string }) => {
        const [src, setSrc] = useState<string | null>(null);
        const [hasError, setHasError] = useState(false);

        useEffect(() => {
            if (!website) { setSrc(null); return; }
            setHasError(false);
            try {
                const domain = website.replace('https://', '').replace('http://', '').split('/')[0];
                setSrc(`https://logo.clearbit.com/${domain}`);
            } catch (e) { setSrc(null); }
        }, [website]);

        const handleError = () => {
            if (hasError) return; // Stop si déjà en erreur
            if (src && src.includes('clearbit')) {
                setHasError(true);
                try {
                    const domain = website?.replace('https://', '').replace('http://', '').split('/')[0];
                    setSrc(`https://www.google.com/s2/favicons?domain=${domain}&sz=64`);
                } catch (e) { setSrc(null); }
            } else {
                setSrc(null);
            }
        };

        return (
            <Avatar src={src} radius="sm" size="md" onError={handleError} bg="gray.1">
                <IconBriefcase size={20} />
            </Avatar>
        );
    };

    const fetchCompanies = async () => {
        setLoading(true);
        try {
            const res = await api.get(`/companies/?search=${search}`);
            setCompanies(res.data);
            setLoading(false);
            
            // Fetch stats for each company with protections
            const newStats: Record<number, number> = {};
            await Promise.all(res.data.map(async (c: any) => {
                try {
                    const sRes = await api.get(`/companies/${c.id}/stats/`);
                    newStats[c.id] = sRes.data.total_interns;
                } catch (e) { 
                    newStats[c.id] = 0; 
                }
            }));
            setStats(newStats);
        } catch (e) {
            console.error(e);
            setLoading(false);
        }
    };

    const loadHistory = async (company: any) => {
        setHistoryCompany(company);
        setHistoryLoading(true);
        try {
            const res = await api.get(`/companies/${company.id}/internships/`);
            setHistoryData(res.data);
        } catch (e) { console.error(e); }
        setHistoryLoading(false);
    };

    useEffect(() => {
        const timer = setTimeout(fetchCompanies, 300);
        return () => clearTimeout(timer);
    }, [search]);

    const handleToggleInterns = async (company: any) => {
        try {
            await api.patch(`/companies/${company.id}`, { accepts_interns: !company.accepts_interns });
            fetchCompanies();
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de mettre à jour' });
        }
    };

    const handleSaveEdit = async () => {
        try {
            // Géocodage automatique
            let updatedCompany = { ...editingCompany };
            try {
                const geoRes = await fetch(`https://api-adresse.data.gouv.fr/search/?q=${updatedCompany.address}&limit=1`);
                const geoData = await geoRes.json();
                if (geoData.features?.length > 0) {
                    updatedCompany.longitude = geoData.features[0].geometry.coordinates[0];
                    updatedCompany.latitude = geoData.features[0].geometry.coordinates[1];
                }
            } catch (e) { console.error("Geocoding failed", e); }

            await api.patch(`/companies/${updatedCompany.id}/`, updatedCompany);
            setEditingCompany(null);
            fetchCompanies();
            notifications.show({ color: 'green', title: 'Succès', message: 'Entreprise mise à jour (et localisée)' });
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de sauvegarder' });
        }
    };

    const handleViewMap = (company: any) => {
        if (!company.latitude || !company.longitude) {
            notifications.show({ title: 'Pas de coordonnées', message: 'Cette entreprise n\'est pas géolocalisée.', color: 'orange' });
            return;
        }
        setFocusedCompany(company);
        setActiveTab('map');
    };

    const handleDelete = async (company: any) => {
        if (!window.confirm(`Voulez-vous vraiment supprimer "${company.name}" ?`)) return;
        try {
            await api.delete(`/companies/${company.id}`);
            notifications.show({ title: 'Supprimée', message: 'L\'entreprise a été retirée du Codex.', color: 'green' });
            fetchCompanies();
        } catch (e: any) {
            notifications.show({ 
                title: 'Impossible de supprimer', 
                message: e.response?.data?.detail || 'Une erreur est survenue.', 
                color: 'red',
                autoClose: 5000
            });
        }
    };

    const searchSirene = async (query: string) => {
        setSireneSearch(query);
        if (query.length < 3) return;
        setSireneLoading(true);
        try {
            const res = await fetch(`https://recherche-entreprises.api.gouv.fr/search?q=${query}&per_page=5`);
            const data = await res.json();
            setSireneResults(data.results);
        } catch (e) { console.error(e); }
        setSireneLoading(false);
    };

    const applySireneData = (r: any) => {
        setEditingCompany({
            ...editingCompany,
            name: r.nom_complet,
            address: r.siege.adresse,
            longitude: r.siege.longitude || editingCompany.longitude,
            latitude: r.siege.latitude || editingCompany.latitude
        });
        setShowSireneSearch(false);
        setSireneSearch('');
        setSireneResults([]);
    };

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="blue.0">
                    <Group justify="space-between">
                        <Group>
                            <IconBriefcase color="#228be6" />
                            <Title order={3}>Codex Entreprises</Title>
                        </Group>
                        <Group>
                            <Tabs value={activeTab} onChange={setActiveTab} variant="pills" radius="xl" size="xs">
                                <Tabs.List>
                                    <Tabs.Tab value="list" leftSection={<IconList size={14} />}>Liste</Tabs.Tab>
                                    <Tabs.Tab value="map" leftSection={<IconMap2 size={14} />}>Carte</Tabs.Tab>
                                </Tabs.List>
                            </Tabs>
                            <TextInput 
                                placeholder="Rechercher..." 
                                leftSection={<IconSearch size={16} />}
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                w={200}
                            />
                        </Group>
                    </Group>
                </Paper>

                {activeTab === 'list' ? (
                    <Paper withBorder radius="md" p="md">
                        {loading ? (
                            <Center h={200}><Loader /></Center>
                        ) : (
                            <Table striped highlightOnHover verticalSpacing="sm">
                                <Table.Thead>
                                    <Table.Tr>
                                        <Table.Th>Entreprise</Table.Th>
                                        <Table.Th>Coordonnées</Table.Th>
                                        <Table.Th>Stagiaires</Table.Th>
                                        <Table.Th>Statut</Table.Th>
                                        <Table.Th>Actions</Table.Th>
                                    </Table.Tr>
                                </Table.Thead>
                                <Table.Tbody>
                                    {companies.map((c) => (
                                        <Table.Tr key={c.id}>
                                            <Table.Td>
                                                <Group gap="sm">
                                                    <CompanyLogo website={c.website} />
                                                    <div>
                                                        <Text fw={700}>{c.name}</Text>
                                                        <Text size="xs" c="dimmed">{c.address || 'Pas d\'adresse'}</Text>
                                                    </div>
                                                </Group>
                                            </Table.Td>
                                            <Table.Td>
                                                <Stack gap={2}>
                                                    {c.email && <Group gap={5}><IconMail size={12} /><Text size="xs">{c.email}</Text></Group>}
                                                    {c.phone && <Group gap={5}><IconPhone size={12} /><Text size="xs">{c.phone}</Text></Group>}
                                                    {c.website && <Group gap={5}><IconWorld size={12} /><Text size="xs">{c.website}</Text></Group>}
                                                </Stack>
                                            </Table.Td>
                                            <Table.Td>
                                                <Badge color="blue" variant="light">{stats[c.id] || 0} stagiaires</Badge>
                                            </Table.Td>
                                            <Table.Td>
                                                <Switch 
                                                    label={c.accepts_interns ? "Accepte" : "N'accepte plus"}
                                                    checked={c.accepts_interns}
                                                    onChange={() => handleToggleInterns(c)}
                                                    size="xs"
                                                    color="green"
                                                />
                                            </Table.Td>
                                            <Table.Td>
                                                <Group gap="xs">
                                                    <ActionIcon variant="subtle" color="blue" title="Historique" onClick={() => loadHistory(c)}>
                                                        <IconHistory size={18} />
                                                    </ActionIcon>
                                                    <ActionIcon variant="subtle" color="green" title="Voir sur la carte" onClick={() => handleViewMap(c)} disabled={!c.latitude}>
                                                        <IconMap2 size={18} />
                                                    </ActionIcon>
                                                    <ActionIcon variant="subtle" title="Modifier" onClick={() => setEditingCompany(c)}>
                                                        <IconEdit size={18} />
                                                    </ActionIcon>
                                                    <ActionIcon variant="subtle" color="red" title="Supprimer (si aucun stage)" onClick={() => handleDelete(c)}>
                                                        <IconTrash size={18} />
                                                    </ActionIcon>
                                                </Group>
                                            </Table.Td>
                                        </Table.Tr>
                                    ))}
                                </Table.Tbody>
                            </Table>
                        )}
                    </Paper>
                ) : (
                    <CompanyMapView companies={companies} focusOn={focusedCompany} />
                )}
            </Stack>

            <Modal opened={!!historyCompany} onClose={() => setHistoryCompany(null)} title={`Historique - ${historyCompany?.name}`} size="xl">
                {historyLoading ? <Center h={100}><Loader /></Center> : (
                    <Table>
                        <Table.Thead>
                            <Table.Tr>
                                <Table.Th>Année</Table.Th>
                                <Table.Th>Étudiant</Table.Th>
                                <Table.Th>Tuteur Entreprise</Table.Th>
                                <Table.Th>Dates</Table.Th>
                                <Table.Th>Statut</Table.Th>
                            </Table.Tr>
                        </Table.Thead>
                        <Table.Tbody>
                            {historyData.length === 0 ? (
                                <Table.Tr><Table.Td colSpan={5} align="center"><Text c="dimmed">Aucun historique trouvé.</Text></Table.Td></Table.Tr>
                            ) : historyData.map((h: any) => (
                                <Table.Tr key={h.id}>
                                    <Table.Td>{h.academic_year}</Table.Td>
                                    <Table.Td>{h.student_name}</Table.Td>
                                    <Table.Td>{h.supervisor_name || 'Non renseigné'}</Table.Td>
                                    <Table.Td>
                                        {h.start_date ? `${new Date(h.start_date).toLocaleDateString()} - ${new Date(h.end_date).toLocaleDateString()}` : 'Dates non définies'}
                                    </Table.Td>
                                    <Table.Td>
                                        <Badge color={h.is_active ? 'green' : 'gray'}>{h.is_active ? 'En cours' : 'Archivé'}</Badge>
                                    </Table.Td>
                                </Table.Tr>
                            ))}
                        </Table.Tbody>
                    </Table>
                )}
            </Modal>

            <Modal opened={!!editingCompany} onClose={() => setEditingCompany(null)} title="Modifier l'entreprise" size="lg">
                {editingCompany && (
                    <Stack>
                        {!showSireneSearch ? (
                            <Button variant="light" color="grape" onClick={() => { setShowSireneSearch(true); searchSirene(editingCompany.name); }} leftSection={<IconWorld size={18} />}>
                                Rechercher infos officielles (Sirene)
                            </Button>
                        ) : (
                            <Paper withBorder p="sm" bg="gray.0">
                                <Group mb="xs">
                                    <TextInput 
                                        placeholder="Nom officiel..." 
                                        value={sireneSearch} 
                                        onChange={(e) => searchSirene(e.target.value)} 
                                        style={{ flex: 1 }}
                                        rightSection={sireneLoading && <Loader size="xs" />}
                                    />
                                    <ActionIcon onClick={() => setShowSireneSearch(false)}><IconX size={16} /></ActionIcon>
                                </Group>
                                <Stack gap="xs">
                                    {sireneResults.map((r: any) => (
                                        <Paper 
                                            key={r.siren} 
                                            p="xs" 
                                            withBorder 
                                            style={{ cursor: 'pointer' }} 
                                            onClick={() => applySireneData(r)}
                                            bg="white"
                                        >
                                            <Text size="sm" fw={700}>{r.nom_complet}</Text>
                                            <Text size="xs" c="dimmed">{r.siege.adresse}</Text>
                                        </Paper>
                                    ))}
                                </Stack>
                            </Paper>
                        )}

                        <TextInput label="Nom" value={editingCompany.name} onChange={(e) => setEditingCompany({...editingCompany, name: e.target.value})} />
                        <TextInput label="Adresse" value={editingCompany.address || ''} onChange={(e) => setEditingCompany({...editingCompany, address: e.target.value})} />
                        <Group grow>
                            <TextInput label="Email" value={editingCompany.email || ''} onChange={(e) => setEditingCompany({...editingCompany, email: e.target.value})} />
                            <TextInput label="Téléphone" value={editingCompany.phone || ''} onChange={(e) => setEditingCompany({...editingCompany, phone: e.target.value})} />
                        </Group>
                        <TextInput label="Site Web" value={editingCompany.website || ''} onChange={(e) => setEditingCompany({...editingCompany, website: e.target.value})} />
                        <Group justify="flex-end" mt="md">
                            <Button variant="default" onClick={() => setEditingCompany(null)}>Annuler</Button>
                            <Button onClick={handleSaveEdit}>Enregistrer</Button>
                        </Group>
                    </Stack>
                )}
            </Modal>

            <Center mt="xl">
                <Text size="xs" c="dimmed" fs="italic">
                    Usage interne uniquement. Les données des entreprises et des tuteurs sont confidentielles et soumises au RGPD.
                </Text>
            </Center>
        </Container>
    );
}
