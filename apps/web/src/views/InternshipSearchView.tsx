import { Container, Tabs, Title, Stack, Group, Paper, Text, TextInput, Button, Card, Badge, Loader } from '@mantine/core';
import { IconSearch, IconLayoutDashboard, IconLamp, IconExternalLink, IconFileText } from '@tabler/icons-react';
import { ApplicationTracker } from '../components/ApplicationTracker';
import { CoachingPanel } from '../components/CoachingPanel';
import { InternshipOffers } from '../components/InternshipOffers';
import { InternshipForm } from '../components/InternshipForm';
import { InternshipSelfEvaluation } from '../components/InternshipSelfEvaluation';

export function InternshipSearchView({ user }: { user: any }) {
    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="blue.0">
                    <Group>
                        <IconSearch color="#228be6" />
                        <Title order={3}>Hub Stages</Title>
                    </Group>
                </Paper>

                <Tabs defaultValue="tracker" variant="outline">
                    <Tabs.List mb="md">
                        <Tabs.Tab value="tracker" leftSection={<IconLayoutDashboard size={16} />}>Mes Candidatures</Tabs.Tab>
                        <Tabs.Tab value="search" leftSection={<IconSearch size={16} />}>Trouver une offre</Tabs.Tab>
                        <Tabs.Tab value="convention" leftSection={<IconFileText size={16} />}>Ma Convention & Suivi</Tabs.Tab>
                        <Tabs.Tab value="coaching" leftSection={<IconLamp size={16} />}>Coaching & IA</Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="tracker">
                        <ApplicationTracker />
                    </Tabs.Panel>

                    <Tabs.Panel value="search">
                        <InternshipOffers />
                    </Tabs.Panel>

                    <Tabs.Panel value="convention">
                        <Stack gap="xl">
                            <InternshipForm studentUid={user.ldap_uid} />
                            <InternshipSelfEvaluation studentUid={user.ldap_uid} />
                        </Stack>
                    </Tabs.Panel>

                    <Tabs.Panel value="coaching">
                        <CoachingPanel />
                    </Tabs.Panel>
                </Tabs>
            </Stack>
        </Container>
    );
}
