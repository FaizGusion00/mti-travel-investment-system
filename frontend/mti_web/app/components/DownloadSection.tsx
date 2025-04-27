'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { FaApple, FaGooglePlay } from 'react-icons/fa';
import { cn } from '../utils/cn';

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
          <motion.div 
            className="w-full lg:w-1/2 text-center lg:text-left"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.7 }}
          >
            <motion.div
              className="inline-block mb-3 px-4 py-1 rounded-full bg-[rgba(255,215,0,0.1)] border border-[var(--accent-gold)] text-sm text-[var(--accent-gold)]"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1, duration: 0.7 }}
            >
              Get Started Today
            </motion.div>
            
            <h2 className="text-4xl md:text-5xl font-bold mb-6">
              <span className="text-[var(--accent-gold)]">Download</span> Our App
            </h2>
            
            <p className="text-gray-300 text-lg mb-8 max-w-xl mx-auto lg:mx-0">
              Get started with Meta Travel International today. Download our app and begin your journey to financial freedom and exclusive travel experiences.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-6 justify-center lg:justify-start">
              <motion.a
                href="https://apps.apple.com/app/mti-travel-investment/id123456789" 
                className={cn(
                  "flex items-center gap-4 px-6 py-4",
                  "bg-black border-2 border-[var(--accent-gold)] rounded-xl",
                  "hover:bg-[var(--accent-gold)]/10 transition-all duration-300",
                  "w-full sm:w-auto"
                )}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.3 }}
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
              >
                <div className="w-12 h-12 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center">
                  <FaApple className="text-3xl text-[var(--accent-gold)]" />
                </div>
                <div className="text-left">
                  <div className="text-sm text-gray-400">Download on the</div>
                  <div className="text-xl font-bold text-white">App Store</div>
                </div>
              </motion.a>
              
              <motion.a
                href="https://play.google.com/store/apps/details?id=com.mti.travel.investment" 
                className={cn(
                  "flex items-center gap-4 px-6 py-4",
                  "bg-black border-2 border-[var(--accent-gold)] rounded-xl",
                  "hover:bg-[var(--accent-gold)]/10 transition-all duration-300",
                  "w-full sm:w-auto"
                )}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.4 }}
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
              >
                <div className="w-12 h-12 rounded-full bg-[var(--accent-gold)]/10 flex items-center justify-center">
                  <FaGooglePlay className="text-3xl text-[var(--accent-gold)]" />
                </div>
                <div className="text-left">
                  <div className="text-sm text-gray-400">Get it on</div>
                  <div className="text-xl font-bold text-white">Google Play</div>
                </div>
              </motion.a>
            </div>
            
            <motion.p
              className="mt-8 text-gray-400 text-sm"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.7, delay: 0.5 }}
            >
              Available for iOS and Android devices. Download now and join the Meta Travel International community.
            </motion.p>
          </motion.div>
          
          {/* Phone mockups */}
          <motion.div
            className="w-full lg:w-1/2 flex justify-center"
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.7, delay: 0.2 }}
          >
            <div className="relative">
              {/* First phone */}
              <motion.div 
                className="absolute -left-16 top-8 w-64 h-[500px] animate-float"
                style={{ animationDelay: "0.5s" }}
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.7, delay: 0.4 }}
              >
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
              </motion.div>
              
              {/* Second phone (main) */}
              <motion.div 
                className="relative z-20 w-72 h-[550px] animate-float"
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.7, delay: 0.3 }}
              >
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
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default DownloadSection;
