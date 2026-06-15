import { useEffect, useState } from "react";
import { Modal, ScrollView, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function Table() {

    const letter = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    const [groups, setGroups] = useState([]);
    const [group, setGroup] = useState(['', '', '', '']);
    const [showAddGroup, setShowAddGroup] = useState(false);
    const [deleteGroup, setDeleteGroup] = useState(false);

    useEffect(() => {
        const loadData = async () => {
            try {
                const data = await AsyncStorage.getItem('table');
                if (data) {
                    setGroups(JSON.parse(data));
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
                await AsyncStorage.setItem('table', JSON.stringify(groups));
            } catch (err) {
                console.error("Failed to save data", err);
            }
        };
        storeData();
    }, [groups]);

    useEffect(() => {
        const updatedGroups = [...groups];
        updatedGroups.forEach(group => {
            group.forEach((team, teamIndex) => {
                team.matches.forEach((el, index) => {
                    if (teamIndex == index) {
                        team.matches[index] = '#';
                    }
                })
            })
        });
        setGroups(updatedGroups);
    }, [showAddGroup])

    const addTeamName = (value, index) => {
        setGroup(g => g.map((team, i) => i === index ? value : team));
    }

    const removeTeam = index => {
        setGroup(g => g.filter((_, i) => i !== index));
    }

    const makeTable = _ => {
        return group.map(el => ({ name: el, matches: group.map(_ => '-'), points: 0, place: 'TBD' }));
    }

    const addGroup = _ => {
        setGroups(g => [...g, makeTable()]);
        setGroup(['', '', '', '']);
        setShowAddGroup(false);
    }

    const removeGroup = e => {
        setGroups(g => g.filter((_, i) => i !== e));
        setDeleteGroup(false);
    }

    const updateMatch = (grIndex, gIndex, matchIndex, value) => {

        const updatedGroups = [...groups];

        updatedGroups[grIndex][gIndex].matches[matchIndex] = value;

        updatedGroups.forEach(team => {

            // 2 sets 2:0
            if (team[0].matches[1] == 3) {
                team[1].matches[0] = 0;
            } else if (team[0].matches[1] == 0) {
                team[1].matches[0] = 3;
            }

            if (team[0].matches[2] == 3) {
                team[2].matches[0] = 0;
            } else if (team[0].matches[2] == 0) {
                team[2].matches[0] = 3;
            }

            if (team[0].matches[3] == 3) {
                team[3].matches[0] = 0;
            } else if (team[0].matches[3] == 0) {
                team[3].matches[0] = 3;
            }

            if (team[1].matches[2] == 3) {
                team[2].matches[1] = 0;
            } else if (team[1].matches[2] == 0) {
                team[2].matches[1] = 3;
            }

            if (team[1].matches[3] == 3) {
                team[3].matches[1] = 0;
            } else if (team[1].matches[3] == 0) {
                team[3].matches[1] = 3;
            }

            if (team[2].matches[3] == 3) {
                team[3].matches[2] = 0;
            } else if (team[2].matches[3] == 0) {
                team[3].matches[2] = 3;
            }

            if (team[0].matches[4] == 3) {
                team[4].matches[0] = 0;
            } else if (team[0].matches[4] == 0) {
                team[4].matches[0] = 3;
            }

            if (team[1].matches[4] == 3) {
                team[4].matches[1] = 0;
            } else if (team[1].matches[4] == 0) {
                team[4].matches[1] = 3;
            }

            if (team[2].matches[4] == 3) {
                team[4].matches[2] = 0;
            } else if (team[2].matches[4] == 0) {
                team[4].matches[2] = 3;
            }

            if (team[3].matches[4] == 3) {
                team[4].matches[3] = 0;
            } else if (team[3].matches[4] == 0) {
                team[4].matches[3] = 3;
            }

            // 3 sets 2:1
            if (team[0].matches[1] == 2) {
                team[1].matches[0] = 1;
            } else if (team[0].matches[1] == 1) {
                team[1].matches[0] = 2;
            }

            if (team[0].matches[2] == 2) {
                team[2].matches[0] = 1;
            } else if (team[0].matches[2] == 1) {
                team[2].matches[0] = 2;
            }

            if (team[0].matches[3] == 2) {
                team[3].matches[0] = 1;
            } else if (team[0].matches[3] == 1) {
                team[3].matches[0] = 2;
            }

            if (team[1].matches[2] == 2) {
                team[2].matches[1] = 1;
            } else if (team[1].matches[2] == 1) {
                team[2].matches[1] = 2;
            }

            if (team[1].matches[3] == 2) {
                team[3].matches[1] = 1;
            } else if (team[1].matches[3] == 1) {
                team[3].matches[1] = 2;
            }

            if (team[2].matches[3] == 2) {
                team[3].matches[2] = 1;
            } else if (team[2].matches[3] == 1) {
                team[3].matches[2] = 2;
            }

            if (team[0].matches[4] == 2) {
                team[4].matches[0] = 1;
            } else if (team[0].matches[4] == 1) {
                team[4].matches[0] = 2;
            }

            if (team[1].matches[4] == 2) {
                team[4].matches[1] = 1;
            } else if (team[1].matches[4] == 1) {
                team[4].matches[1] = 2;
            }

            if (team[2].matches[4] == 2) {
                team[4].matches[2] = 1;
            } else if (team[2].matches[4] == 1) {
                team[4].matches[2] = 2;
            }

            if (team[3].matches[4] == 2) {
                team[4].matches[3] = 1;
            } else if (team[3].matches[4] == 1) {
                team[4].matches[3] = 2;
            }

            // reverse, not nessecery
            if (team[1].matches[0] == 2) {
                team[0].matches[1] = 1;
            } else if (team[1].matches[0] == 1) {
                team[0].matches[1] = 2;
            }

            if (team[2].matches[0] == 2) {
                team[0].matches[2] = 1;
            } else if (team[2].matches[0] == 1) {
                team[0].matches[2] = 2;
            }

            if (team[3].matches[0] == 2) {
                team[0].matches[3] = 1;
            } else if (team[3].matches[0] == 1) {
                team[0].matches[3] = 2;
            }

            if (team[2].matches[1] == 2) {
                team[1].matches[2] = 1;
            } else if (team[2].matches[1] == 1) {
                team[1].matches[2] = 2;
            }

            if (team[3].matches[1] == 2) {
                team[1].matches[3] = 1;
            } else if (team[3].matches[1] == 1) {
                team[1].matches[3] = 2;
            }

            if (team[3].matches[2] == 2) {
                team[2].matches[3] = 1;
            } else if (team[3].matches[2] == 1) {
                team[2].matches[3] = 2;
            }

            if (team[4]) {
                if (team[4].matches[0] == 2) {
                    team[0].matches[4] = 1;
                } else if (team[4].matches[0] == 1) {
                    team[0].matches[4] = 2;
                }

                if (team[4].matches[1] == 2) {
                    team[1].matches[4] = 1;
                } else if (team[4].matches[1] == 1) {
                    team[4].matches[1] = 2;
                }

                if (team[4].matches[2] == 2) {
                    team[2].matches[4] = 1;
                } else if (team[4].matches[2] == 1) {
                    team[2].matches[4] = 2;
                }

                if (team[4].matches[3] == 2) {
                    team[3].matches[4] = 1;
                } else if (team[4].matches[3] == 1) {
                    team[3].matches[4] = 2;
                }
            }
        });

        updatedGroups.forEach(group => {
            group.forEach((team, teamIndex) => {
                team.points = 0;
                team.matches.forEach((el, index) => {
                    if (teamIndex != index) {
                        team.points += Number(el);
                    }
                })
            })
        });
        setGroups(updatedGroups);
    };

    const changeTeamName = (grIndex, gIndex, text) => {
        const updatedGroups = [...groups];

        updatedGroups[grIndex][gIndex].name = text;
        setGroups(updatedGroups);
    }

    const calcPlaces = e => {
        const updatedGroups = [...groups];

        updatedGroups.map((group, groupIndex) => {
            let sorted = [];
            if (groupIndex == e) {
                sorted = group.toSorted((a, b) => b.points - a.points);
            }
            group.forEach(team => {
                sorted.map((s, sIndex) => s.name === team.name ? team.place = sIndex + 1 : null);
            })
        });

        setGroups(updatedGroups);
    }

    return (
        <ScrollView >
            <View style={styles.container}>
                <View >
                    {groups.map((gr, grIndex) =>
                        <View key={grIndex}>
                            <Text style={styles.name}>{letter[grIndex]} Group</Text>
                            <View style={styles.group}>
                                {gr.map((g, gIndex) =>
                                    <View key={gIndex} style={styles.team}>
                                        <TextInput style={styles.name} value={g.name} onChangeText={text => changeTeamName(grIndex, gIndex, text)} />
                                        {g.matches.map((match, matchIndex) =>
                                            <TextInput
                                                key={matchIndex}
                                                style={styles.result}
                                                value={String(match)}
                                                onChangeText={text => updateMatch(grIndex, gIndex, matchIndex, text.trim())}
                                                keyboardType="numeric" />
                                        )}
                                        <Text style={styles.points}>{g.points}</Text>
                                        <Text style={styles.points}>{g.place}</Text>
                                    </View>)}
                            </View>
                            <View style={styles.bin}>
                                <TouchableOpacity onPress={e => calcPlaces(grIndex)}><Text style={styles.buttonB}>Calc</Text></TouchableOpacity>
                                <TouchableOpacity onPress={_ => setDeleteGroup(true)}><Text style={styles.buttonR}>Delete</Text></TouchableOpacity>
                            </View>

                            <Modal visible={deleteGroup} animationType="fade" style={styles.modal}>
                                <View style={styles.card}>
                                    <Text style={styles.title}>Are you sure?</Text>
                                    <View style={styles.bin}>
                                        <TouchableOpacity onPress={_ => removeGroup(grIndex)}><Text style={styles.buttonR}>Yes</Text></TouchableOpacity>
                                        <TouchableOpacity onPress={_ => setDeleteGroup(false)}><Text style={styles.buttonB}>Back</Text></TouchableOpacity>
                                    </View>
                                </View>
                            </Modal>

                        </View>
                    )}
                </View>

                <View>
                    <TouchableOpacity onPress={_ => setShowAddGroup(true)}><Text style={styles.button}>Add group</Text></TouchableOpacity>
                </View>

                <Modal visible={showAddGroup} animationType="fade" style={styles.modal}>
                    <View style={styles.card}>

                        <Text style={styles.title}>Create New Group</Text>
                        {group.map((name, index) =>
                            <View key={index} style={styles.line}>
                                <TextInput style={styles.input} onChange={e => addTeamName(e.target.value, index)} placeholder="Team name" value={name} />
                                <TouchableOpacity onPress={_ => removeTeam(index)}><Text style={styles.buttonR}>Remove</Text></TouchableOpacity>
                            </View>)}

                        <TouchableOpacity onPress={_ => setGroup(g => [...g, ''])}><Text style={styles.button}>Add Team</Text></TouchableOpacity>
                        <View style={styles.bin}>
                            <TouchableOpacity onPress={addGroup}><Text style={styles.button}>Create</Text></TouchableOpacity>
                            <TouchableOpacity onPress={_ => setShowAddGroup(false)}><Text style={styles.buttonB}>Back</Text></TouchableOpacity>
                        </View>

                    </View>
                </Modal>

            </View>
        </ScrollView>
    )
}

const styles = StyleSheet.create({
    container: {
        alignSelf: 'center',
        padding: '1%',
        backgroundColor: '#40b0cc80',
        width: '100%',
    },
    group: {
        border: 'solid, 1px, #000000',
        margin: 10,
    },
    team: {
        padding: 5,
        border: 'solid, 1px, #000000',
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
    name: {
        fontSize: 22,
        width: '36%',
        color: '#000000',
        fontFamily: 'BrightAura',
    },
    result: {
        fontSize: 22,
        color: '#000000',
        width: '10%',
        textAlign: 'right',
        fontFamily: 'BrightAura',
    },
    points: {
        fontSize: 22,
        color: '#000000',
        width: '7%',
        textAlign: 'right',
        fontFamily: 'BrightAura',
    },
    button: {
        borderRadius: 10,
        backgroundColor: 'green',
        padding: 6,
        width: 100,
        alignItems: 'center',
        alignSelf: 'flex-end',
        margin: 10,
        fontFamily: 'BrightAura',
        textAlign: 'center',
    },
    buttonR: {
        borderRadius: 10,
        backgroundColor: '#c00707',
        padding: 6,
        width: 100,
        alignItems: 'center',
        alignSelf: 'flex-end',
        margin: 10,
        fontFamily: 'BrightAura',
        textAlign: 'center',
    },
    buttonB: {
        borderRadius: 10,
        backgroundColor: '#40b0cc',
        padding: 6,
        width: 100,
        alignItems: 'center',
        alignSelf: 'flex-end',
        margin: 10,
        fontFamily: 'BrightAura',
        textAlign: 'center',
    },
    bin: {
        flexDirection: 'row',
        justifyContent: 'center',
        margin: 20,
    },
    modal: {
        alignSelf: 'center',
        justifyContent: 'center',
    },
    card: {
        alignSelf: 'center',
        color: 'white',
        backgroundColor: '#194955',
        padding: 10,
        width: 420,
        height: '100%',
        justifyContent: 'center',
    },
    title: {
        textAlign: 'center',
        fontSize: 24,
        marginBottom: 30,
        color: '#48d2f5',
        fontFamily: 'BrightAura',
    },
    line: {
        flexDirection: 'row',
    },
    input: {
        color: '#ffffff4f',
        padding: 5,
        margin: 5,
        border: 'solid 1px white',
        borderRadius: 10,
        outlineStyle: 'none',
        fontFamily: 'BrightAura',
    },
})