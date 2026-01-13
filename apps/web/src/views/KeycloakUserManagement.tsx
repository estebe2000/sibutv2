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
import { IconPlus, IconTrash, IconUser, IconRefresh } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import axios from 'axios';

export function KeycloakUserManagement() {
  const [users, setUsers] = useState<any[]>([]);
  const [search, setSearch] = useState('');
  const [showLdap, setShowLdap] = useState(false);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newUser, setNewUser] = useState({
    username: '',
    email: '',
    first_name: '',
    last_name: '',
    password: ''
  });

  const fetchUsers = async (query: string = '') => {
    if (loading) return; // Prevent concurrent requests
    setLoading(true);
    try {
      const url = query ? `/api/keycloak/users?q=${query}` : '/api/keycloak/users';
      const res = await axios.get(url);
      setUsers(Array.isArray(res.data) ? res.data : []);
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de récupérer les utilisateurs' });
    }
    setLoading(false);
  };

  // On fetch au montage et quand la recherche change
  useEffect(() => {
    const delayDebounceFn = setTimeout(() => {
      fetchUsers(search);
    }, 500);

    return () => clearTimeout(delayDebounceFn);
  }, [search]);

  const handleCreate = async () => {
    try {
      await axios.post('/api/keycloak/users', newUser);
      notifications.show({ color: 'green', title: 'Succès', message: 'Utilisateur créé' });
      setIsModalOpen(false);
      setNewUser({ username: '', email: '', first_name: '', last_name: '', password: '' });
      fetchUsers(search); // On rafraichit avec la recherche actuelle
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la création' });
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm("Supprimer cet utilisateur ?")) return;
    try {
      await axios.delete(`/api/keycloak/users/${id}`);
      notifications.show({ color: 'green', title: 'Succès', message: 'Utilisateur supprimé' });
      fetchUsers(search); // On rafraichit avec la recherche actuelle
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la suppression' });
    }
  };

  return (
    <Paper withBorder p="md" shadow="xs" style={{ position: 'relative' }}>
      <LoadingOverlay visible={loading} />
      <Group justify="space-between" mb="md">
        <Title order={4}>Comptes Locaux (Keycloak)</Title>
        <Group>
          <TextInput 
            placeholder="Rechercher par identifiant ou nom..." 
            size="xs" 
            w={250}
            value={search}
            onChange={(e) => setSearch(e.currentTarget.value)}
          />
          <Switch 
            label="Afficher les comptes LDAP" 
            checked={showLdap} 
            onChange={(event) => setShowLdap(event.currentTarget.checked)} 
          />
          <Button variant="light" leftSection={<IconRefresh size={16} />} onClick={fetchUsers}>Actualiser</Button>
          <Button leftSection={<IconPlus size={16} />} onClick={() => setIsModalOpen(true)}>Nouvel Utilisateur</Button>
        </Group>
      </Group>

      <Table highlightOnHover verticalSpacing="sm">
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
            .filter(user => showLdap || !(user.federationLink !== undefined && user.federationLink !== null))
            .map((user) => {
              const isLdap = user.federationLink !== undefined && user.federationLink !== null;
              return (
              <Table.Tr key={user.id}>
                <Table.Td><Group gap="xs"><IconUser size={14} color="gray" /><Text size="sm">{user.username}</Text></Group></Table.Td>
                <Table.Td>{user.firstName} {user.lastName}</Table.Td>
                <Table.Td>{user.email}</Table.Td>
                <Table.Td>
                  {isLdap ? <Badge color="blue" size="xs">LDAP</Badge> : <Badge color="green" size="xs">Local</Badge>}
                </Table.Td>
                <Table.Td>
                  <Group justify="flex-end">
                    {!isLdap && (
                      <ActionIcon color="red" variant="subtle" onClick={() => handleDelete(user.id)}>
                        <IconTrash size={16} />
                      </ActionIcon>
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
    </Paper>
  );
}
