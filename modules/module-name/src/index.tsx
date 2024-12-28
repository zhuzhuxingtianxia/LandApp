const ModuleName = require('./NativeModuleName').default;

export function multiply(a: number, b: number): number {
  return ModuleName.multiply(a, b);
}
