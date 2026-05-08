import React from 'react';
import { View, Text, TouchableOpacity, SafeAreaView, TextInput } from 'react-native';

export default function MagicLinkScreen({ navigation }: any) {
  return (
    <SafeAreaView className="flex-1 bg-white justify-center px-6">
      <TouchableOpacity onPress={() => navigation.goBack()} className="absolute top-12 left-6">
        <Text className="text-gray-500 font-bold text-lg">← Accueil</Text>
      </TouchableOpacity>

      <View className="items-center mb-8 mt-12">
        <Text className="text-3xl font-bold text-green-600 mb-2 text-center">Accès Tuteur</Text>
        <Text className="text-gray-500 text-center">Entrez le code à 6 chiffres reçu par e-mail ou copiez le Magic Link.</Text>
      </View>

      <View className="space-y-4 mb-8">
        <TextInput
          placeholder="Code d'accès (ex: 789-456)"
          className="bg-gray-100 p-4 rounded-xl text-center text-2xl tracking-widest font-bold text-gray-800"
          keyboardType="numeric"
          maxLength={6}
        />
      </View>

      <TouchableOpacity
        className="bg-green-500 p-4 rounded-xl items-center shadow-lg shadow-green-200"
        onPress={() => navigation.navigate('Dashboard', { role: 'TUTOR' })}
      >
        <Text className="text-white font-bold text-lg">Valider et Évaluer</Text>
      </TouchableOpacity>

    </SafeAreaView>
  );
}
