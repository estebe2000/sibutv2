import React from 'react';
import { View, Text, TouchableOpacity, SafeAreaView, TextInput } from 'react-native';

export default function LoginScreen({ navigation }: any) {
  return (
    <SafeAreaView className="flex-1 bg-white justify-center px-6">
      <View className="items-center mb-10">
        <Text className="text-4xl font-bold text-blue-600 mb-2">Skills Hub</Text>
        <Text className="text-gray-500">IUT Le Havre - Portail Mobile</Text>
      </View>

      <View className="space-y-4 mb-8">
        <TextInput
          placeholder="Identifiant LDAP (ex: mm192837)"
          className="bg-gray-100 p-4 rounded-xl text-gray-800"
          autoCapitalize="none"
        />
        <TextInput
          placeholder="Mot de passe"
          secureTextEntry
          className="bg-gray-100 p-4 rounded-xl text-gray-800"
        />
      </View>

      <TouchableOpacity
        className="bg-blue-600 p-4 rounded-xl items-center shadow-lg shadow-blue-300"
        onPress={() => navigation.navigate('Dashboard', { role: 'STUDENT' })}
      >
        <Text className="text-white font-bold text-lg">Connexion SSO</Text>
      </TouchableOpacity>

      <View className="mt-10 pt-6 border-t border-gray-200">
        <Text className="text-center text-gray-500 mb-4">Vous êtes un tuteur d&apos;entreprise ?</Text>
        <TouchableOpacity
          className="bg-white border-2 border-green-500 p-4 rounded-xl items-center"
          onPress={() => navigation.navigate('MagicLink')}
        >
          <Text className="text-green-600 font-bold text-lg">Entrer mon Code Sécurisé</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}
