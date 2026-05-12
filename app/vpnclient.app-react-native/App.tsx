/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * 
 * @format
 */

import React from 'react';
import type {PropsWithChildren} from 'react';
import {
  Button,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';
import VPNClientEngine, { ConnectionStatus } from 'vpnclient-engine-react-native';

import {
  Colors,
  DebugInstructions,
  Header,
  LearnMoreLinks,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({children, title}: SectionProps): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={[styles.sectionContainer, {marginTop: 0}]}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        {title}
      </Text>
      <Text
        style={[
          styles.sectionDescription,
          {
            color: isDarkMode ? Colors.light : Colors.dark,
          },
        ]}>
        {children}
      </Text>
    </View>
  );
}

function App(): React.JSX.Element {
  const [connectionStatus, setConnectionStatus] = React.useState('disconnected');
  const [vpnStatus, setVpnStatus] = React.useState<ConnectionStatus>('disconnected');
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  /*
   * To keep the template simple and small we're adding padding to prevent view
   * from rendering under the System UI.
   * For bigger apps the recommendation is to use `react-native-safe-area-context`:
   * https://github.com/AppAndFlow/react-native-safe-area-context
   *
   * You can read more about it here:
   * https://github.com/react-native-community/discussions-and-proposals/discussions/827
   */
  const safePadding = '5%';

  const toggleVpn = async () => {
    if (connectionStatus === 'disconnected') {
      try {
        setConnectionStatus('connecting');
        // TODO: Add your VPN connection logic using vpnclient-engine-react-native here.
        // Example: await VPNClientEngine.connect({ /* connection options */ });
      } catch (error) {
        console.error('Failed to connect VPN:', error);
        setConnectionStatus('disconnected'); // Revert state on error
      }
    } else if (connectionStatus === 'connected') {
      try {
        setConnectionStatus('disconnecting');
        // TODO: Add your VPN disconnection logic using vpnclient-engine-react-native here.
      } catch (error) {
        console.error('Failed to disconnect VPN:', error);
      }
    }
  };

  React.useEffect(() => {
    // Initialize the VPN engine
    VPNClientEngine.initialize();

    // Add listener for connection status changes
    const statusListener = VPNClientEngine.addListener('onConnectionStatusChanged', (status: ConnectionStatus) => {
      setConnectionStatus(status);
      setVpnStatus(status);
    });

    // Clean up the listener when the component unmounts
    return () => {
      statusListener.remove();
    };
  }, []); // Empty dependency array means this effect runs only once on mount


  return (
    <View style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <View style={backgroundStyle}>
        <View style={{paddingRight: safePadding}}>
          <Header/>
        </View>
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            paddingHorizontal: safePadding,
            paddingBottom: safePadding,
          }}>
          <Section title="Step One">
            Edit <Text style={styles.highlight}>App.tsx</Text> to change this
            screen and then come back to see your edits.
          </Section>
          <Section title="See Your Changes">
            <ReloadInstructions />
          </Section>
          <Section title="Debug">
            <DebugInstructions />
          </Section>
          <Section title="Learn More">
            Read the docs to discover what to do next:
          </Section>
          <LearnMoreLinks />
        </View>
      </ScrollView>
      <View style={{marginHorizontal: safePadding, marginBottom: 20}}>
         <Button title={connectionStatus === 'connected' ? 'Disconnect VPN' : 'Connect VPN'} onPress={toggleVpn} />
         <Text style={{textAlign: 'center', marginTop: 10}}>Status: {connectionStatus}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
