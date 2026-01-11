import React from 'react';
import { Select, MultiSelect, Stack, Divider } from '@mantine/core';
import { IconCrown, IconUserCircle } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import axios from 'axios';

interface ResponsibilitySelectorProps {
  entity: any;
  type: string;
  professors: any[];
  onRefresh: () => void;
  apiUrl: string;
}

export function ResponsibilitySelector({ entity, type, professors, onRefresh, apiUrl }: ResponsibilitySelectorProps) {
    if (!professors) return null;
    const profOptions = professors.map((p: any) => ({ value: p.id.toString(), label: p.full_name || 'Sans nom' }));

    const handleSetOwner = async (val: string | null) => {
        try {
            await axios.post(`${apiUrl}/curriculum/assign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${val}&role_type=owner`);
            notifications.show({ title: 'Succès', message: 'Responsable assigné' });
            onRefresh();
        } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec assignation' }); }
    };

    const handleSetIntervenants = async (values: string[]) => {
        const currentIds = entity?.intervenants?.map((u: any) => u.id.toString()) || [];
        const added = values.filter(v => !currentIds.includes(v));
        const removed = currentIds.filter(v => !values.includes(v));

        try {
            for (const id of added) {
                await axios.post(`${apiUrl}/curriculum/assign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${id}&role_type=intervenant`);
            }
            for (const id of removed) {
                await axios.post(`${apiUrl}/curriculum/unassign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${id}&role_type=intervenant`);
            }
            if (added.length > 0 || removed.length > 0) onRefresh();
        } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec mise à jour intervenants' }); }
    };

    return (
        <Stack gap="xs" mt="md">
            <Divider label="Gouvernance" labelPosition="center" />
            <Select
                label="Responsable Principal"
                placeholder="Choisir un responsable"
                data={profOptions}
                value={entity?.owner_id?.toString() || null}
                onChange={handleSetOwner}
                searchable
                leftSection={<IconCrown size={16} color="gold" />}
            />
            <MultiSelect
                label="Intervenants"
                placeholder="Ajouter des intervenants"
                data={profOptions}
                value={entity?.intervenants?.map((u: any) => u.id.toString()) || []}
                onChange={handleSetIntervenants}
                searchable
                leftSection={<IconUserCircle size={16} />}
            />
        </Stack>
    );
}
