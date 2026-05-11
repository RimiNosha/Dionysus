import { useState } from 'react';
import { Button } from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { Box, Stack } from '../../components';
import { Image } from '../../components/Image';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export enum DioPrefsPage {
  APPEARANCE = 'Appearance',
  JOBS = 'Jobs',
  LOADOUT = 'Loadout',
  LORE = 'Lore',
  OOC = 'OOC',
  RECORDS = 'Records',
  SELECT = 'Select',
  SKILLS = 'Skills',
  SPECIES = 'Species',
}

export const HIDDEN_PAGES = [
  DioPrefsPage.SELECT,
  DioPrefsPage.SKILLS,
  // DioPrefsPage.SPECIES,
];

export const CharacterPreview = (props) => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const [current_page] = useLocalState('DioPrefs_page', DioPrefsPage.SELECT);

  const [previewSpecies, setPreviewSpecies] = useLocalState(
    'DioPrefs_previewSpecies',
    data.character_preferences.misc.species || 'human',
  );

  const [previewSex, setPreviewSex] = useState('male');
  const [previewIndex, setPreviewIndex] = useState(0);

  return (
    <Stack vertical height="100%" pt="5px" pb="5px">
      <Stack.Item>
        {current_page !== DioPrefsPage.SPECIES ? (
          <Stack vertical>
            <Stack.Item style={{ justifyContent: 'center', display: 'flex' }}>
              <Button>Job</Button>
              <Button>Loadout</Button>
            </Stack.Item>
            <Stack.Item
              mt="0"
              style={{ justifyContent: 'center', display: 'flex' }}
            >
              <Button>Underwear</Button>
              <Button>Naked</Button>
            </Stack.Item>
          </Stack>
        ) : (
          <Stack vertical>
            <Stack.Item style={{ justifyContent: 'center', display: 'flex' }}>
              <Button onClick={() => setPreviewIndex(0)}>1</Button>
              <Button onClick={() => setPreviewIndex(1)}>2</Button>
              <Button onClick={() => setPreviewIndex(2)}>3</Button>
              <Button onClick={() => setPreviewIndex(3)}>4</Button>
            </Stack.Item>
            <Stack.Item
              mt="0"
              style={{ justifyContent: 'center', display: 'flex' }}
            >
              <Button onClick={() => setPreviewSex('male')}>Male</Button>
              <Button onClick={() => setPreviewSex('female')}>Female</Button>
            </Stack.Item>
          </Stack>
        )}
      </Stack.Item>
      <Stack.Item height="100%" width="220px">
        {/* <ByondUi
          width="220px"
          height="100%"
          params={{
            id: props.id,
            type: 'map',
          }}
        /> */}
        <ServerPreferencesFetcher
          render={(serverData) => (
            <Image
              className="DioPrefs__CharacterPreview"
              src={`data:image/png;base64,${current_page === DioPrefsPage.SPECIES ? serverData?.species_previews[previewSpecies][previewSex][previewIndex] : 'do a different thing dipshit'}`}
            />
          )}
        />
      </Stack.Item>
      <Stack.Item align="center" width="100%" basis="0" height="100px">
        <Button icon="arrow-left" ml="2px" />
        <Box inline align="center" width="107px">
          Background
        </Box>
        <Button icon="arrow-right" />
      </Stack.Item>
    </Stack>
  );
};
