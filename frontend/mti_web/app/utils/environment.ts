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
   * - true: Use production keys
   * - false: Use test keys
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
    if (process.env.NEXT_PUBLIC_API_URL) {
      return process.env.NEXT_PUBLIC_API_URL;
    }
    
    // In development mode, use either localhost or proxy based on toggle
    if (this.isDevelopment) {
      return this.useLocalServer 
        ? 'http://localhost:8000/api/v1' // Direct to localhost
        : '/api/v1';                     // Proxy to panel.metatravel.ai
    }
    
    // In production, always use the production URL
    return 'https://panel.metatravel.ai/api/v1';
  }

  /**
   * Get the web app URL based on the current environment
   */
  static get webAppUrl(): string {
    return process.env.NEXT_PUBLIC_WEB_URL ||
      (this.isDevelopment ? 'http://localhost:3000' : 'https://panel.metatravel.ai');
  }

  /**
   * Get test OTP for development mode
   */
  static get testOtp(): string {
    return this.isDevelopment ? '123456' : '';
  }

  /**
   * Get Cloudflare Turnstile site key based on the environment
   */
  static get turnstileSiteKey(): string {
    // Production key
    if (this.useTurnstileProductionKeys) {
      return '0x4AAAAAABT-8FrRBkgeluJo';
    }
    // Test key for development (always passes verification)
    return '1x00000000000000000000AA';
  }
}

export default Environment; 