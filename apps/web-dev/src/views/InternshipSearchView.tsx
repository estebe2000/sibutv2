import { Container, Tabs, Title, Stack, Group, Paper, Text, TextInput, Button, Card, Badge, Loader } from '@mantine/core';
import { IconSearch, IconLayoutDashboard, IconLamp, IconExternalLink, IconFileText } from '@tabler/icons-react';
import { ApplicationTracker } from '../components/ApplicationTracker';
import { CoachingPanel } from '../components/CoachingPanel';
import { InternshipOffers } from '../components/InternshipOffers';
import { InternshipForm } from '../components/InternshipForm';
import { InternshipSelfEvaluation } from '../components/InternshipSelfEvaluation';
import { useMediaQuery } from '@mantine/hooks';

export function InternshipSearchView({ user }: { user: any }) {
    const isMobile = useMediaQuery('(max-width: 768px)');

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p={isMobile ? "sm" : "md"} radius="md" bg="blue.0">
                    <Group justify={isMobile ? "center" : "flex-start"}>
                        <IconSearch color="#228be6" />
                        <Title order={isMobile ? 4 : 3}>Hub Stages</Title>
                    </Group>
                </Paper>

                <Tabs defaultValue="tracker" variant="pills" color="blue">
                    <Tabs.List grow={isMobile} style={{ flexWrap: isMobile ? 'wrap' : 'nowrap' }}>
                        <Tabs.Tab value="tracker" leftSection={<IconLayoutDashboard size={16} />}>{isMobile ? "Suivi" : "Mes Candidatures"}</Tabs.Tab>
                        <Tabs.Tab value="search" leftSection={<IconSearch size={16} />}>{isMobile ? "Offres" : "Trouver une offre"}</Tabs.Tab>
                        <Tabs.Tab value="convention" leftSection={<IconFileText size={16} />}>{isMobile ? "Doc" : "Convention & Suivi"}</Tabs.Tab>
                        <Tabs.Tab value="coaching" leftSection={<IconLamp size={16} />}>{isMobile ? "IA" : "Coaching & IA"}</Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="tracker" pt="md">
                        <ApplicationTracker />
                    </Tabs.Panel>

                    <Tabs.Panel value="search" pt="md">
                        <InternshipOffers />
                    </Tabs.Panel>

                    <Tabs.Panel value="convention" pt="md">
                        <Stack gap="xl">
                            <InternshipForm studentUid={user.ldap_uid} />
                            <InternshipSelfEvaluation studentUid={user.ldap_uid} />
                        </Stack>
                    </Tabs.Panel>

                    <Tabs.Panel value="coaching" pt="md">
                        <CoachingPanel />
                    </Tabs.Panel>
                </Tabs>
            </Stack>
        </Container>
    );
}
