import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Select, Divider, Loader, Center, ActionIcon } from '@mantine/core';
import { IconBriefcase, IconUsers, IconChevronLeft, IconChevronRight } from '@tabler/icons-react';
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
                        
                        <Group gap="xs" style={{ width: isMobile ? '100%' : 'auto' }}>
                            {isMobile && (
                                <ActionIcon 
                                    variant="default" 
                                    size="lg" 
                                    onClick={() => {
                                        const idx = tutoredStudents.findIndex(s => s.ldap_uid === selectedStudentUid);
                                        if (idx > 0) setSelectedStudentUid(tutoredStudents[idx - 1].ldap_uid);
                                    }} 
                                    disabled={tutoredStudents.findIndex(s => s.ldap_uid === selectedStudentUid) <= 0}
                                >
                                    <IconChevronLeft size={18} />
                                </ActionIcon>
                            )}
                            
                            <Select 
                                label={isMobile ? null : "Étudiant à évaluer"}
                                placeholder="Choisir..."
                                data={tutoredStudents.map(s => ({ value: s.ldap_uid, label: s.full_name }))}
                                value={selectedStudentUid}
                                onChange={setSelectedStudentUid}
                                style={{ flex: 1, maxWidth: isMobile ? 'none' : 300 }}
                                leftSection={<IconUsers size={16} />}
                            />

                            {isMobile && (
                                <ActionIcon 
                                    variant="default" 
                                    size="lg" 
                                    onClick={() => {
                                        const idx = tutoredStudents.findIndex(s => s.ldap_uid === selectedStudentUid);
                                        if (idx < tutoredStudents.length - 1) setSelectedStudentUid(tutoredStudents[idx + 1].ldap_uid);
                                    }} 
                                    disabled={tutoredStudents.findIndex(s => s.ldap_uid === selectedStudentUid) >= tutoredStudents.length - 1}
                                >
                                    <IconChevronRight size={18} />
                                </ActionIcon>
                            )}
                        </Group>
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