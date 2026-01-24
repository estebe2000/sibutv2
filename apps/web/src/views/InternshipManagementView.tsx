import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Select, Divider, Loader, Center } from '@mantine/core';
import { IconBriefcase, IconUsers } from '@tabler/icons-react';
import api from '../services/api';
import { ProfessorInternshipManager } from '../components/ProfessorInternshipManager';

export function InternshipManagementView({ user }: { user: any }) {
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
                    <Group justify="space-between">
                        <Group>
                            <IconBriefcase color="#228be6" />
                            <Title order={3}>Gestion du Tutorat de Stage</Title>
                        </Group>
                        <Select 
                            label="Sélectionner un étudiant"
                            placeholder="Choisir dans la liste"
                            data={tutoredStudents.map(s => ({ value: s.ldap_uid, label: s.full_name }))}
                            value={selectedStudentUid}
                            onChange={setSelectedStudentUid}
                            style={{ width: 300 }}
                            leftSection={<IconUsers size={16} />}
                        />
                    </Group>
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
