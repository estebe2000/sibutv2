import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Select, Divider, Loader, Center } from '@mantine/core';
import { IconBriefcase, IconUsers } from '@tabler/icons-react';
import api from '../services/api';
import { ProfessorInternshipManager } from '../components/ProfessorInternshipManager';
import { useMediaQuery } from '@mantine/hooks';

export function InternshipManagementView({ user }: { user: any }) {
    const isMobile = useMediaQuery('(max-width: 768px)');
    const [tutoredStudents, setTutoredStudents] = useState<any[]>([]);
    const [selectedStudentUid, setSelectedStudentUid] = useState<string | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStudents = async () => {
            try {
                const res = await api.get(`/activity-management/teacher/${user.ldap_uid}/tutored-students`);
                setTutoredStudents(res.data);
                if (res.data.length > 0) {
                    setSelectedStudentUid(res.data[0].ldap_uid);
                }
                setLoading(false);
            } catch (e) { console.error(e); setLoading(false); }
        };
        fetchStudents();
    }, [user.ldap_uid]);

    const selectedStudent = tutoredStudents.find(s => s.ldap_uid === selectedStudentUid);

    if (loading) return <Center h="50vh"><Loader /></Center>;

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="blue.0">
                    <Stack gap="xs">
                        <Group justify={isMobile ? 'center' : 'flex-start'}>
                            <IconBriefcase color="#228be6" />
                            <Title order={3}>Suivi de Stage</Title>
                        </Group>
                        <Select 
                            label="Étudiant à évaluer"
                            placeholder="Choisir..."
                            data={tutoredStudents.map(s => ({ value: s.ldap_uid, label: s.full_name }))}
                            value={selectedStudentUid}
                            onChange={setSelectedStudentUid}
                            style={{ width: isMobile ? '100%' : 300 }}
                            leftSection={<IconUsers size={16} />}
                        />
                    </Stack>
                </Paper>

                {selectedStudent ? (
                    <ProfessorInternshipManager student={selectedStudent} />
                ) : (
                    <Center h="30vh">
                        <Text c="dimmed">Aucun étudiant assigné pour le tutorat.</Text>
                    </Center>
                )}
            </Stack>
        </Container>
    );
}