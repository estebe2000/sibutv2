import React, { useState, useEffect } from 'react';
import { Select, MultiSelect, Stack, Divider, Loader, Center, ThemeIcon, Paper } from '@mantine/core';
import { IconCrown, IconUserCircle, IconShieldCheck } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';
import { useStore } from '../store/useStore';

interface ResponsibilitySelectorProps {
  entityId: string; // ID ou Code de l'entité (ex: R1.01 ou ID activity ou UID student)
  entityType: 'RESOURCE' | 'ACTIVITY' | 'STUDENT';
  professors: any[]; 
  onRefresh: () => void;
}

export function ResponsibilitySelector({ entityId, entityType, onRefresh }: ResponsibilitySelectorProps) {
    const [loading, setLoading] = useState(false);
    const [responsibilities, setResponsibilities] = useState<any[]>([]);
    const [staffOptions, setStaffOptions] = useState<{value: string, label: string}[]>([]);
    const [targetUser, setTargetUser] = useState<any>(null);

    const fetchData = async () => {
        setLoading(true);
        try {
            // 1. Charger les responsabilités actuelles
            if (entityType === 'STUDENT') {
                const res = await api.get(`/activity-management/student/${entityId}/tutor`);
                if (res.data) setResponsibilities([{ user_id: res.data.ldap_uid, role_type: 'TUTOR' }]);
                else setResponsibilities([]);
            } else {
                const res = await api.get(`/responsibility?entity_type=${entityType}&entity_id=${entityId}`);
                setResponsibilities(res.data);
            }

            // 2. Charger les options de personnel (pour les menus déroulants)
            const resU = await api.get('/users');
            const staff = resU.data.filter((u: any) => 
                u.group_id === 1 || ['PROFESSOR', 'ADMIN', 'DEPT_HEAD', 'ADMIN_STAFF', 'STUDY_DIRECTOR'].includes(u.role)
            );
            setStaffOptions(staff.map((s: any) => ({ value: s.ldap_uid, label: s.full_name || s.ldap_uid })));
            
            // 3. Charger les infos de l'utilisateur cible (si c'est un individu)
            const tu = resU.data.find((u: any) => u.ldap_uid === entityId);
            if (tu) setTargetUser(tu);

        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, [entityId, entityType]);

    const handleSetRole = async (userId: string, roleType: 'OWNER' | 'INTERVENANT' | 'TUTOR', isAssign: boolean) => {
        try {
            if (entityType === 'STUDENT' && isAssign) {
                await api.post(`/activity-management/students/${entityId}/tutor/${userId}`);
            } else {
                const endpoint = isAssign ? '/assign-role' : '/unassign-role';
                await api.post(endpoint, { user_id: userId, entity_type: entityType, entity_id: entityId, role_type: roleType });
            }
            notifications.show({ title: 'Succès', message: 'Mise à jour effectuée', color: 'green' });
            fetchData();
            onRefresh();
        } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); } // Removed unnecessary fetchData() call here
    };

    const handleUpdateUserRole = async (newRole: string) => {
        try {
            await api.post('/users/assign', { ...targetUser, role: newRole });
            notifications.show({ title: 'Rôle mis à jour', color: 'green' });
            fetchData();
            onRefresh();
        } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); }
    };

    if (loading) return <Center p="xs"><Loader size="xs" /></Center>;

    const owner = responsibilities.find(r => r.role_type === 'OWNER' || r.role_type === 'TUTOR')?.user_id || null;
    const currentOwner = staffOptions.find(s => s.value === owner) ? owner : null;
    const intervenantIds = responsibilities.filter(r => r.role_type === 'INTERVENANT').map(r => r.user_id);

    // LOGIQUE DE VISIBILITÉ
    const isStaffTarget = targetUser && targetUser.role !== 'STUDENT';
    const isStudentTarget = targetUser && targetUser.role === 'STUDENT';
    const isResourceOrActivity = entityType !== 'STUDENT';

    return (
        <Stack gap="md">
            {/* SECTION 1 : Rôle (Visible uniquement pour le personnel) */}
            {isStaffTarget && (
                <Paper withBorder p="sm" radius="md">
                    <Divider label="Rôle & Permissions" labelPosition="center" mb="sm" />
                    <Select
                        label="Grade dans l'application"
                        description="Définit les droits d'accès aux menus."
                        data={[
                            { value: 'PROFESSOR', label: 'Enseignant (Accès standard)' },
                            { value: 'STUDY_DIRECTOR', label: 'Directeur d\'études (Gestion Promo)' },
                            { value: 'DEPT_HEAD', label: 'Directeur de Département (Accès total)' },
                            { value: 'ADMIN_STAFF', label: 'Personnel Administratif (Accès total)' },
                            { value: 'ADMIN', label: 'Administrateur Système' }
                        ]}
                        value={targetUser.role}
                        onChange={(val) => val && handleUpdateUserRole(val)}
                        leftSection={<IconShieldCheck size={16} color="blue" />}
                    />
                </Paper>
            )}

            {/* SECTION 2 : Responsabilités / Tuteur (Visible pour Étudiants, Ressources, Activités) */}
            {(isStudentTarget || isResourceOrActivity) && (
                <Paper withBorder p="sm" radius="md">
                    <Divider label="Gouvernance & Suivi" labelPosition="center" mb="sm" />
                    <Stack gap="xs">
                        <Select
                            label={isStudentTarget ? "Tuteur Référent" : "Responsable Principal"}
                            placeholder="Choisir dans la liste des enseignants"
                            data={staffOptions}
                            value={currentOwner}
                            onChange={(val) => val && handleSetRole(val, isStudentTarget ? 'TUTOR' : 'OWNER', true)}
                            searchable
                            leftSection={<IconCrown size={16} color="gold" />}
                        />

                        {isResourceOrActivity && (
                            <MultiSelect
                                label="Intervenants secondaires"
                                placeholder="Ajouter des intervenants"
                                data={staffOptions}
                                value={intervenantIds}
                                onChange={(newValues) => {
                                    const added = newValues.filter(v => !intervenantIds.includes(v));
                                    const removed = intervenantIds.filter(v => !newValues.includes(v));
                                    added.forEach(v => handleSetRole(v, 'INTERVENANT', true));
                                    removed.forEach(v => handleSetRole(v, 'INTERVENANT', false));
                                }}
                                searchable
                                leftSection={<IconUserCircle size={16} />}
                            />
                        )}
                    </Stack>
                </Paper>
            )}
        </Stack>
    );
}
