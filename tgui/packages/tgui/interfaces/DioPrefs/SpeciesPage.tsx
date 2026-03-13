import { useBackend } from '../../backend';
import { Box, Stack } from '../../components';
import { PreferencesMenuData } from './data';
import { CharacterPreview } from './Preferences';

export const SpeciesPage = (props) => {
  const { data } = useBackend<PreferencesMenuData>();

  return (
    <Box position="relative" width="100%" height="100%">
      <Stack fill>
        <Stack.Item width="100%">test</Stack.Item>
        <Stack.Item style={{ width: '158px' }}>
          <CharacterPreview id={data.character_preview_view} />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
