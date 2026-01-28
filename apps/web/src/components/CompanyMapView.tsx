import React, { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import { Box, Text, Avatar, Group, Button, Badge } from '@mantine/core';
import { IconBriefcase } from '@tabler/icons-react';

// Fix Leaflet Default Icon issue in React
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';

let DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

// Composant interne pour gérer le recentrage
function MapController({ center }: { center: [number, number] }) {
    const map = useMap();
    useEffect(() => {
        map.flyTo(center, 14); // Zoom niveau 14 quand on sélectionne
    }, [center, map]);
    return null;
}

export function CompanyMapView({ companies, focusOn }: { companies: any[], focusOn?: any }) {
    // Filtrer les entreprises qui ont des coordonnées
    const mappedCompanies = companies.filter(c => c.latitude && c.longitude);

    // Centrer sur la Normandie par défaut (ou la moyenne des points)
    let center: [number, number] = [49.49, 0.11]; // Le Havre
    
    if (focusOn && focusOn.latitude && focusOn.longitude) {
        center = [focusOn.latitude, focusOn.longitude];
    }

    const getLogoUrl = (website?: string) => {
        if (!website) return null;
        try {
            const domain = website.replace('https://', '').replace('http://', '').split('/')[0];
            return `https://logo.clearbit.com/${domain}`;
        } catch (e) { return null; }
    };

    return (
        <Box h={600} w="100%" style={{ borderRadius: '8px', overflow: 'hidden', border: '1px solid #eee' }}>
            <MapContainer center={center} zoom={focusOn ? 14 : 10} style={{ height: '100%', width: '100%' }}>
                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />
                {focusOn && focusOn.latitude && <MapController center={[focusOn.latitude, focusOn.longitude]} />}
                
                {mappedCompanies.map((c) => (
                    <Marker key={c.id} position={[c.latitude, c.longitude]}>
                        <Popup>
                            <Box p="xs">
                                <Group gap="xs" mb="xs">
                                    <Avatar src={getLogoUrl(c.website)} radius="sm" size="sm">
                                        <IconBriefcase size={14} />
                                    </Avatar>
                                    <Text fw={700} size="sm">{c.name}</Text>
                                </Group>
                                <Text size="xs" c="dimmed" mb="xs">{c.address}</Text>
                                <Badge color={c.accepts_interns ? 'green' : 'red'} size="xs">
                                    {c.accepts_interns ? 'Prend des stagiaires' : 'Ne prend plus'}
                                </Badge>
                            </Box>
                        </Popup>
                    </Marker>
                ))}
            </MapContainer>
        </Box>
    );
}
