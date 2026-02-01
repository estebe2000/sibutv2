import React, { useState } from 'react';
import { Container, Paper, Title, Text, Stack, Group, ThemeIcon, Badge, Card, SimpleGrid, ScrollArea, ActionIcon, Tooltip, Box } from '@mantine/core';
import { Calendar } from '@mantine/dates';
import { IconCalendar, IconChevronLeft, IconChevronRight, IconClock, IconMapPin, IconInfoCircle, IconTarget, IconBriefcase } from '@tabler/icons-react';
import dayjs from 'dayjs';
import 'dayjs/locale/fr';

// Mock data for academic events
const MOCK_EVENTS = [
    { date: dayjs().set('hour', 9).set('minute', 0).toDate(), title: 'Marketing Stratégique', type: 'COURSE', location: 'Amphi A', duration: '2h' },
    { date: dayjs().set('hour', 14).set('minute', 30).toDate(), title: 'SAÉ 3.01 : Étude de marché', type: 'SAE', location: 'Salle 204', duration: '3h' },
    { date: dayjs().add(1, 'day').set('hour', 10).toDate(), title: 'Anglais Business', type: 'COURSE', location: 'Salle 105', duration: '1h30' },
    { date: dayjs().add(2, 'day').toDate(), title: 'Date limite Rapport de Stage', type: 'INTERNSHIP', location: 'En ligne', duration: 'Toute la journée' },
    { date: dayjs().subtract(1, 'day').toDate(), title: 'Réunion Mentorat', type: 'OTHER', location: 'Bureau 12', duration: '45m' },
];

export function CalendarView() {
    const [selectedDate, setSelectedDate] = useState<Date | null>(new Date());
    const [viewDate, setViewDate] = useState(new Date());

    const getEventsForDate = (date: Date) => {
        return MOCK_EVENTS.filter(event => dayjs(event.date).isSame(date, 'day'));
    };

    const getTypeColor = (type: string) => {
        switch (type) {
            case 'COURSE': return 'blue';
            case 'SAE': return 'violet';
            case 'INTERNSHIP': return 'orange';
            default: return 'gray';
        }
    };

    const getTypeIcon = (type: string) => {
        switch (type) {
            case 'COURSE': return <IconClock size={14} />;
            case 'SAE': return <IconTarget size={14} />;
            case 'INTERNSHIP': return <IconBriefcase size={14} />;
            default: return <IconInfoCircle size={14} />;
        }
    };

    const dayEvents = selectedDate ? getEventsForDate(selectedDate) : [];

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Group justify="space-between">
                    <Group>
                        <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                            <IconCalendar size={24} />
                        </ThemeIcon>
                        <div>
                            <Title order={3}>Mon Calendrier Académique</Title>
                            <Text size="xs" c="dimmed">Synchronisé avec Hyperplanning (Beta)</Text>
                        </div>
                    </Group>
                    <Badge color="yellow" variant="outline" size="lg">BUT TC - S3</Badge>
                </Group>

                <SimpleGrid cols={{ base: 1, md: 2 }} spacing="lg">
                    {/* Left Column: Interactive Calendar */}
                    <Paper withBorder p="md" radius="md" shadow="sm">
                        <Stack align="center">
                            <Calendar
                                locale="fr"
                                value={selectedDate}
                                onChange={setSelectedDate}
                                onMonthSelect={setViewDate}
                                size="md"
                                static={false}
                                renderDay={(date) => {
                                    const d = dayjs(date);
                                    const events = getEventsForDate(date);
                                    return (
                                        <Box pos="relative" w="100%" h="100%" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                            <Text size="sm">{d.date()}</Text>
                                            {events.length > 0 && (
                                                <Group gap={2} justify="center" pos="absolute" bottom={2} left={0} right={0}>
                                                    {events.slice(0, 3).map((e, i) => (
                                                        <Box 
                                                            key={i} 
                                                            w={4} h={4} 
                                                            style={{ borderRadius: '50%' }} 
                                                            bg={`${getTypeColor(e.type)}.6`} 
                                                        />
                                                    ))}
                                                </Group>
                                            )}
                                        </Box>
                                    );
                                }}
                            />
                        </Stack>
                    </Paper>

                    {/* Right Column: Day Details */}
                    <Stack gap="md">
                        <Paper withBorder p="md" radius="md" bg="gray.0">
                            <Group justify="space-between" mb="md">
                                <Title order={4}>Événements du {dayjs(selectedDate).format('DD MMMM YYYY')}</Title>
                                <Badge variant="light" color="gray">{dayEvents.length} activité(s)</Badge>
                            </Group>

                            <ScrollArea h={400} offsetScrollbars>
                                <Stack gap="sm">
                                    {dayEvents.length > 0 ? (
                                        dayEvents.map((event, index) => (
                                            <Card key={index} withBorder shadow="xs" radius="md" style={{ borderLeft: `4px solid var(--mantine-color-${getTypeColor(event.type)}-6)` }}>
                                                <Group justify="space-between" mb="xs">
                                                    <Badge color={getTypeColor(event.type)} variant="light" leftSection={getTypeIcon(event.type)}>
                                                        {event.type}
                                                    </Badge>
                                                    <Group gap={5} c="dimmed">
                                                        <IconClock size={12} />
                                                        <Text size="xs">{dayjs(event.date).format('HH:mm')} ({event.duration})</Text>
                                                    </Group>
                                                </Group>
                                                <Title order={5} mb={5}>{event.title}</Title>
                                                <Group gap="xs" c="dimmed">
                                                    <IconMapPin size={14} />
                                                    <Text size="xs">{event.location}</Text>
                                                </Group>
                                            </Card>
                                        ))
                                    ) : (
                                        <Paper p="xl" withBorder style={{ borderStyle: 'dashed' }} bg="transparent">
                                            <Stack align="center" gap="xs">
                                                <IconInfoCircle size={30} color="var(--mantine-color-gray-4)" />
                                                <Text c="dimmed" size="sm" ta="center">Aucun événement prévu pour cette journée.</Text>
                                            </Stack>
                                        </Paper>
                                    )}
                                </Stack>
                            </ScrollArea>
                        </Paper>

                        {/* Legend / Info */}
                        <Card withBorder radius="md" p="sm">
                            <Group grow>
                                <Stack gap={5}>
                                    <Group gap="xs">
                                        <Box w={8} h={8} style={{ borderRadius: '50%' }} bg="blue.6" />
                                        <Text size="xs">Cours Magistraux / TD</Text>
                                    </Group>
                                    <Group gap="xs">
                                        <Box w={8} h={8} style={{ borderRadius: '50%' }} bg="violet.6" />
                                        <Text size="xs">SAÉ & Projets</Text>
                                    </Group>
                                </Stack>
                                <Stack gap={5}>
                                    <Group gap="xs">
                                        <Box w={8} h={8} style={{ borderRadius: '50%' }} bg="orange.6" />
                                        <Text size="xs">Stages & Entreprises</Text>
                                    </Group>
                                    <Group gap="xs">
                                        <Box w={8} h={8} style={{ borderRadius: '50%' }} bg="gray.6" />
                                        <Text size="xs">Autres activités</Text>
                                    </Group>
                                </Stack>
                            </Group>
                        </Card>
                    </Stack>
                </SimpleGrid>
            </Stack>
        </Container>
    );
}
