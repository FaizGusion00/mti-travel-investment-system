import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ErrorBoundary from "./components/ErrorBoundary";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Meta Travel International | E-Komuniti Platform",
  description: "Join Meta Travel International's MLM platform for travel rewards, referral bonuses, and XLM staking in a premium cosmic ecosystem.",
  keywords: "Meta Travel International, MLM, travel rewards, referral bonuses, XLM staking",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased cosmic-gradient-animated star-bg min-h-screen`}
      >
        <div className="fixed inset-0 z-[-1] bg-black opacity-50"></div>
        <ErrorBoundary>
          {children}
        </ErrorBoundary>
      </body>
    </html>
  );
}
