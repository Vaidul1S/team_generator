import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from "react";

export default function Bracket() {
    document.title = "Team Bracket";

    const [groups, setGroups] = useState([]);
    const [bracket, setBracket] = useState([]);
    const [semifinals, setSemifinals] = useState(['TBD', 'TBD', 'TBD', 'TBD']);
    const [finals, setFinals] = useState(['TBD', 'TBD', 'TBD', 'TBD']);

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
        if (groups.length > 0) {
            fillBracket();
        }
    }, [groups]);

    const fillBracket = _ => {
        const groupsByPlaces = groups.map(group => [...group].sort((a, b) => a.place - b.place));

        const array = [];
        groupsByPlaces.forEach(group => {
            group.forEach(team => {
                array.push(team.name);
            })
        });
        setBracket(array);
    };

    const promoteTeam = e => {
        setSemifinals(prev => {
            const next = [...prev];

            if (e === bracket[0] || e === bracket[7]) {
                next[0] = e;
            } else if (e === bracket[2] || e === bracket[5]) {
                next[1] = e;
            } else if (e === bracket[1] || e === bracket[6]) {
                next[2] = e;
            } else if (e === bracket[4] || e === bracket[3]) {
                next[3] = e;
            }
            return next;
        });
    };

    const promoteToFinals = e => {
        setFinals(prev => {
            const next = [...prev];

            if (e === semifinals[0]) {
                next[0] = e;
                next[2] = semifinals[1];
            } else if (e === semifinals[1]) {
                next[0] = e;
                next[2] = semifinals[0];
            } else if (e === semifinals[2]) {
                next[1] = e;
                next[3] = semifinals[3];
            } else if (e === semifinals[3]) {
                next[1] = e;
                next[3] = semifinals[2];
            }
            return next;
        });
    };

    return (
        <ScrollView>
            <View style={styles.container}>

                <View style={styles.col}>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[0])} style={styles.button}>
                            <Text style={styles.text}>(A1) {bracket[0]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[7])} style={styles.button}>
                            <Text style={styles.text}>(B4) {bracket[7]}</Text>
                        </TouchableOpacity>
                    </View>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[5])} style={styles.button}>
                            <Text style={styles.text}>(B2) {bracket[5]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[2])} style={styles.button}>
                            <Text style={styles.text}>(A3) {bracket[2]}</Text>
                        </TouchableOpacity>
                    </View>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[1])} style={styles.button}>
                            <Text style={styles.text}>(A2) {bracket[1]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[6])} style={styles.button}>
                            <Text style={styles.text}>(B3) {bracket[6]}</Text>
                        </TouchableOpacity>
                    </View>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[4])} style={styles.button}>
                            <Text style={styles.text}>(B1) {bracket[4]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteTeam(bracket[3])} style={styles.button}>
                            <Text style={styles.text}>(A4) {bracket[3]}</Text>
                        </TouchableOpacity>
                    </View>
                </View>

                <View style={styles.col}>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteToFinals(semifinals[0])} style={styles.button}>
                            <Text style={styles.text}>(Q1) {semifinals[0]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteToFinals(semifinals[1])} style={styles.button}>
                            <Text style={styles.text}>(Q2) {semifinals[1]}</Text>
                        </TouchableOpacity>
                    </View>
                    <View style={styles.row}>
                        <TouchableOpacity onPress={_ => promoteToFinals(semifinals[2])} style={styles.button}>
                            <Text style={styles.text}>(Q3) {semifinals[2]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity onPress={_ => promoteToFinals(semifinals[3])} style={styles.button}>
                            <Text style={styles.text}>(Q4) {semifinals[3]}</Text>
                        </TouchableOpacity>
                    </View>
                </View>

                <View style={styles.col}>
                    <View style={styles.row}>
                        <Text style={styles.title}>Finals🏆</Text>
                    </View>
                    <View style={styles.row}>
                        <TouchableOpacity style={styles.button}>
                            <Text style={styles.text}>🥇(W1) {finals[0]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity style={styles.button}>
                            <Text style={styles.text}>(W2) {finals[1]}</Text>
                        </TouchableOpacity>
                    </View>

                    <View style={styles.row}>
                        <TouchableOpacity style={styles.button}>
                            <Text style={styles.text}>🥉(L1) {finals[2]}</Text>
                        </TouchableOpacity>
                        <Text style={styles.point}> : </Text>
                        <TouchableOpacity style={styles.button}>
                            <Text style={styles.text}>(L2) {finals[3]}</Text>
                        </TouchableOpacity>
                    </View>
                </View>

            </View>
        </ScrollView>
    )
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'column',
        alignContent: 'space-around',
        flexWrap: 'wrap',
        width: '100%',
        backgroundColor: '#40b0cc80',
    },
    col: {
        justifyContent: 'space-around',
        height: '100%',
        padding: '2%',
        width: '33%',
        backgroundColor: 'none',
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-around',
        gap: '3%',
        width: '100%',
        backgroundColor: 'none',
    },
    text: {
        textAlign: 'center',
        fontSize: '20px',
        fontFamily: 'BrightAura',
        color: '#000000',
        width: '100%',
    },
    point: {
        textAlign: 'center',
        fontSize: '20px',
        fontFamily: 'BrightAura',
        color: '#000000',
    },
    button: {
        width: '42%',
    },
    title: {
        textAlign: 'center',
        fontSize: '24px',
        fontFamily: 'BrightAura',
        color: '#000000',
        width: '100%'
    },
});