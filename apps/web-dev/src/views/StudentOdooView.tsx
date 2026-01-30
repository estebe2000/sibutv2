import React from 'react';
import { Container, Paper, Title, Text, Stack, Center } from '@mantine/core';
import { IconDatabase } from '@tabler/icons-react';
import OdooWidget from '../components/OdooWidget';

export function StudentOdooView() {
    return (
        <Container size="md" py="xl">
            <Stack gap="xl">
                <Paper withBorder p="xl" radius="md" bg="gray.0">
                    <Stack align="center" gap="xs">
                        <IconDatabase size={40} color="var(--mantine-color-indigo-6)" />
                        <Title order={3}>Mon Espace ERP (Odoo)</Title>
                        <Text c="dimmed" ta="center">
                            Gérez votre entreprise virtuelle et apprenez les processus de gestion.
                        </Text>
                    </Stack>
                </Paper>

                <OdooWidget />
            </Stack>
        </Container>
    );
}
