import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { KeyboardInsetsView } from '@sdcx/keyboard-insets';
import TagsModal from './components/TagsModal';
const Tags = ['周五不上班', '设备面临换代', '喜欢喝茶', '喜欢钓鱼'];

const FindHome = ()=> {
    const [tagVisble, setTagVisble] = React.useState(false);
    const [tags, setTags] = React.useState(Tags);
    return (
        <KeyboardInsetsView style={styles.container}>
        <View style={styles.container}>
            <View style={styles.center}>
                <TouchableOpacity onPress={()=>setTagVisble(true)}>
                    <Text>Find</Text>
                </TouchableOpacity>
            </View>
            <TagsModal
                visible={tagVisble}
                tags={tags}
                onClose={()=>setTagVisble(false)}
                onTagChange={(tgs)=>{
                console.log(tgs);
                setTags(tgs);
                }}
            />
        </View>
        </KeyboardInsetsView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    center: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
});

export default FindHome;
