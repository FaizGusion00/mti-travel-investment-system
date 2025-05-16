'use client';

import dynamic from 'next/dynamic';

// Dynamically import the environment switcher component
const DevEnvironmentSwitcher = dynamic(
  () => import('./DevEnvironmentSwitcher'),
  { ssr: false }
);

// Client component wrapper for the environment switcher
export default function ClientEnvironmentSwitcher() {
  return <DevEnvironmentSwitcher />;
}
