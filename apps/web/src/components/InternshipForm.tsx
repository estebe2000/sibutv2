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
        if (companySearch.length > 1) {
            setSuggestionsLoading(true);
            const timer = setTimeout(async () => {
                try {
                    const res = await api.get(`/companies?search=${companySearch}`);
                    setCompanySuggestions(res.data);
                } catch (e) { console.error(e); }
                setSuggestionsLoading(false);
            }, 300);
            return () => clearTimeout(timer);
        } else {
            setCompanySuggestions([]);
        }
    }, [companySearch]);

    const handleSelectCompany = (val: string) => {
        const company = companySuggestions.find(c => c.name === val);
        if (company) {
            setData({
                ...data,
                company_id: company.id,
                company_name: company.name,
                company_address: company.address || data.company_address,
                company_phone: company.phone || data.company_phone,
                company_email: company.email || data.company_email
            });
            setCompanySearch(company.name);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            // First, if company_id is not set but name is provided, let's try to find/create it
            let finalData = { ...data, company_name: companySearch };
            
            if (!data.company_id && companySearch) {
                const cRes = await api.post('/companies', { name: companySearch, address: data.company_address, phone: data.company_phone, email: data.company_email });
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
                    data={companySuggestions.map(c => c.name)}
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