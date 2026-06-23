import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

type Theme = keyof typeof Colors;
type ColorName = keyof typeof Colors.light & keyof typeof Colors.dark;

export function useThemeColor(
  props: { light?: string; dark?: string },
  colorName: ColorName
) {
  const theme = (useColorScheme() ?? 'light') as Theme;
  const colorFromProps = props[theme];

  return colorFromProps ?? Colors[theme][colorName];
}