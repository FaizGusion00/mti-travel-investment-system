'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '../utils/cn';

const benefits = [
  {
    number: "01",
    title: "Exclusive Member Rewards",
    description: "Enjoy special deals, incentives, and rewards available only to Meta Travel International members.",
    delay: 0.1
  },
  {
    number: "02",
    title: "Exclusive Travel Opportunities",
    description: "Access premium travel packages and experiences available only to our community members.",
    delay: 0.2
  },
  {
    number: "03",
    title: "Cryptocurrency Growth",
    description: "Benefit from XLM staking rewards and potential cryptocurrency value appreciation.",
    delay: 0.3
  },
  {
    number: "04",
    title: "Global Networking",
    description: "Connect with a vibrant community of travelers, entrepreneurs, and professionals from around the world.",
    delay: 0.4
  }
];

const BenefitsSection = () => {
  return (
    <section id="benefits" className="py-24 px-4 sm:px-8 relative overflow-hidden">
      {/* Background elements */}
      <div className="absolute top-0 left-0 w-full h-32 bg-gradient-to-b from-black to-transparent z-10"></div>
      <div className="absolute bottom-0 left-0 w-full h-32 bg-gradient-to-t from-black to-transparent z-10"></div>
      
      {/* Animated background circles */}
      <div className="absolute left-1/4 top-1/3 w-96 h-96 rounded-full bg-[var(--accent-purple)]/5 blur-3xl"></div>
      <div className="absolute right-1/4 bottom-1/3 w-80 h-80 rounded-full bg-[var(--accent-blue)]/5 blur-3xl"></div>
      
      <div className="max-w-7xl mx-auto relative z-20">
        <motion.div 
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.7 }}
        >
          <motion.div
            className="inline-block mb-3 px-4 py-1 rounded-full bg-[rgba(157,78,221,0.1)] border border-[var(--accent-purple)] text-sm text-[var(--accent-purple)]"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1, duration: 0.7 }}
          >
            Why Choose Us
          </motion.div>
          
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            <span className="text-[var(--accent-purple)] text-glow-purple">Why</span> Join Us
          </h2>
          
          <p className="text-gray-300 max-w-2xl mx-auto text-lg">
            Experience the freedom to explore the world anytime in ultimate luxury, without limits.
          </p>
        </motion.div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 md:gap-16">
          {benefits.map((benefit, index) => (
            <motion.div 
              key={index}
              className="relative"
              initial={{ opacity: 0, x: index % 2 === 0 ? -30 : 30 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true, margin: "-100px" }}
              transition={{ duration: 0.6, delay: benefit.delay }}
            >
              {/* Number background */}
              <div className="absolute -left-8 -top-8 text-8xl font-bold text-[var(--accent-gold)]/10 select-none">
                {benefit.number}
              </div>
              
              <div className="relative z-10 flex gap-6 p-6 rounded-xl glass-effect border border-white/5 hover:border-[var(--accent-gold)]/30 transition-all duration-300">
                <div className="flex-shrink-0 w-12 h-12 rounded-full bg-gradient-to-br from-[var(--accent-purple)] to-[var(--accent-blue)] flex items-center justify-center text-white font-bold">
                  {benefit.number}
                </div>
                
                <div>
                  <h3 className="text-xl font-bold mb-3 text-white">{benefit.title}</h3>
                  <p className="text-gray-300">{benefit.description}</p>
                </div>
                
                {/* Decorative element */}
                <div className="absolute bottom-0 right-0 w-16 h-16 overflow-hidden">
                  <div className="absolute bottom-0 right-0 w-8 h-8 border-t border-l border-[var(--accent-gold)]/20 transform rotate-45 translate-x-1/2 translate-y-1/2"></div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
        
        <motion.div 
          className="mt-20 text-center"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 0.7, delay: 0.5 }}
        >
          <motion.a
            href="#download"
            className={cn(
              "inline-flex items-center gap-2 px-8 py-4 rounded-full",
              "bg-gradient-to-r from-[var(--accent-purple)] to-[var(--accent-blue)]",
              "text-white font-bold shadow-lg",
              "hover:shadow-[var(--accent-purple)]/20 transition-all duration-300"
            )}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <span>Join Our Community</span>
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clipRule="evenodd" />
            </svg>
          </motion.a>
        </motion.div>
      </div>
    </section>
  );
};

export default BenefitsSection;
