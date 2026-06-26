import { useState, useEffect, useRef } from 'react';
import { Text, StyleSheet, Modal, TextInput, View, Alert, TouchableOpacity } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAudioPlayer } from 'expo-audio';

const click = require('../../assets/sounds/click2.mp3');

export default function Generator() {

  const inputRef = useRef(null);
  const [pool, setPool] = useState([]);
  const [name, setName] = useState("");
  const [gt, setGt] = useState(false);
  const [teams, setTeams] = useState([]);
  const [size, setSize] = useState(2);
  const player = useAudioPlayer(click);

  useEffect(() => {
    const loadData = async () => {
      try {
        const data = await AsyncStorage.getItem('generator');
        if (data) {
          setPool(JSON.parse(data));
        }
      } catch (err) {
        console.error("Failed to load data", err);
      }
    };
    loadData();
  }, []);

  useEffect(() => {
    const storeData = async () => {
      try {
        await AsyncStorage.setItem('generator', JSON.stringify(pool));
      } catch (err) {
        console.error("Failed to save data", err);
      }
    };
    storeData();
  }, [pool]);

  const submitName = e => {
    player.seekTo(0);
    player.play();
    if (e.trim().length < 1) {
      Alert.alert("Please enter a name!");
    } else if (pool.some(p => p.name.toLowerCase() === e.trim().toLowerCase())) {
      Alert.alert("Name already exists!");
      setName("")
    }
    else {
      setPool(p => [...p, { name }])
      setName("")
    }
    inputRef.current?.blur();
  }

  const delete_name = e => {
    setPool(p => p.filter(p => p.name !== e));
  }

  const generate_teams = _ => {
    player.seekTo(0);
    player.play();
    let shuffle = Object.values(pool);
    function shuffleArray(array) {
      for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
      }
      return array;
    }
    setTeams(shuffleArray([...shuffle]));    
    setGt(true);
  }

  const generate_mixes = _ => {
    player.seekTo(0);
    player.play();    

    function shuffleMixes() {
      const players = [...Object.values(pool)];

      const first = players.slice(0, 4);
      const second = players.slice(4);
    
      for (let i = second.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [second[i], second[j]] = [second[j], second[i]];
      }

      return first.map((player, i) => [player, second[i]]);
    }
    console.log(shuffleMixes());
    
    setTeams(shuffleMixes().flat());
    setGt(true);
  }

  const goBack = _ => {
    player.seekTo(0);
    player.play();
    setGt(false)
  }

  const setTeamSize = e => {
    player.seekTo(0);
    player.play();
    setSize(e);
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Team Generator</Text>

      <TextInput
        ref={inputRef}
        style={styles.input}
        placeholder='Enter a name'
        value={name}
        onChangeText={name => setName(n => name)}
      />
      <TouchableOpacity style={styles.button} onPress={_ => submitName(name)}><Text style={styles.buttonText}>Add name</Text></TouchableOpacity>
      <Text style={styles.namesTitle}>Name Pool</Text>
      <View style={styles.namePool}>
        {pool.map((p, i) =>
          <TouchableOpacity style={styles.name} key={i} onLongPress={_ => delete_name(p.name)}>
            <Text style={styles.name}>{i + 1}. {p.name}</Text>
          </TouchableOpacity>)}
      </View>
      <Text style={styles.namesTitle}>Team Size: {size}</Text>
      <View style={styles.sizes}>
        <TouchableOpacity style={styles.button2} onPress={_ => setTeamSize(2)}><Text style={styles.buttonText}>2</Text></TouchableOpacity>
        <TouchableOpacity style={styles.button2} onPress={_ => setTeamSize(3)}><Text style={styles.buttonText}>3</Text></TouchableOpacity>
        <TouchableOpacity style={styles.button2} onPress={_ => setTeamSize(4)}><Text style={styles.buttonText}>4</Text></TouchableOpacity>
        <TouchableOpacity style={styles.button2} onPress={_ => setTeamSize(5)}><Text style={styles.buttonText}>5</Text></TouchableOpacity>
        <TouchableOpacity style={styles.button2} onPress={_ => setTeamSize(6)}><Text style={styles.buttonText}>6</Text></TouchableOpacity>
        <TouchableOpacity style={styles.button2} onPress={generate_mixes}><Text style={styles.buttonText}>M</Text></TouchableOpacity>
      </View>
      <TouchableOpacity style={styles.button} onPress={generate_teams}><Text style={styles.buttonText}>Generate Teams</Text></TouchableOpacity>

      <Modal visible={gt} animationType='fade'>
        <View style={styles.modal}>
          <Text style={styles.title}>Teams</Text>
          <View style={styles.pool}>
            {teams.map((t, i) => (
              <Text
                key={i}
                style={i % size ? styles.secondTeammate : styles.firstTeammate}
              >
                {i % size + 1}. {t.name}
              </Text>
            ))}
          </View>
          <TouchableOpacity style={styles.button} onPress={generate_teams}><Text style={styles.buttonText}>Generate Again</Text></TouchableOpacity>
          <TouchableOpacity style={styles.button} onPress={goBack}><Text style={styles.buttonText}>Go Back</Text></TouchableOpacity>
        </View>
      </Modal>

    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'space-between',
    backgroundColor: '#40b0cc80',
  },
  title: {
    color: 'white',
    fontSize: 40,
    textAlign: 'center',
    backgroundColor: '#00000080',
    marginTop: 50,
    fontFamily: 'BrightAura',
    padding: 6,
  },
  input: {
    padding: 12,
    margin: 10,
    borderRadius: 10,
    borderColor: 'white',
    borderWidth: 2,
    color: 'white',
    fontFamily: 'BrightAura',
    fontSize: 20,
  },
  button: {
    padding: 10,
    margin: 10,
    borderRadius: 10,
    borderWidth: 0,
    backgroundColor: '#40b0cc',
    alignItems: 'center',
  },
  sizes: {
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  button2: {
    width: 50,
    padding: 10,
    borderRadius: 10,
    borderWidth: 0,
    backgroundColor: '#40b0cc',
    alignItems: 'center',
  },
  buttonText: {
    color: 'black',
    fontSize: 28,
    fontFamily: 'BrightAura',
  },
  namesTitle: {
    width: "100%",
    padding: 7,
    color: 'white',
    fontSize: 30,
    backgroundColor: '#00000080',
    textAlign: 'center',
    fontFamily: 'BrightAura',
  },
  namePool: {
    height: 300,
    flexWrap: 'wrap',
    alignContent: 'center',
  },
  name: {
    width: 180,
    fontSize: 24,
    padding: 3,
    fontFamily: 'BrightAura',
  },
  modal: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'space-between',
    backgroundColor: '#2b6c7c',
  },
  pool: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
  },
  firstTeammate: {
    marginTop: 30,
    fontSize: 24,
    fontFamily: 'BrightAura',
  },
  secondTeammate: {
    fontSize: 24,
    fontFamily: 'BrightAura',
  },
});