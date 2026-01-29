import React, { useState } from 'react';
import { Stack, Group, TextInput, Button, Card, Text, Badge, ActionIcon, Loader, Center } from '@mantine/core';
import { IconSearch, IconMapPin, IconBriefcase, IconPlus, IconExternalLink } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function InternshipOffers() {
    const [query, setQuery] = useState('Marketing');
    const [location, setLocation] = useState('Rouen');
    const [results, setResults] = useState<any[]>([]);
    const [loading, setLoading] = useState(false);

    const handleSearch = async () => {
        setLoading(true);
        try {
            const res = await api.get(`/applications/search-offers?query=${query}&location=${location}`);
            setResults(res.data.results || []);
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de récupérer les offres.' });
        }
        setLoading(false);
    };

    const handleAddToTracker = async (offer: any) => {
        try {
            await api.post('/applications/', {
                company_name: offer.company,
                position_title: offer.title,
                url: offer.url,
                notes: `Source: ${offer.source} - ${offer.place}`,
                status: 'APPLIED' // On considère qu'on l'ajoute pour postuler
            });
            notifications.show({ color: 'green', title: 'Ajouté', message: 'Offre ajoutée à votre suivi !' });
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: "Erreur lors de l'ajout." });
        }
    };

    return (
        <Stack gap="lg">
            <Group align="flex-end">
                <TextInput 
                    label="Métier / Mots-clés" 
                    placeholder="Ex: Marketing, Communication..." 
                    value={query} 
                    onChange={(e) => setQuery(e.target.value)} 
                    style={{ flex: 1 }}
                    leftSection={<IconSearch size={16} />}
                />
                <TextInput 
                    label="Ville" 
                    placeholder="Ex: Rouen, Le Havre..." 
                    value={location} 
                    onChange={(e) => setLocation(e.target.value)} 
                    style={{ flex: 1 }}
                    leftSection={<IconMapPin size={16} />}
                />
                <Button loading={loading} onClick={handleSearch}>Rechercher</Button>
            </Group>

            {loading ? (
                <Center p="xl"><Loader /></Center>
            ) : (
                <Stack gap="md">
                    <Text size="sm" c="dimmed">{results.length} offres trouvées (La Bonne Alternance / France Travail)</Text>
                    {results.map((offer) => (
                        <Card key={offer.id} withBorder shadow="sm" radius="md">
                            <Group justify="space-between" align="flex-start">
                                <div>
                                    <Text fw={700} size="lg">{offer.title}</Text>
                                    <Group gap="xs" mb="xs">
                                        <Badge color="blue" variant="light" leftSection={<IconBriefcase size={12}/>}>{offer.company}</Badge>
                                        <Badge color="gray" variant="light" leftSection={<IconMapPin size={12}/>}>{offer.place}</Badge>
                                        <Badge color={offer.is_internship ? 'green' : 'orange'} variant={offer.is_internship ? 'filled' : 'outline'}>
                                            {offer.is_internship ? 'STAGE' : offer.contract}
                                        </Badge>
                                    </Group>
                                    <Text size="xs" c="dimmed">Source: {offer.source}</Text>
                                </div>
                                <Group>
                                    {offer.url && (
                                        <ActionIcon component="a" href={offer.url} target="_blank" variant="subtle" title="Voir l'offre">
                                            <IconExternalLink size={20} />
                                        </ActionIcon>
                                    )}
                                    <Button size="xs" leftSection={<IconPlus size={16}/>} onClick={() => handleAddToTracker(offer)}>
                                        Suivre
                                    </Button>
                                </Group>
                            </Group>
                        </Card>
                    ))}
                </Stack>
            )}
        </Stack>
    );
}
