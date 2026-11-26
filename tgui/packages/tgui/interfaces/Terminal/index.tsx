/**
 * @file
 * @copyright 2022-2023
 * @author Original skeletonman0 (https://github.com/skeletonman0/)
 * @author Changes garash2k (https://github.com/garash2l)
 * @license MIT
 */

import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { Window } from '../../layouts';
import { PeripheralsSection } from './PeripheralsSection';
import { TerminalOutputSection } from './TerminalSection';
import type { TerminalData } from './types';

export const Terminal = (props) => {
  const { data } = useBackend<TerminalData>();
  const {
    bgColor,
    fontColor,
    inputMode,
    inputValue,
    peripherals,
    terminalContent,
    windowName,
  } = data;

  return (
    <Window theme="retro-dark" title={windowName} width={670} height={500}>
      <Window.Content fontFamily="Consolas">
        <Stack vertical fill>
          <Stack.Item grow>
            <TerminalOutputSection
              bgColor={bgColor}
              fontColor={fontColor}
              inputMode={inputMode}
              inputValue={inputValue}
              terminalContent={terminalContent}
            />
          </Stack.Item>
          <Stack.Item>
            <PeripheralsSection peripherals={peripherals} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
