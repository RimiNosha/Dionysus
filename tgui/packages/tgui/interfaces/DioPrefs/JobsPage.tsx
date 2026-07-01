import { useBackend, useLocalState } from '../../backend';
import { Box, Stack } from '../../components';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export const JobsPage = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return;
        }

        const [selectedJob, setSelectedJob] = useLocalState<string>(
          'DioPrefs_selectedJob',
          Object.keys(serverData.jobs.jobs)[0],
        );

        const selectedJobObj = serverData.jobs.jobs[selectedJob];

        return (
          <Stack width="100%" height="100%">
            <Stack.Item width="40%" height="100%">
              <Box overflowY="scroll" height="730px">
                {Object.entries(serverData.jobs.jobs).map((e) => {
                  return (
                    <Box
                      key={e[0]}
                      width="100%"
                      height="42px"
                      onClick={() => setSelectedJob(e[0])}
                      style={{ cursor: 'pointer', userSelect: 'none' }}
                    >
                      <Stack>
                        <Stack.Item>
                          <Box
                            width="36px"
                            height="36px"
                            style={{
                              boxShadow: e[1].sub_department
                                ? `inset 3px 3px ${serverData.jobs.departments[e[1].sub_department].color}, inset -2px -2px ${serverData.jobs.departments[e[1].sub_department].color}`
                                : '',
                            }}
                            backgroundColor={
                              serverData.jobs.departments[e[1].department].color
                            }
                          />
                        </Stack.Item>
                        <Stack.Item mt="3px">{e[1].alt_titles[0]}</Stack.Item>
                      </Stack>
                    </Box>
                  );
                })}
              </Box>
            </Stack.Item>
            <Stack.Item width="100%" height="100%">
              <Stack vertical>
                <Stack.Item>
                  <h1 style={{ textAlign: 'center' }}>
                    {selectedJobObj.alt_titles[0]}
                  </h1>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item>Pretend there&apos;s an image here</Stack.Item>
                    <Stack.Item preserveWhitespace>
                      {selectedJobObj.description.join('\n')}
                    </Stack.Item>
                  </Stack>
                  <Stack.Item>{selectedJobObj.flavor.join('\n')}</Stack.Item>
                  <Stack.Item>
                    <ul>
                      {selectedJobObj.flavor.map((e) => (
                        <li key={e}>{e}</li>
                      ))}
                    </ul>
                  </Stack.Item>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
};
