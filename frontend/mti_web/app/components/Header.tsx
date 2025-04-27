'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { cn } from '../utils/cn';
import Link from 'next/link';
import Image from 'next/image';

const Header = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [activeLink, setActiveLink] = useState('');

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
      
      // Determine which section is in view
      const sections = ['features', 'benefits', 'download'];
      for (const section of sections) {
        const element = document.getElementById(section);
        if (element) {
          const rect = element.getBoundingClientRect();
          if (rect.top <= 100 && rect.bottom >= 100) {
            setActiveLink(section);
            break;
          }
        }
      }
    };
    
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navItems = [
    { name: 'Features', href: '#features' },
    { name: 'Benefits', href: '#benefits' },
    { name: 'Download', href: '#download' }
  ];

  return (
    <>
      <motion.header 
        className={cn(
          "fixed top-0 left-0 right-0 z-50 py-3 px-4 md:px-6 transition-all duration-300",
          isScrolled 
            ? "bg-black/80 backdrop-blur-md border-b border-blue-500/20" 
            : "bg-transparent"
        )}
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
      >
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <motion.div 
            className="flex items-center"
            whileHover={{ scale: 1.02 }}
          >
            <Link href="/" className="flex items-center gap-2">
              <div className="w-10 h-10 relative overflow-hidden">
                <Image 
                  src="/logo.png" 
                  alt="MTI Logo" 
                  width={40} 
                  height={40}
                  className="object-contain"
                />
              </div>
              <div className="hidden sm:block">
                <h1 className="text-xl md:text-2xl font-bold flex items-center">
                  <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-blue-600">META</span>
                  <span className="bg-clip-text text-transparent bg-gradient-to-r from-yellow-400 to-amber-500 ml-1">TRAVEL</span>
                  <span className="text-white ml-1">INTL</span>
                </h1>
              </div>
            </Link>
          </motion.div>
          
          <nav className="hidden md:flex items-center space-x-1">
            <div className="bg-gray-900/50 rounded-full p-1 backdrop-blur-sm border border-white/10 mx-auto">
              <div className="flex space-x-1">
                {navItems.map((item, index) => (
                  <NavItem 
                    key={item.name} 
                    href={item.href} 
                    delay={index * 0.1}
                    isActive={activeLink === item.href.substring(1)}
                  >
                    {item.name}
                  </NavItem>
                ))}
              </div>
            </div>
            
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="ml-4"
            >
              <Link 
                href="/register" 
                className="relative group inline-flex items-center justify-center px-6 py-2 overflow-hidden font-medium rounded-md"
              >
                <span className="absolute inset-0 w-full h-full bg-gradient-to-br from-blue-600 via-indigo-600 to-purple-600"></span>
                <span className="absolute bottom-0 right-0 block w-64 h-64 mb-32 mr-4 transition duration-500 origin-bottom-left transform rotate-45 translate-x-24 bg-blue-500 rounded-full opacity-30 group-hover:rotate-90 ease"></span>
                <span className="relative text-white font-semibold">Register</span>
              </Link>
            </motion.div>
          </nav>
          
          <motion.button
            className="md:hidden text-white text-2xl focus:outline-none z-50"
            whileTap={{ scale: 0.9 }}
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            aria-label="Toggle menu"
          >
            <div className="relative w-8 h-8">
              <span className={`absolute block h-0.5 w-full bg-current transform transition duration-500 ease-in-out ${isMobileMenuOpen ? 'rotate-45' : '-translate-y-2'}`}></span>
              <span className={`absolute block h-0.5 w-full bg-current transform transition duration-200 ease-in-out ${isMobileMenuOpen ? 'opacity-0' : 'opacity-100'}`}></span>
              <span className={`absolute block h-0.5 w-full bg-current transform transition duration-500 ease-in-out ${isMobileMenuOpen ? '-rotate-45' : 'translate-y-2'}`}></span>
            </div>
          </motion.button>
        </div>
      </motion.header>

      {/* Mobile menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div 
            className="fixed inset-0 z-40 bg-gradient-to-b from-black via-blue-950/90 to-black backdrop-blur-md pt-24 px-6"
            initial={{ opacity: 0, clipPath: "circle(0% at top right)" }}
            animate={{ opacity: 1, clipPath: "circle(150% at top right)" }}
            exit={{ opacity: 0, clipPath: "circle(0% at top right)" }}
            transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
          >
            <div className="flex flex-col space-y-6 items-center">
              {navItems.map((item, index) => (
                <motion.a
                  key={item.name}
                  href={item.href}
                  className="text-white text-2xl font-semibold hover:text-blue-400 transition-all duration-300 relative group"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.1 + index * 0.1 }}
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.name}
                  <span className="block max-w-0 group-hover:max-w-full transition-all duration-500 h-0.5 bg-gradient-to-r from-blue-400 to-purple-600"></span>
                </motion.a>
              ))}
              
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
                className="w-full max-w-xs mt-4"
              >
                <Link 
                  href="/register" 
                  className="flex items-center justify-center w-full px-8 py-4 text-lg font-bold text-white rounded-lg bg-gradient-to-r from-blue-600 to-indigo-700 hover:shadow-lg hover:shadow-blue-500/30 transition-all duration-300 transform hover:-translate-y-1"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  <span className="mr-2">Create Account</span>
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </Link>
              </motion.div>
              
              <div className="absolute bottom-10 left-0 right-0 flex justify-center">
                <motion.div
                  className="flex space-x-4"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.5 }}
                >
                  <SocialIcon icon="facebook" />
                  <SocialIcon icon="twitter" />
                  <SocialIcon icon="instagram" />
                  <SocialIcon icon="linkedin" />
                </motion.div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

const NavItem = ({ href, children, delay = 0, isActive = false }: { href: string, children: React.ReactNode, delay?: number, isActive?: boolean }) => {
  return (
    <motion.a 
      href={href}
      className={cn(
        "relative px-4 py-2 text-sm font-medium rounded-full transition-colors duration-300 hover:text-white",
        isActive ? "text-white" : "text-gray-300"
      )}
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration: 0.5 }}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      {children}
      {isActive && (
        <motion.span 
          className="absolute inset-0 rounded-full bg-gradient-to-r from-blue-600/20 to-indigo-600/20 -z-10"
          layoutId="activeNavItem"
          transition={{ type: "spring", duration: 0.6 }}
        />
      )}
    </motion.a>
  );
};

const SocialIcon = ({ icon }: { icon: string }) => {
  return (
    <motion.a
      href="#"
      className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-blue-600 hover:to-purple-600 transition-all duration-300"
      whileHover={{ scale: 1.2, rotate: 5 }}
      whileTap={{ scale: 0.9 }}
    >
      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
        <path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd" />
      </svg>
    </motion.a>
  );
};

export default Header;
