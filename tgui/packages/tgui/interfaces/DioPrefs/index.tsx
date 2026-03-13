import { Button } from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { Stack } from '../../components';
import { Window } from '../../layouts';
import { AppearancePage } from './AppearancePage';
import { CharacterSelect } from './CharacterSelectPage';
import { PreferencesMenuData } from './data';
import { DioPrefsPage, HIDDEN_PAGES } from './Preferences';
import { SpeciesPage } from './SpeciesPage';

export const DioPrefs = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  const [current_page, setCurrentPage] = useLocalState(
    'DioPrefs_page',
    DioPrefsPage.SELECT,
  );

  let page;

  switch (current_page) {
    case DioPrefsPage.SELECT:
      page = <CharacterSelect />;
      break;
    case DioPrefsPage.APPEARANCE:
      page = <AppearancePage />;
      break;
    case DioPrefsPage.SPECIES:
      page = <SpeciesPage />;
      break;
    default:
      page = <CharacterSelect />;
      break;
  }

  return (
    <Window title={current_page} theme="dionysus" width={920} height={770}>
      <Stack vertical fill>
        <Stack.Item>
          <Stack vertical width="100%">
            <Stack.Item style={{ display: 'flex', justifyContent: 'center' }}>
              <Button selected>Character</Button>
              <Button>Game</Button>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item style={{ display: 'flex', justifyContent: 'center' }}>
              <h3>{data.character_profiles[data.active_slot].name}</h3>
            </Stack.Item>
            <Stack.Item style={{ display: 'flex', justifyContent: 'center' }}>
              {Object.entries(DioPrefsPage).map(([key, value]) => {
                if (HIDDEN_PAGES.includes(value)) {
                  return;
                }
                return (
                  <Button
                    key={key}
                    selected={value === current_page}
                    onClick={() => setCurrentPage(value)}
                  >
                    {value}
                  </Button>
                );
              })}
            </Stack.Item>
            <Stack.Divider />
          </Stack>
        </Stack.Item>
        <Stack.Item height="100%">{page}</Stack.Item>
      </Stack>
    </Window>
  );
};
