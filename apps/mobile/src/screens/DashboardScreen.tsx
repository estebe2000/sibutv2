import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, SafeAreaView } from 'react-native';

export default function DashboardScreen({ route, navigation }: any) {
  const role = route.params?.role || 'STUDENT';

  return (
    <SafeAreaView className="flex-1 bg-gray-50">
      <View className="px-6 pt-6 pb-4 bg-white shadow-sm flex-row justify-between items-center">
        <View>
          <Text className="text-gray-500 text-sm">Bienvenue,</Text>
          <Text className="text-2xl font-bold text-gray-800">
            {role === 'TUTOR' ? 'Tuteur' : 'Marie DUPONT'}
          </Text>
        </View>
        <TouchableOpacity
          className="bg-gray-100 p-2 rounded-full"
          onPress={() => navigation.navigate('Login')}
        >
          <Text className="text-red-500 font-bold">Déconnexion</Text>
        </TouchableOpacity>
      </View>

      <ScrollView className="flex-1 px-4 pt-6">

        {/* Module Stage */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-gray-800 mb-3 px-2">Mon Suivi de Stage</Text>
          <TouchableOpacity className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 mb-3">
            <View className="flex-row justify-between items-center mb-2">
              <Text className="font-bold text-lg text-blue-600">Stage BUT2 - 10 Semaines</Text>
              <View className="bg-green-100 px-2 py-1 rounded-md">
                <Text className="text-green-700 text-xs font-bold">EN COURS</Text>
              </View>
            </View>
            <Text className="text-gray-600 mb-1">Entreprise : Tech LH Innov</Text>
            <Text className="text-gray-500 text-sm">Tuteur : Jean MARTIN</Text>

            <View className="flex-row mt-4 space-x-2">
              <TouchableOpacity className="flex-1 bg-blue-50 py-2 rounded-lg items-center">
                <Text className="text-blue-600 font-semibold">Uploader Preuve</Text>
              </TouchableOpacity>
              <TouchableOpacity className="flex-1 bg-purple-50 py-2 rounded-lg items-center">
                <Text className="text-purple-600 font-semibold">Évaluer</Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        </View>

        {/* Module Messagerie / IA */}
        <View className="mb-6 flex-row space-x-4 px-2">
          <TouchableOpacity
            className="flex-1 bg-blue-600 p-5 rounded-2xl shadow-sm items-center justify-center h-32"
            onPress={() => console.log('Ouvrir Matrix')}
          >
            <Text className="text-white font-bold text-lg mb-1">Chat Tuteur</Text>
            <View className="bg-red-500 w-6 h-6 rounded-full items-center justify-center mt-2">
              <Text className="text-white text-xs font-bold">2</Text>
            </View>
          </TouchableOpacity>

          <TouchableOpacity
            className="flex-1 bg-indigo-600 p-5 rounded-2xl shadow-sm items-center justify-center h-32"
            onPress={() => navigation.navigate('AIChat')}
          >
            <Text className="text-white font-bold text-lg mb-1">Assistant IA</Text>
            <Text className="text-indigo-200 text-sm text-center">Posez vos questions RAG</Text>
          </TouchableOpacity>
        </View>

        {/* Prochaines évaluations (SAÉ) */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-gray-800 mb-3 px-2">SAÉ & Évaluations à venir</Text>
          <View className="bg-white p-4 rounded-2xl shadow-sm border border-gray-100">
            <View className="flex-row justify-between mb-3 border-b border-gray-100 pb-3">
              <View>
                <Text className="font-semibold text-gray-800">Soutenance SAÉ 2.01</Text>
                <Text className="text-gray-500 text-sm">Demain - 14h00</Text>
              </View>
              <Text className="text-orange-500 font-bold">À préparer</Text>
            </View>
            <View className="flex-row justify-between">
              <View>
                <Text className="font-semibold text-gray-800">Rendu Dossier Marketing</Text>
                <Text className="text-gray-500 text-sm">24 Mars - 23h59</Text>
              </View>
              <Text className="text-gray-400 font-bold">En cours</Text>
            </View>
          </View>
        </View>

      </ScrollView>
    </SafeAreaView>
  );
}
