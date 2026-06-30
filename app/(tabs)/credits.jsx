import { Text, StyleSheet, Image, View } from 'react-native';
import { Link } from 'expo-router';
import React from 'react';

export default function Credits() {

  return (
    <View style={styles.container}>
      <Image
        source={require("../../assets/images/gg.jpg")}
        style={styles.image} />
      <Text style={styles.text}>Simple team generator for pairing people into teams.</Text>
      <Text style={styles.text}>To delete name press long on a selected name.</Text>
      <Text style={styles.text}>Version 1.06</Text>
      <Text style={styles.text}>Added Tornament Table</Text>
      <Text style={styles.text}>Added Tornament Bracket</Text>
      <Link style={styles.link} href='https://github.com/Vaidul1S' target='_blank'>GitHub Link</Link>
      <Text style={styles.text}>&copy; Vaidul1s {new Date().getFullYear()}</Text>
    </View>
  )
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'flex-end',
  },
  text: {
    color: 'white',
    alignSelf: 'center',
    margin: 10,
  },
  image: {
    width: 200,
    height: 200,
    borderRadius: 100,
    alignSelf: 'center',
  },
  link: {
    fontStyle: 'italic',
    color: 'lightblue',
    alignSelf: 'center',
    margin: 20,
  },
})