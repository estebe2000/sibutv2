import React, { useState, useEffect } from 'react';
import {
  Table,
  Button,
  Group,
  Text,
  Modal,
  TextInput,
  Stack,
  ActionIcon,
  Badge,
  Paper,
  Title,
  PasswordInput,
  LoadingOverlay,
  Switch
} from '@mantine/core';
import { IconPlus, IconTrash, IconUser, IconRefresh, IconKey } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function KeycloakUserManagement() {
  const [users, setUsers] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [showLdap, setShowLdap] = useState(false);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isResetModalOpen, setIsResetModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [newPassword, setNewPassword] = useState('');
  const [newUser, setNewUser] = useState({
    username: '',
    email: '',
    first_name: '',
    last_name: '',
    password: ''
  });

  const fetchUsers = async (query: string = '') => {
    if (loading) return;
    setLoading(true);
    try {
      const url = query ? `/keycloak/users?q=${query.trim()}` : '/keycloak/users';
      const res = await api.get(url);
      setUsers(Array.isArray(res.data) ? res.data : []);
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de récupérer les utilisateurs' });
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchUsers('');
  }, []);

  useEffect(() => {
    if (search === '') return;
    const delayDebounceFn = setTimeout(() => {
      fetchUsers(search);
    }, 500);
    return () => clearTimeout(delayDebounceFn);
  }, [search]);

  const handleCreate = async () => {
    try {
      await api.post('/keycloak/users', newUser);
      notifications.show({ color: 'green', title: 'Succès', message: 'Utilisateur créé' });
      setIsModalOpen(false);
      setNewUser({ username: '', email: '', first_name: '', last_name: '', password: '' });
      fetchUsers(search);
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la création' });
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm("Supprimer cet utilisateur ?")) return;
    try {
      await api.delete(`/keycloak/users/${id}`);
      notifications.show({ color: 'green', title: 'Succès', message: 'Utilisateur supprimé' });
      fetchUsers(search);
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la suppression' });
    }
  };

  const handleResetPassword = async () => {
    if (!newPassword) return;
    try {
      await api.put(`/keycloak/users/${selectedUser.id}/reset-password`, { password: newPassword });
      notifications.show({ color: 'green', title: 'Succès', message: 'Mot de passe réinitialisé' });
      setIsResetModalOpen(false);
      setNewPassword('');
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la réinitialisation' });
    }
  };

  return (
    <Paper withBorder p="md" shadow="xs" style={{ position: 'relative' }}>
      <LoadingOverlay visible={loading} />
      <Group justify="space-between" mb="md">
        <Title order={4}>Comptes Locaux (Keycloak)</Title>
        <Group>
          <TextInput 
            placeholder="Rechercher..." 
            size="xs" 
            w={200}
            value={search}
            onChange={(e) => setSearch(e.currentTarget.value)}
          />
          <Switch 
            label="LDAP" 
            checked={showLdap} 
            onChange={(event) => setShowLdap(event.currentTarget.checked)} 
          />
          <Button variant="light" size="xs" leftSection={<IconRefresh size={14} />} onClick={() => fetchUsers(search)}>Actualiser</Button>
          <Button size="xs" leftSection={<IconPlus size={14} />} onClick={() => setIsModalOpen(true)}>Nouvel Utilisateur</Button>
        </Group>
      </Group>

      <Table highlightOnHover verticalSpacing="xs">
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Identifiant</Table.Th>
            <Table.Th>Nom Complet</Table.Th>
            <Table.Th>Email</Table.Th>
            <Table.Th>Type</Table.Th>
            <Table.Th align="right">Actions</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {users
            .filter(user => showLdap || !user.federationLink)
            .map((user) => {
              const isLdap = !!user.federationLink;
              return (
              <Table.Tr key={user.id}>
                <Table.Td><Group gap="xs"><IconUser size={14} color="gray" /><Text size="sm">{user.username}</Text></Group></Table.Td>
                <Table.Td>{user.firstName} {user.lastName}</Table.Td>
                <Table.Td>{user.email}</Table.Td>
                <Table.Td>
                  {isLdap ? <Badge color="blue" size="xs">LDAP</Badge> : <Badge color="green" size="xs">Local</Badge>}
                </Table.Td>
                <Table.Td>
                  <Group justify="flex-end" gap={5}>
                    {!isLdap && (
                      <>
                        <ActionIcon color="blue" variant="subtle" size="sm" onClick={() => { setSelectedUser(user); setIsResetModalOpen(true); }} title="Réinitialiser le mot de passe">
                          <IconKey size={14} />
                        </ActionIcon>
                        <ActionIcon color="red" variant="subtle" size="sm" onClick={() => handleDelete(user.id)} title="Supprimer">
                          <IconTrash size={14} />
                        </ActionIcon>
                      </>
                    )}
                  </Group>
                </Table.Td>
              </Table.Tr>
            );
          })}
        </Table.Tbody>
      </Table>

      <Modal opened={isModalOpen} onClose={() => setIsModalOpen(false)} title="Créer un compte local">
        <Stack>
          <TextInput label="Identifiant" placeholder="j.doe" value={newUser.username} onChange={(e) => setNewUser({...newUser, username: e.target.value})} required />
          <TextInput label="Prénom" placeholder="John" value={newUser.first_name} onChange={(e) => setNewUser({...newUser, first_name: e.target.value})} />
          <TextInput label="Nom" placeholder="Doe" value={newUser.last_name} onChange={(e) => setNewUser({...newUser, last_name: e.target.value})} />
          <TextInput label="Email" placeholder="john.doe@example.com" value={newUser.email} onChange={(e) => setNewUser({...newUser, email: e.target.value})} required />
          <PasswordInput label="Mot de passe" value={newUser.password} onChange={(e) => setNewUser({...newUser, password: e.target.value})} required />
          <Button fullWidth mt="md" onClick={handleCreate}>Créer l'utilisateur</Button>
        </Stack>
      </Modal>

      <Modal opened={isResetModalOpen} onClose={() => setIsResetModalOpen(false)} title={`Réinitialiser le mot de passe : ${selectedUser?.username}`}>
        <Stack>
          <PasswordInput label="Nouveau mot de passe" value={newPassword} onChange={(e) => setNewPassword(e.target.value)} required />
          <Button fullWidth mt="md" onClick={handleResetPassword}>Valider le nouveau mot de passe</Button>
        </Stack>
      </Modal>
    </Paper>
  );
}