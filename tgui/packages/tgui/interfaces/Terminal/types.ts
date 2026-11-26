/**
 * @file
 * @copyright 2023
 * @author Garash2k (https://github.com/garash2k)
 * @license ISC
 */

import { BooleanLike } from 'common/react';

export type PeripheralData = {
  clown?: BooleanLike;
  color?: string;
  disabled?: BooleanLike;
  extraInfo?: Record<string, any>;
  icon: string;
  kind: string;
  label: string;
};

export type TerminalData = {
  bgColor: string;
  ckey: string;
  fontColor: string;
  inputMode: InputMode;
  inputValue: string;
  loadTimestamp: number;
  noScroll: boolean;
  peripherals: Array<PeripheralData>;
  terminalActive: BooleanLike;
  terminalContent: string;
  windowName: string;
};

export enum InputMode {
  DIRECT = 'direct',
  LINE = 'line',
}
