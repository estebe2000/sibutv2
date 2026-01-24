import React, { useState, useEffect } from 'react';
import { Paper, Title, TextInput, Stack, Button, Group, Text, Divider, Alert, ThemeIcon, Badge } from '@mantine/core';
import { IconBriefcase, IconDeviceFloppy, IconInfoCircle } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function InternshipForm({ studentUid }: { studentUid: string }) {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);

    useEffect(() => {
        api.get(`/internships/${studentUid}`).then(res => {
            setData(res.data);
            setLoading(false);
        });
    }, [studentUid]);

    const handleSave = async () => {
        setSaving(true);
        try {
            await api.patch(`/internships/${studentUid}`, data);
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
                <TextInput label="Nom de l'entreprise" value={data.company_name || ''} onChange={(e) => setData({...data, company_name: e.target.value})} />
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