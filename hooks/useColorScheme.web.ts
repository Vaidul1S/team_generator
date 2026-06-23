import { useEffect, useState } from 'react';
import { useColorScheme as useRNColorScheme } from 'react-native';

export function useColorScheme(): 'light' | 'dark' {
  const [hasHydrated, setHasHydrated] = useState(false);
  const colorScheme = useRNColorScheme();

  useEffect(() => {
    setHasHydrated(true);
  }, []);

  const resolvedScheme = colorScheme === 'dark' ? 'dark' : 'light';
  return hasHydrated ? resolvedScheme : 'light';
}