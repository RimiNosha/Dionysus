// This is just a wrapper for preference type IDs to their components.
// Intentionally dumber than TGUI prefs.
// Keep it simple, stupid.

// If you change this, make sure to update the preferences define file too.

import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { PreferencesMenuData } from './data';
import {
  CheckboxInput,
  CheckboxInputInverse,
  FeatureColorInput,
  FeatureDropdownInput,
  FeatureIconnedDropdownInput,
  FeatureNumberInput,
  FeatureShortTextInput,
  FeatureTextInput,
  FeatureTriColorInput,
  FeatureValue,
  FeatureValueInput,
} from './preferences/features/base';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export const FEATURE_ID_TO_COMPONENT: Record<
  string,
  FeatureValue<unknown, unknown, unknown>
> = {
  color: FeatureColorInput,
  checkbox: CheckboxInput,
  checkbox_inverse: CheckboxInputInverse,
  dropdown: FeatureDropdownInput,
  iconned_dropdown: FeatureIconnedDropdownInput,
  number: FeatureNumberInput,
  large_text: FeatureTextInput,
  short_text: FeatureShortTextInput,
  tri_color: FeatureTriColorInput,
};

export const PreferenceDataComponent = (props: {
  prefCategory: string;
  prefId: string;
}) => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return;
        }
        const { act, data } = useBackend<PreferencesMenuData>();
        const prefData = serverData[props.prefId];
        return FEATURE_ID_TO_COMPONENT[prefData.feature] ? (
          <FeatureValueInput
            act={(action, data) => {
              act(action, data);
            }}
            feature={FEATURE_ID_TO_COMPONENT[prefData.feature]}
            featureId={props.prefId}
            shrink
            value={data.character_preferences[props.prefCategory][props.prefId]}
          />
        ) : (
          'INVALID FEATURE FOR ' + props.prefId
        );
      }}
    />
  );
};

export const AllFeaturesInCategory = (props: { category: string }) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        return (
          <Stack fill vertical>
            {Object.keys(data.character_preferences[props.category]).map(
              (k) => {
                if (!serverData || serverData[k].feature === 'none') {
                  return;
                }
                return (
                  <Stack.Item key={k}>
                    <Stack>
                      <Stack.Item width="50%">
                        {serverData[k].name!!}
                      </Stack.Item>
                      <Stack.Item width="50%">
                        <PreferenceDataComponent
                          prefCategory={props.category}
                          prefId={k}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                );
              },
            )}
          </Stack>
        );
      }}
    />
  );
};
