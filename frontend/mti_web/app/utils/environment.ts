/**
 * Environment configuration for the MTI web application
 */
class Environment {
  /**
   * Toggle this flag to switch between localhost and production server in development mode
   * - true: Use localhost:8000 for development
   * - false: Use panel.metatravel.ai (via proxy) for development
   */
  static useLocalServer: boolean = false;

  /**
   * Toggle to use production Turnstile keys vs test keys
   * - true: Use production keys (for production environment)
   * - false: Use test keys (for development/testing)
   * 
   * IMPORTANT: For local development, set this to FALSE to avoid Cloudflare domain verification issues
   * Documentation: https://developers.cloudflare.com/turnstile/get-started/
   */
  static useTurnstileProductionKeys: boolean = true;
  
  /**
   * Determine if the app is running in production mode
   */
  static get isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
  }

  /**
   * Determine if the app is running in development mode
   */
  static get isDevelopment(): boolean {
    return !this.isProduction;
  }

  /**
   * Get the API base URL based on the current environment
   */
  static get apiBaseUrl(): string {
    // Check for environment variable first
    if (typeof window !== 'undefined' && window.location.hostname === 'panel.metatravel.ai') {
      return 'https://panel.metatravel.ai';
    }

    if (process.env.NEXT_PUBLIC_API_URL) {
      return process.env.NEXT_PUBLIC_API_URL;
    }
    
    // In development mode, use either localhost or proxy based on toggle
    if (this.isDevelopment) {
      return this.useLocalServer 
        ? 'http://localhost:8000' // Direct to localhost without /api/v1 suffix
        : '';                     // Empty base for proxy to panel.metatravel.ai
    }
    
    // In production, always use the production URL
    return 'https://panel.metatravel.ai';
  }

  /**
   * Get the web app URL based on the current environment
   */
  static get webAppUrl(): string {
    if (typeof window !== 'undefined') {
      return window.location.origin; // Use current origin when in browser
    }
    
    return process.env.NEXT_PUBLIC_WEB_URL ||
      (this.isDevelopment ? 'http://localhost:3000' : 'https://panel.metatravel.ai');
  }

  /**
   * Get test OTP for development mode
   */
  static get testOtp(): string {
    return ''; // Always return empty string to allow user input
  }

  /**
   * Get Cloudflare Turnstile site key based on the environment
   * 
   * Production key should only be used in production environment or when specifically testing with production keys
   * Test key (1x00000000000000000000AA) always passes verification without domain validation
   */
  static get turnstileSiteKey(): string {
    // In development, use test key unless explicitly configured to use production keys
    if (this.isDevelopment && !this.useTurnstileProductionKeys) {
      console.log('[Turnstile] Using TEST key (development mode)');
      return '1x00000000000000000000AA'; // Test key (always passes verification)
    }
    
    // Production key - only use in production or when explicitly testing with production keys
    console.log('[Turnstile] Using PRODUCTION key');
    return '0x4AAAAAABT-8FrRBkgeluJo';
  }

  /**
   * Alias for compatibility: Get Cloudflare Turnstile site key (for use as captchaSiteKey)
   */
  static get captchaSiteKey(): string {
    return this.turnstileSiteKey;
  }

  /**
   * Email configuration settings
   */
  static get emailConfig() {
    return {
      // Company display name for emails
      companyName: 'MetaTravel.ai',
      
      // Primary support email address
      supportEmail: 'support@metatravel.ai',
      
      // Brand colors used in email templates (must match backend email templates)
      colors: {
        primary: '#FFD700', // Gold
        background: '#181818', // Dark background
        text: '#FFFFFF', // White text
        textSecondary: '#CCCCCC' // Light gray text
      },
      
      // Email verification settings
      verification: {
        otpExpiryMinutes: 15, // OTP expiry time in minutes
        retryDelaySeconds: 60 // Delay before allowing resend
      }
    };
  }

  /**
   * API endpoint configuration
   */
  static get apiEndpoints() {
    return {
      auth: {
        register: '/api/v1/register',
        verifyOtp: '/api/v1/verify-otp',
        resendOtp: '/api/v1/resend-otp',
        backupRegistration: '/api/v1/backup-registration'
      }
    };
  }
}

export default Environment; 