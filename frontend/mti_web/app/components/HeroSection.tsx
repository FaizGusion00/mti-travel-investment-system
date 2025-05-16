'use client';

import React from 'react';
import { motion } from 'framer-motion';
import type { HTMLMotionProps } from 'framer-motion';
import { cn } from '../utils/cn';
import Image from 'next/image';

// Update Swiper imports for v11.x
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay, EffectFade } from 'swiper/modules';

// Import Swiper styles
import 'swiper/css';
import 'swiper/css/pagination';
import 'swiper/css/navigation';
import 'swiper/css/effect-fade';

// Define component types
type MotionButtonProps = HTMLMotionProps<"button">;
type MotionDivProps = HTMLMotionProps<"div">;

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
    <section className="py-16 sm:py-20 md:py-24 lg:py-32 px-4 sm:px-6 md:px-8 relative overflow-hidden mx-auto">
      {/* Animated stars background */}
      <div className="absolute inset-0 overflow-hidden">
        {starPositions.map((position, i) => (
          <motion.div
            key={i}
            style={{
              top: position.top,
              left: position.left,
              width: position.size,
              height: position.size,
              position: 'absolute',
              borderRadius: '9999px',
              backgroundColor: 'white',
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
            style={{
              top: star.top,
              left: star.left,
              position: 'absolute',
              width: '0.125rem',
              height: '0.125rem',
              backgroundColor: 'white',
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
      <div className="w-full max-w-6xl mx-auto relative space-y-8 md:space-y-12 text-center">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 1 }}
          style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}
        >
          <div className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 relative overflow-hidden mb-4 sm:mb-6">
              <Image 
                src="/logo.png" 
                alt="MTI Logo" 
                width={400} 
                height={400}
                className="mx-auto object-contain"
              />
          </div>
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3, duration: 0.7 }}
            style={{ 
              display: 'inline-block',
              marginBottom: '1rem',
              padding: '0.5rem 1.5rem',
              borderRadius: '9999px',
              background: 'rgba(30,144,255,0.1)',
              backdropFilter: 'blur(4px)',
              border: '1px solid rgba(30,144,255, 0.4)',
              fontSize: '0.9rem',
              letterSpacing: '0.5px',
              color: 'rgb(30,144,255)',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
            }}
          >
            Let's Travel & Earn Income
          </motion.div>
          
          <motion.h1 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7 }}
            style={{
              fontSize: 'clamp(2.5rem, 8vw, 3.5rem)',
              lineHeight: '1.1',
              fontWeight: '800',
              letterSpacing: '-0.02em',
              marginBottom: '1.5rem',
            }}
          >
            <span style={{ 
              color: 'var(--accent-blue)', 
              display: 'block', 
              textShadow: '0 0 15px rgba(30,144,255,0.7)',
              background: 'linear-gradient(135deg, #4dabf7 0%, #1e90ff 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}>META TRAVEL</span>
            <span style={{ 
              color: 'var(--accent-gold)', 
              display: 'block', 
              fontSize: 'clamp(2rem, 7vw, 3rem)',
              background: 'linear-gradient(135deg, #ffd700 0%, #e6b800 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
            }}>INTERNATIONAL</span>
          </motion.h1>
        </motion.div>
        
        <motion.p 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.2 }}
          style={{
            fontSize: 'clamp(1rem, 2vw, 1.25rem)',
            lineHeight: '1.7',
            color: 'rgba(255, 255, 255, 0.9)',
            fontWeight: '300',
            maxWidth: '40rem',
            margin: '0 auto 1.5rem',
            textAlign: 'center',
            padding: '0 0.5rem',
          }}
        >
          Enjoy the chance to explore destinations around the world at no cost through our exclusive travel programs.
        </motion.p>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.4 }}
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '1rem',
            justifyContent: 'center',
          }}
        >
          <div className="flex flex-col sm:flex-row gap-4 sm:gap-6 justify-center px-4 sm:px-0">
            <button
              className="group relative py-3 px-6 sm:px-10 sm:py-4 rounded-full font-bold text-black transition-all duration-300 overflow-hidden"
              style={{
                background: 'linear-gradient(135deg, #ffd700 0%, #e6b800 100%)',
                border: 'none',
                cursor: 'pointer',
                boxShadow: '0 4px 30px rgba(230, 184, 0, 0.3), 0 2px 16px rgba(230, 184, 0, 0.2)',
                transform: 'translateZ(0)',
                fontSize: 'clamp(0.875rem, 1vw, 1rem)',
                fontWeight: '600',
                letterSpacing: '0.5px',
                minWidth: 'min(80%, 180px)',
              }}
              onClick={() => {
                window.location.href = "#download";
              }}
            >
              <span className="relative z-10">Download App</span>
              <span className="absolute inset-0 bg-white/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
            </button>
            
            <button
              className="group relative py-3 px-6 sm:px-10 sm:py-4 rounded-full font-bold text-white transition-all duration-300 overflow-hidden"
              style={{
                background: 'transparent',
                border: '2px solid var(--accent-gold)',
                cursor: 'pointer',
                boxShadow: '0 4px 20px rgba(230, 184, 0, 0.1)',
                fontSize: 'clamp(0.875rem, 1vw, 1rem)',
                fontWeight: '600',
                letterSpacing: '0.5px',
                minWidth: 'min(80%, 180px)',
              }}
              onClick={() => {
                window.location.href = "https://app.metatravel.ai";
              }}
            >
              <span className="relative z-10">Login</span>
              <span className="absolute inset-0 bg-[var(--accent-gold)]/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
            </button>
          </div>
        </motion.div>
      </div>
      
      {/* Mobile app mockup */}
      <div className="z-10 w-full max-w-6xl mx-auto mt-12 sm:mt-16 md:mt-24 flex justify-center items-center relative">
        <div className="w-full md:w-4/5 lg:w-3/4 max-w-[500px] relative mx-auto">
          <Swiper
            spaceBetween={0}
            centeredSlides={true}
            effect="fade"
            autoplay={{
              delay: 3000,
              disableOnInteraction: false,
            }}
            modules={[Autoplay, EffectFade]}
            style={{
              width: '100%',
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              margin: '0 auto',
            }}
          >
            <SwiperSlide>
              <motion.div 
                style={{ 
                  width: '100%',
                  maxWidth: '400px',
                  position: 'relative',
                  margin: '0 auto'
                }}
                animate={{ 
                  y: [0, -10, 0],
                }}
                transition={{
                  duration: 6,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              >
                <div className="phone-frame relative">
                  <Image
                    src="/hero/mti_promo_1.png" 
                    alt="MTI Package 1" 
                    width={500}
                    height={900}
                    className="w-full h-auto"
                    style={{ 
                      border: '10px solid #111',
                      borderRadius: '38px',
                      boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.5)',
                      filter: 'contrast(1.05) brightness(1.05)',
                    }}
                    priority
                    quality={100}
                  />
                  {/* Phone details */}
                  <div className="absolute top-[10px] left-1/2 transform -translate-x-1/2 w-1/3 h-[16px] sm:h-[22px] bg-black rounded-b-[12px] sm:rounded-b-[16px] z-10 flex justify-center items-center">
                    <div className="w-[40%] h-2 sm:h-3 bg-black rounded-full relative">
                      <div className="absolute left-[16%] top-1/2 transform -translate-y-1/2 w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full bg-[#333]"></div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </SwiperSlide>
            <SwiperSlide>
              <motion.div 
                style={{ 
                  width: '100%',
                  maxWidth: '400px',
                  position: 'relative',
                  margin: '0 auto'
                }}
                animate={{ 
                  y: [0, -10, 0],
                }}
                transition={{
                  duration: 6,
                  repeat: Infinity,
                  ease: "easeInOut"
                }}
              >
                <div className="phone-frame relative">
                  <Image
                    src="/hero/mti_promo_2.png" 
                    alt="MTI Package 2" 
                    width={500}
                    height={900}
                    className="w-full h-auto"
                    style={{ 
                      border: '10px solid #111',
                      borderRadius: '38px',
                      boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.5)',
                      filter: 'contrast(1.05) brightness(1.05)',
                    }}
                    priority
                    quality={100}
                  />
                  {/* Phone details */}
                  <div className="absolute top-[10px] left-1/2 transform -translate-x-1/2 w-1/3 h-[16px] sm:h-[22px] bg-black rounded-b-[12px] sm:rounded-b-[16px] z-10 flex justify-center items-center">
                    <div className="w-[40%] h-2 sm:h-3 bg-black rounded-full relative">
                      <div className="absolute left-[16%] top-1/2 transform -translate-y-1/2 w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full bg-[#333]"></div>
                    </div>
                  </div>
                </div>
              </motion.div>
            </SwiperSlide>
          </Swiper>
        </div>
      </div>
      
    </section>
  );
};

export default HeroSection;
