/**
 * Environment configuration for the MTI web application
 */
class Environment {
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
    return process.env.NEXT_PUBLIC_API_URL || 
      (this.isDevelopment ? 'http://localhost:8000' : 'https://api.mti.travel');
  }

  /**
   * Get the web app URL based on the current environment
   */
  static get webAppUrl(): string {
    return process.env.NEXT_PUBLIC_WEB_URL ||
      (this.isDevelopment ? 'http://localhost:3000' : 'https://mti.travel');
  }

  /**
   * Get test OTP for development mode
   */
  static get testOtp(): string {
    return this.isDevelopment ? '123456' : '';
  }
}

export default Environment; 