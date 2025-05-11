'use client';

import React from 'react';
import { cn } from '../utils/cn';

// Apple icon SVG component
interface IconProps {
  className?: string;
}

const AppleIcon: React.FC<IconProps> = ({ className }) => (
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512" width="24" height="24" fill="currentColor" className={className}>
    <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/>
  </svg>
);

// Google Play icon SVG component
const GooglePlayIcon: React.FC<IconProps> = ({ className }) => (
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="24" height="24" fill="currentColor" className={className}>
    <path d="M325.3 234.3L104.6 13l280.8 161.2-60.1 60.1zM47 0C34 6.8 25.3 19.2 25.3 35.3v441.3c0 16.1 8.7 28.5 21.7 35.3l256.6-256L47 0zm425.2 225.6l-58.9-34.1-65.7 64.5 65.7 64.5 60.1-34.1c18-14.3 18-46.5-1.2-60.8zM104.6 499l280.8-161.2-60.1-60.1L104.6 499z"/>
  </svg>
);

const DownloadSection = () => {
  return (
    <section id="download" className="py-24 px-4 sm:px-8 relative overflow-hidden">
      {/* Background elements */}
      <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-black to-transparent z-10"></div>
      <div className="absolute bottom-0 left-0 w-full h-32 bg-gradient-to-t from-black to-transparent z-10"></div>
      
      {/* Animated background circles */}
      <div className="absolute left-0 top-1/2 w-96 h-96 rounded-full bg-[var(--accent-gold)]/5 blur-3xl"></div>
      <div className="absolute right-0 top-1/4 w-80 h-80 rounded-full bg-[var(--accent-blue)]/5 blur-3xl"></div>
      
      <div className="max-w-7xl mx-auto relative z-20">
        <div className="flex flex-col lg:flex-row items-center gap-16">
          {/* Content */}
          <div className="w-full lg:w-1/2 text-center lg:text-left">
            <div className="inline-block mb-3 px-4 py-1 rounded-full bg-[rgba(255,215,0,0.1)] border border-[var(--accent-gold)] text-sm text-[var(--accent-gold)]">
              Get Started Today
            </div>
            
            <h2 className="text-4xl md:text-5xl font-bold mb-6">
              <span className="text-[var(--accent-gold)]">Download</span> Our App
            </h2>
            
            <p className="text-gray-300 text-lg mb-8 max-w-xl mx-auto lg:mx-0">
              Get started with Meta Travel International today. Download our app and begin your journey to financial freedom and exclusive travel experiences.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-6 justify-center lg:justify-start">
              <a
                href="https://apps.apple.com/app/mti-travel-investment/id123456789" 
                className={cn(
                  "flex items-center gap-4 px-6 py-4",
                  "bg-black border-2 border-[var(--accent-gold)] rounded-xl",
                  "hover:bg-[var(--accent-gold)]/10 transition-all duration-300",
                  "w-full sm:w-auto"
                )}
              >
                <div className="w-12 h-12 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center">
                  <AppleIcon className="text-3xl text-[var(--accent-gold)]" />
                </div>
                <div className="text-left">
                  <div className="text-sm text-gray-400">Download on the</div>
                  <div className="text-xl font-bold text-white">App Store</div>
                </div>
              </a>
              
              <a
                href="https://play.google.com/store/apps/details?id=com.mti.travel.investment" 
                className={cn(
                  "flex items-center gap-4 px-6 py-4",
                  "bg-black border-2 border-[var(--accent-gold)] rounded-xl",
                  "hover:bg-[var(--accent-gold)]/10 transition-all duration-300",
                  "w-full sm:w-auto"
                )}
              >
                <div className="w-12 h-12 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center">
                  <GooglePlayIcon className="text-3xl text-[var(--accent-gold)]" />
                </div>
                <div className="text-left">
                  <div className="text-sm text-gray-400">Get it on</div>
                  <div className="text-xl font-bold text-white">Google Play</div>
                </div>
              </a>
            </div>
            
            <p className="mt-8 text-gray-400 text-sm">
              Available for iOS and Android devices. Download now and join the Meta Travel International community.
            </p>
          </div>
          
          {/* Phone mockups */}
          <div className="w-full lg:w-1/2 flex justify-center">
            <div className="relative">
              {/* First phone */}
              <div className="absolute -left-16 top-8 w-64 h-[500px] animate-float" style={{ animationDelay: "0.5s" }}>
                <div className="absolute inset-0 rounded-[32px] border-8 border-[#333] bg-black overflow-hidden shadow-2xl">
                  {/* Screen content */}
                  <div className="absolute inset-0 overflow-hidden">
                    {/* App UI simulation - Wallet screen */}
                    <div className="absolute inset-0 bg-gradient-to-b from-[#0a0a2a] to-black p-4">
                      <div className="h-6 flex justify-between items-center">
                        <div className="text-white text-xs">9:41</div>
                        <div className="flex space-x-1">
                          <div className="w-4 h-1 bg-white rounded-sm"></div>
                        </div>
                      </div>
                      
                      <div className="mt-4 mb-6 flex justify-between items-center">
                        <div className="text-white font-bold">Wallet</div>
                        <div className="w-8 h-8 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center">
                          <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 text-[var(--accent-gold)]" viewBox="0 0 20 20" fill="currentColor">
                            <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                          </svg>
                        </div>
                      </div>
                      
                      <div className="bg-[var(--accent-gold)]/10 rounded-xl p-4 mb-4">
                        <div className="text-gray-400 text-xs">Total Balance</div>
                        <div className="text-white text-2xl font-bold mb-1">12,580.42 USDT</div>
                        <div className="text-green-400 text-xs">+1,245.80 USDT (10.8%)</div>
                      </div>
                      
                      <div className="space-y-3">
                        <div className="bg-white/5 rounded-lg p-3 flex justify-between items-center">
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-blue-500/20 flex items-center justify-center">
                              <span className="text-blue-400 font-bold">XLM</span>
                            </div>
                            <div>
                              <div className="text-white font-medium">Stellar</div>
                              <div className="text-gray-400 text-xs">358.42 XLM</div>
                            </div>
                          </div>
                          <div className="text-white">215.05 USDT</div>
                        </div>
                        
                        <div className="bg-white/5 rounded-lg p-3 flex justify-between items-center">
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-purple-500/20 flex items-center justify-center">
                              <span className="text-purple-400 font-bold">TR</span>
                            </div>
                            <div>
                              <div className="text-white font-medium">Travel</div>
                              <div className="text-gray-400 text-xs">2 Packages</div>
                            </div>
                          </div>
                          <div className="text-white">1,200 USDT</div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                {/* Glow effect */}
                <div className="absolute -inset-4 bg-gradient-to-b from-blue-500 to-purple-500 opacity-20 rounded-[60px] blur-xl -z-10"></div>
              </div>
              
              {/* Second phone (main) */}
              <div className="relative z-20 w-72 h-[550px] animate-float">
                <div className="absolute inset-0 rounded-[40px] border-8 border-[#333] bg-black overflow-hidden shadow-2xl">
                  {/* Screen content */}
                  <div className="absolute inset-0 overflow-hidden">
                    {/* App UI simulation - Home screen */}
                    <div className="absolute inset-0 bg-gradient-to-b from-[#0a0a2a] to-black">
                      <div className="h-6 bg-black/40 flex justify-between items-center px-4">
                        <div className="text-white text-xs">9:41</div>
                        <div className="flex space-x-1">
                          <div className="w-4 h-2 bg-white rounded-sm"></div>
                          <div className="w-2 h-2 bg-white rounded-full"></div>
                          <div className="w-2 h-2 bg-white rounded-full"></div>
                        </div>
                      </div>
                      
                      <div className="p-4">
                        <div className="flex justify-between items-center mb-6">
                          <div>
                            <div className="text-white text-lg font-bold">Welcome back,</div>
                            <div className="text-[var(--accent-gold)]">Izz Nasir</div>
                          </div>
                          <div className="w-10 h-10 rounded-full bg-[var(--accent-gold)]/20 flex items-center justify-center">
                            <span className="text-[var(--accent-gold)] font-bold">FG</span>
                          </div>
                        </div>
                        
                        <div className="bg-[var(--accent-blue)]/10 border border-[var(--accent-blue)]/30 rounded-xl p-4 mb-4">
                          <div className="flex justify-between items-center mb-2">
                            <div className="text-white font-bold">Total Earnings</div>
                            <div className="text-[var(--accent-blue)]">This Month</div>
                          </div>
                          <div className="text-white text-2xl font-bold mb-1">2,580.42 USDT</div>
                          <div className="text-green-400 text-xs">+245.80 USDT (10.5%)</div>
                        </div>
                        
                        <div className="grid grid-cols-2 gap-3 mb-4">
                          <div className="bg-white/5 rounded-xl p-3">
                            <div className="text-[var(--accent-gold)] text-xs mb-1">Referrals</div>
                            <div className="text-white text-lg font-bold">28</div>
                            <div className="text-green-400 text-xs">+5 this week</div>
                          </div>
                          <div className="bg-white/5 rounded-xl p-3">
                            <div className="text-[var(--accent-gold)] text-xs mb-1">Network</div>
                            <div className="text-white text-lg font-bold">142</div>
                            <div className="text-green-400 text-xs">Level 5</div>
                          </div>
                        </div>
                        
                        <div className="bg-white/5 rounded-xl p-4">
                          <div className="text-white font-bold mb-3">Quick Actions</div>
                          <div className="grid grid-cols-4 gap-2">
                            <div className="flex flex-col items-center">
                              <div className="w-10 h-10 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center mb-1">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[var(--accent-gold)]" viewBox="0 0 20 20" fill="currentColor">
                                  <path d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z" />
                                </svg>
                              </div>
                              <div className="text-white text-xs">Refer</div>
                            </div>
                            <div className="flex flex-col items-center">
                              <div className="w-10 h-10 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center mb-1">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[var(--accent-gold)]" viewBox="0 0 20 20" fill="currentColor">
                                  <path d="M4 4a2 2 0 00-2 2v1h16V6a2 2 0 00-2-2H4z" />
                                  <path fillRule="evenodd" d="M18 9H2v5a2 2 0 002 2h12a2 2 0 002-2V9zM4 13a1 1 0 011-1h1a1 1 0 110 2H5a1 1 0 01-1-1zm5-1a1 1 0 100 2h1a1 1 0 100-2H9z" clipRule="evenodd" />
                                </svg>
                              </div>
                              <div className="text-white text-xs">Wallet</div>
                            </div>
                            <div className="flex flex-col items-center">
                              <div className="w-10 h-10 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center mb-1">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[var(--accent-gold)]" viewBox="0 0 20 20" fill="currentColor">
                                  <path fillRule="evenodd" d="M12 7a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0V8.414l-4.293 4.293a1 1 0 01-1.414 0L8 10.414l-4.293 4.293a1 1 0 01-1.414-1.414l5-5a1 1 0 011.414 0L11 10.586 14.586 7H12z" clipRule="evenodd" />
                                </svg>
                              </div>
                              <div className="text-white text-xs">Stats</div>
                            </div>
                            <div className="flex flex-col items-center">
                              <div className="w-10 h-10 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center mb-1">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-[var(--accent-gold)]" viewBox="0 0 20 20" fill="currentColor">
                                  <path fillRule="evenodd" d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z" clipRule="evenodd" />
                                </svg>
                              </div>
                              <div className="text-white text-xs">Settings</div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  {/* Notch */}
                  <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-1/3 h-6 bg-black rounded-b-xl"></div>
                </div>
                
                {/* Glow effect */}
                <div className="absolute -inset-4 bg-gradient-to-b from-[var(--accent-gold)] to-[var(--accent-blue)] opacity-20 rounded-[60px] blur-xl -z-10"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default DownloadSection;
