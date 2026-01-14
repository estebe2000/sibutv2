import React, { useState, useEffect } from 'react';
import { Select, MultiSelect, Stack, Divider, Loader, Center } from '@mantine/core';
import { IconCrown, IconUserCircle } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

interface ResponsibilitySelectorProps {
  entityId: string; // ID ou Code de l'entité (ex: R1.01 ou ID activity)
  entityType: 'RESOURCE' | 'ACTIVITY' | 'STUDENT';
  professors: any[]; // Liste pré-chargée (optionnelle si on utilise la recherche)
  onRefresh: () => void;
}

export function ResponsibilitySelector({ entityId, entityType, onRefresh }: ResponsibilitySelectorProps) {
    const [loading, setLoading] = useState(false);
    const [responsibilities, setResponsibilities] = useState<any[]>([]);
    const [staffOptions, setStaffOptions] = useState<{value: string, label: string}[]>([]);

    const fetchResponsibilities = async () => {
        try {
            const res = await api.get(`/responsibility?entity_type=${entityType}&entity_id=${entityId}`);
            setResponsibilities(res.data);
        } catch (e) { console.error("Error fetching responsibilities", e); }
    };

    const fetchStaffOptions = async () => {
        // On récupère uniquement les membres du groupe Enseignants (ID 1)
        try {
            const res = await api.get('/users');
            const staff = res.data.filter((u: any) => u.group_id === 1);
            setStaffOptions(staff.map((s: any) => ({ value: s.ldap_uid, label: s.full_name || s.ldap_uid })));
        } catch (e) { console.error("Error fetching staff", e); }
    };

    useEffect(() => {
        setLoading(true);
        Promise.all([fetchResponsibilities(), fetchStaffOptions()]).finally(() => setLoading(false));
    }, [entityId, entityType]);

    const handleSetRole = async (userId: string, roleType: 'OWNER' | 'INTERVENANT' | 'TUTOR', isAssign: boolean) => {
        const endpoint = isAssign ? '/assign-role' : '/unassign-role';
        try {
            await api.post(endpoint, {
                user_id: userId,
                entity_type: entityType,
                entity_id: entityId,
                role_type: roleType
            });
            notifications.show({ title: 'Succès', message: 'Mise à jour effectuée', color: 'green' });
            fetchResponsibilities();
            onRefresh();
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la mise à jour', color: 'red' });
        }
    };

    const owner = responsibilities.find(r => r.role_type === 'OWNER')?.user_id || null;
    const intervenants = responsibilities.filter(r => r.role_type === 'INTERVENANT').map(r => r.user_id);

    if (loading) return <Center p="xs"><Loader size="xs" /></Center>;

    return (
        <Stack gap="xs" mt="md">
            <Divider label="Gouvernance & Responsables" labelPosition="center" />
            
            <Select
                label={entityType === 'STUDENT' ? "Tuteur Référent" : "Responsable Principal"}
                placeholder="Choisir un responsable"
                data={staffOptions}
                value={owner}
                onChange={(val) => val && handleSetRole(val, 'OWNER', true)}
                searchable
                leftSection={<IconCrown size={16} color="gold" />}
            />

            {entityType !== 'STUDENT' && (
                <MultiSelect
                    label="Intervenants"
                    placeholder="Ajouter des intervenants"
                    data={staffOptions}
                    value={intervenants}
                    onChange={(newValues) => {
                        const added = newValues.filter(v => !intervenants.includes(v));
                        const removed = intervenants.filter(v => !newValues.includes(v));
                        added.forEach(v => handleSetRole(v, 'INTERVENANT', true));
                        removed.forEach(v => handleSetRole(v, 'INTERVENANT', false));
                    }}
                    searchable
                    leftSection={<IconUserCircle size={16} />}
                />
            )}
        </Stack>
    );
}