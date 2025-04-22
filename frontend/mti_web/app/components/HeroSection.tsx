'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '../utils/cn';

// Fixed star positions to avoid hydration errors
const starPositions = [
  { top: "5%", left: "10%", size: "1px", delay: 0 },
  { top: "15%", left: "25%", size: "2px", delay: 1 },
  { top: "25%", left: "50%", size: "1px", delay: 2 },
  { top: "10%", left: "70%", size: "3px", delay: 3 },
  { top: "20%", left: "85%", size: "1px", delay: 4 },
  { top: "35%", left: "15%", size: "2px", delay: 0.5 },
  { top: "45%", left: "35%", size: "1px", delay: 1.5 },
  { top: "55%", left: "65%", size: "2px", delay: 2.5 },
  { top: "65%", left: "40%", size: "1px", delay: 3.5 },
  { top: "75%", left: "20%", size: "3px", delay: 4.5 },
  { top: "85%", left: "60%", size: "1px", delay: 0.2 },
  { top: "95%", left: "80%", size: "2px", delay: 1.2 },
  { top: "30%", left: "90%", size: "1px", delay: 2.2 },
  { top: "40%", left: "5%", size: "3px", delay: 3.2 },
  { top: "50%", left: "75%", size: "1px", delay: 4.2 },
  { top: "60%", left: "30%", size: "2px", delay: 0.7 },
  { top: "70%", left: "55%", size: "1px", delay: 1.7 },
  { top: "80%", left: "45%", size: "3px", delay: 2.7 },
  { top: "90%", left: "15%", size: "1px", delay: 3.7 },
  { top: "15%", left: "65%", size: "2px", delay: 4.7 }
];

// Shooting star animation
const shootingStars = [
  { delay: 2, duration: 1.5, top: "15%", left: "10%" },
  { delay: 5, duration: 2, top: "45%", left: "80%" },
  { delay: 9, duration: 1.8, top: "75%", left: "20%" },
];

const HeroSection = () => {
  return (
    <section className="relative w-full min-h-screen flex flex-col md:flex-row items-center justify-center px-4 sm:px-8 py-24 pt-32">
      {/* Animated stars background */}
      <div className="absolute inset-0 overflow-hidden">
        {starPositions.map((position, i) => (
          <motion.div
            key={i}
            className="absolute bg-white rounded-full"
            style={{
              top: position.top,
              left: position.left,
              width: position.size,
              height: position.size,
            }}
            animate={{
              opacity: [0.1, 0.8, 0.1],
              scale: [1, 1.5, 1],
            }}
            transition={{
              duration: 3 + (i % 5),
              delay: position.delay,
              repeat: Infinity,
              repeatType: 'reverse',
            }}
          />
        ))}
        
        {/* Shooting stars */}
        {shootingStars.map((star, i) => (
          <motion.div
            key={`shooting-${i}`}
            className="absolute w-0.5 h-0.5 bg-white"
            style={{
              top: star.top,
              left: star.left,
            }}
            initial={{ 
              opacity: 0,
              width: "1px",
              rotate: -45,
              x: 0,
              y: 0,
            }}
            animate={{ 
              opacity: [0, 1, 0],
              width: ["1px", "150px", "1px"],
              x: [0, 200, 250],
              y: [0, 200, 250],
            }}
            transition={{
              duration: star.duration,
              delay: star.delay,
              repeat: Infinity,
              repeatDelay: 15,
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="z-10 w-full md:w-1/2 space-y-8 text-center md:text-left">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1 }}
        >
          <motion.div
            className="inline-block mb-2 px-4 py-1 rounded-full bg-[rgba(30,144,255,0.1)] border border-[var(--accent-blue)] text-sm text-[var(--accent-blue)]"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.7 }}
          >
            Welcome to the Future of Travel & Finance
          </motion.div>
          
          <motion.h1 
            className="text-5xl md:text-7xl font-bold leading-tight"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7 }}
          >
            <span className="text-[var(--accent-blue)] text-glow block">META TRAVEL</span>
            <span className="text-white block">INTERNATIONAL</span>
          </motion.h1>
        </motion.div>
        
        <motion.p 
          className="text-xl md:text-2xl text-gray-300 max-w-xl"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.2 }}
        >
          Explore a revolutionary MLM platform with travel rewards, referral bonuses, and XLM staking in a premium cosmic ecosystem.
        </motion.p>
        
        <motion.div
          className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.4 }}
        >
          <motion.a
            href="#download"
            className={cn(
              "px-8 py-4 rounded-full font-bold text-black",
              "gold-gradient hover:shadow-lg hover:shadow-[var(--accent-gold)]/20",
              "transition-all duration-300"
            )}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Download App
          </motion.a>
          
          <motion.a
            href="#benefits"
            className={cn(
              "px-8 py-4 rounded-full font-bold",
              "border-2 border-[var(--accent-gold)] text-white",
              "hover:bg-[var(--accent-gold)]/10 transition-all duration-300"
            )}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Learn More
          </motion.a>
        </motion.div>
      </div>
      
      {/* Placeholder for mobile app mockup */}
      <motion.div 
        className="z-10 w-full md:w-1/2 mt-16 md:mt-0 flex justify-center"
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.7, delay: 0.6 }}
      >
        <div className="relative w-72 h-[550px] md:w-80 md:h-[600px] animate-float">
          {/* Phone frame */}
          <div className="absolute inset-0 rounded-[40px] border-8 border-[#333] bg-black overflow-hidden shadow-2xl">
            {/* Screen content */}
            <div className="absolute inset-0 overflow-hidden">
              {/* App UI simulation */}
              <div className="absolute inset-0 bg-gradient-to-b from-[#0a0a2a] to-black">
                {/* Status bar */}
                <div className="h-6 bg-black/40 flex justify-between items-center px-4">
                  <div className="text-white text-xs">9:41</div>
                  <div className="flex space-x-1">
                    <div className="w-4 h-2 bg-white rounded-sm"></div>
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  </div>
                </div>
                
                {/* App content */}
                <div className="p-4">
                  <div className="flex justify-center mb-6">
                    <div className="text-[var(--accent-blue)] text-glow text-xl font-bold">META TRAVEL</div>
                  </div>
                  
                  <div className="bg-white/5 rounded-xl p-4 mb-4">
                    <div className="text-white text-sm font-bold mb-2">Welcome Back!</div>
                    <div className="h-2 w-3/4 bg-[var(--accent-gold)]/30 rounded-full mb-1"></div>
                    <div className="h-2 w-1/2 bg-[var(--accent-gold)]/30 rounded-full"></div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3 mb-4">
                    <div className="bg-white/5 rounded-xl p-3 h-24">
                      <div className="text-[var(--accent-gold)] text-xs mb-2">Wallet</div>
                      <div className="text-white text-lg font-bold">2,580 USDT</div>
                      <div className="text-green-400 text-xs">+12.5%</div>
                    </div>
                    <div className="bg-white/5 rounded-xl p-3 h-24">
                      <div className="text-[var(--accent-gold)] text-xs mb-2">XLM</div>
                      <div className="text-white text-lg font-bold">358.42</div>
                      <div className="text-green-400 text-xs">+5.2%</div>
                    </div>
                  </div>
                  
                  <div className="bg-[var(--accent-blue)]/10 border border-[var(--accent-blue)]/30 rounded-xl p-4">
                    <div className="text-white text-sm font-bold mb-2">Network Growth</div>
                    <div className="flex justify-between items-end h-16 mb-1">
                      <div className="w-2 h-4 bg-[var(--accent-blue)]/50 rounded-t-sm"></div>
                      <div className="w-2 h-8 bg-[var(--accent-blue)]/50 rounded-t-sm"></div>
                      <div className="w-2 h-6 bg-[var(--accent-blue)]/50 rounded-t-sm"></div>
                      <div className="w-2 h-10 bg-[var(--accent-blue)]/50 rounded-t-sm"></div>
                      <div className="w-2 h-12 bg-[var(--accent-blue)]/50 rounded-t-sm"></div>
                      <div className="w-2 h-16 bg-[var(--accent-blue)] rounded-t-sm"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            {/* Notch */}
            <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-1/3 h-6 bg-black rounded-b-xl"></div>
          </div>
          
          {/* Glow effect */}
          <div className="absolute -inset-4 bg-gradient-to-b from-[var(--accent-blue)] to-transparent opacity-20 rounded-[60px] blur-xl -z-10"></div>
        </div>
      </motion.div>
    </section>
  );
};

export default HeroSection;
