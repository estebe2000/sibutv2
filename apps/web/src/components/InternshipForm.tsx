import React, { useState, useEffect } from 'react';
import { Paper, Title, TextInput, Stack, Button, Group, Text, Divider, Alert, ThemeIcon, Badge, Autocomplete, Loader } from '@mantine/core';
import { IconBriefcase, IconDeviceFloppy, IconInfoCircle, IconSearch } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function InternshipForm({ studentUid }: { studentUid: string }) {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    
    const [companySearch, setCompanySearch] = useState('');
    const [companySuggestions, setCompanySuggestions] = useState<any[]>([]);
    const [suggestionsLoading, setSuggestionsLoading] = useState(false);

    useEffect(() => {
        api.get(`/internships/${studentUid}`).then(res => {
            setData(res.data);
            setCompanySearch(res.data.company_name || '');
            setLoading(false);
        });
    }, [studentUid]);

    useEffect(() => {
        if (companySearch.length > 2) {
            setSuggestionsLoading(true);
            const timer = setTimeout(async () => {
                try {
                    // 1. Recherche Locale (Codex)
                    const localReq = api.get(`/companies/?search=${companySearch}`);
                    
                    // 2. Recherche API Sirene (Publique)
                    const extReq = fetch(`https://recherche-entreprises.api.gouv.fr/search?q=${companySearch}&per_page=5`);

                    const [localRes, extRes] = await Promise.allSettled([localReq, extReq]);

                    let mergedResults: any[] = [];

                    // Traitement résultats locaux
                    if (localRes.status === 'fulfilled') {
                        mergedResults = [...localRes.value.data.map((c: any) => ({ ...c, source: 'local' }))];
                    }

                    // Traitement résultats API Sirene
                    if (extRes.status === 'fulfilled') {
                        const extData = await extRes.value.json();
                        const sirenResults = extData.results.map((r: any) => ({
                            name: r.nom_complet,
                            address: r.siege.adresse,
                            source: 'sirene',
                            siret: r.siren,
                            // On ajoute un label unique pour l'affichage (avec CP)
                            uniqueLabel: `🌍 ${r.nom_complet} (${r.siege.code_postal || '?'} ${r.siege.libelle_commune || ''})`
                        }));
                        
                        // Filtrer les doublons (si le nom existe déjà en local, on ne l'affiche pas deux fois)
                        const localNames = new Set(mergedResults.map(l => l.name.toLowerCase()));
                        sirenResults.forEach((s: any) => {
                            if (!localNames.has(s.name.toLowerCase())) {
                                mergedResults.push(s);
                            }
                        });
                    }

                    setCompanySuggestions(mergedResults);
                } catch (e) { console.error(e); }
                setSuggestionsLoading(false);
            }, 400); // Debounce un peu plus long (400ms) pour éviter de spammer l'API publique
            return () => clearTimeout(timer);
        } else {
            setCompanySuggestions([]);
        }
    }, [companySearch]);

    const handleSelectCompany = (val: string) => {
        // Recherche dans les suggestions par label affiché OU par nom (pour fallback)
        const company = companySuggestions.find(c => {
             const label = c.source === 'local' ? c.name : c.uniqueLabel;
             return label === val || c.name === val;
        });

        if (company) {
            setData({
                ...data,
                company_id: company.source === 'local' ? company.id : null, 
                company_name: company.name,
                company_address: company.address || data.company_address,
                company_phone: company.source === 'local' ? (company.phone || data.company_phone) : data.company_phone, 
                company_email: company.source === 'local' ? (company.email || data.company_email) : data.company_email
            });
            setCompanySearch(company.name); // On remet le vrai nom propre dans le champ
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            // First, if company_id is not set but name is provided, let's try to find/create it
            let finalData = { ...data, company_name: companySearch };
            
            if (!data.company_id && companySearch) {
                const cRes = await api.post('/companies/', { name: companySearch, address: data.company_address, phone: data.company_phone, email: data.company_email });
                finalData.company_id = cRes.data.id;
            }

            await api.patch(`/internships/${studentUid}`, finalData);
            notifications.show({ title: 'Succès', message: 'Informations de stage enregistrées', color: 'green' });
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
        }
        setSaving(false);
    };

    if (loading) return <Text size="sm" c="dimmed">Chargement de la fiche de stage...</Text>;

    return (
        <Paper withBorder p="md" radius="md" shadow="xs">
            <Stack gap="md">
                <Group justify="space-between">
                    <Group gap="xs">
                        <ThemeIcon color="blue" variant="light"><IconBriefcase size={18} /></ThemeIcon>
                        <Title order={4}>Mon Stage</Title>
                    </Group>
                    {data.start_date && (
                        <Badge color="blue">
                            Du {new Date(data.start_date).toLocaleDateString()} au {new Date(data.end_date).toLocaleDateString()}
                        </Badge>
                    )}
                </Group>

                {!data.start_date && (
                    <Alert icon={<IconInfoCircle size={16} />} color="blue" variant="light">
                        Les dates de votre stage seront renseignées par votre tuteur enseignant.
                    </Alert>
                )}

                <Divider label="L'Entreprise" labelPosition="center" />
                
                <Autocomplete
                    label="Nom de l'entreprise"
                    placeholder="Tapez le nom pour rechercher ou ajouter..."
                    data={companySuggestions.map(c => c.source === 'local' ? c.name : c.uniqueLabel)}
                    value={companySearch}
                    onChange={setCompanySearch}
                    onOptionSubmit={handleSelectCompany}
                    rightSection={suggestionsLoading ? <Loader size="xs" /> : <IconSearch size={14} />}
                />

                <TextInput label="Adresse" value={data.company_address || ''} onChange={(e) => setData({...data, company_address: e.target.value})} />
                <Group grow>
                    <TextInput label="Téléphone" value={data.company_phone || ''} onChange={(e) => setData({...data, company_phone: e.target.value})} />
                    <TextInput label="Email contact" value={data.company_email || ''} onChange={(e) => setData({...data, company_email: e.target.value})} />
                </Group>

                <Divider label="L'Encadrant Professionnel (Maître de stage)" labelPosition="center" mt="md" />
                <TextInput label="Nom du tuteur entreprise" value={data.supervisor_name || ''} onChange={(e) => setData({...data, supervisor_name: e.target.value})} />
                <Group grow>
                    <TextInput label="Téléphone encadrant" value={data.supervisor_phone || ''} onChange={(e) => setData({...data, supervisor_phone: e.target.value})} />
                    <TextInput label="Email encadrant" value={data.supervisor_email || ''} onChange={(e) => setData({...data, supervisor_email: e.target.value})} />
                </Group>

                <Button leftSection={<IconDeviceFloppy size={16} />} onClick={handleSave} loading={saving} mt="md">
                    Enregistrer mes informations
                </Button>
            </Stack>
        </Paper>
    );
}