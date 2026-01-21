import React, { useState, useEffect } from 'react';
import { Stack, Group, TextInput, Button, Divider, Text, Paper, Title } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { IconDeviceFloppy } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function ProfessorInternshipManager({ student }: { student: any }) {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.get(`/internships/${student.ldap_uid}`).then(res => {
            setData(res.data);
            setLoading(false);
        });
    }, [student.ldap_uid]);

    const handleSaveDates = async () => {
        try {
            await api.patch(`/internships/${student.ldap_uid}`, {
                start_date: data.start_date,
                end_date: data.end_date
            });
            notifications.show({ title: 'Succès', message: 'Dates enregistrées' });
        } catch (e) { console.error(e); }
    };

    if (loading) return <Text>Chargement...</Text>;

    return (
        <Stack gap="md">
            <Paper withBorder p="sm" bg="blue.0">
                <Title order={5} mb="xs">Calendrier du Stage</Title>
                <Group grow>
                    <DateInput label="Date de début" value={data.start_date ? new Date(data.start_date) : null} onChange={(d) => setData({...data, start_date: d})} />
                    <DateInput label="Date de fin" value={data.end_date ? new Date(data.end_date) : null} onChange={(d) => setData({...data, end_date: d})} />
                </Group>
                <Button fullWidth mt="md" size="xs" onClick={handleSaveDates} leftSection={<IconDeviceFloppy size={14}/>}>
                    Fixer les dates
                </Button>
            </Paper>

            <Divider label="Informations Entreprise (Saisies par l'élève)" labelPosition="center" />
            <Paper withBorder p="sm">
                <Stack gap="xs">
                    <Group justify="space-between"><Text size="xs" fw={700}>ENTREPRISE :</Text><Text size="sm">{data.company_name || 'Non renseigné'}</Text></Group>
                    <Group justify="space-between"><Text size="xs" fw={700}>ADRESSE :</Text><Text size="sm">{data.company_address || 'Non renseigné'}</Text></Group>
                    <Group justify="space-between"><Text size="xs" fw={700}>EMAIL :</Text><Text size="sm">{data.company_email || 'Non renseigné'}</Text></Group>
                    <Divider />
                    <Group justify="space-between"><Text size="xs" fw={700}>ENCADRANT :</Text><Text size="sm">{data.supervisor_name || 'Non renseigné'}</Text></Group>
                    <Group justify="space-between"><Text size="xs" fw={700}>TEL :</Text><Text size="sm">{data.supervisor_phone || 'Non renseigné'}</Text></Group>
                </Stack>
            </Paper>
        </Stack>
    );
}
