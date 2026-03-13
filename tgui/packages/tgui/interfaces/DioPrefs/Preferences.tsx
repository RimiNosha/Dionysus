import { Button } from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { Box, ByondUi, Stack } from '../../components';
import { PreferencesMenuData } from './data';

export enum DioPrefsPage {
  APPEARANCE = 'Appearance',
  JOBS = 'Jobs',
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

  return (
    <Stack vertical height="100%" pt="5px" pb="5px">
      <Stack.Item>
        {current_page !== DioPrefsPage.SPECIES ? (
          <>
            <Button>Job</Button>
            <Button>Loadout</Button>
            <Button>Underwear</Button>
            <Button>Naked</Button>
          </>
        ) : (
          <>
            <Button>1</Button>
            <Button>2</Button>
            <Button>3</Button>
            <Button>4</Button>
            <Button>Male</Button>
            <Button>Female</Button>
          </>
        )}
      </Stack.Item>
      <Stack.Item height="100%">
        <ByondUi
          width="220px"
          height="100%"
          params={{
            id: props.id,
            type: 'map',
          }}
        />
        {/* <Image
          className="DioPrefs__CharacterPreview"
          src={`data:image/png;base64,${data.character_preview_icon}`}
        /> */}
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
