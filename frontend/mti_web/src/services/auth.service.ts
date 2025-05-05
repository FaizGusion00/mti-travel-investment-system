import axios from 'axios';

const API_URL = 'http://localhost:8000/api/v1';

export interface RegisterData {
  full_name: string;
  email: string;
  phonenumber: string;
  address?: string;
  date_of_birth: string;
  ref_code?: string;
  password: string;
  profile_image?: File;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface UserProfile {
  id: number;
  full_name: string;
  email: string;
  phonenumber: string;
  address?: string;
  date_of_birth: string;
  ref_code: string;
  profile_image?: string;
  created_at?: string;
  updated_at?: string;
}

class AuthService {
  private token: string | null = null;

  constructor() {
    this.token = localStorage.getItem('token');
  }

  private getHeaders() {
    return {
      'Content-Type': 'application/json',
      ...(this.token ? { 'Authorization': `Bearer ${this.token}` } : {})
    };
  }

  async register(data: RegisterData): Promise<{ user: UserProfile; token: string }> {
    const formData = new FormData();
    
    // Append all text fields
    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined && key !== 'profile_image') {
        formData.append(key, String(value));
      }
    });

    // Append profile image if exists
    if (data.profile_image) {
      formData.append('profile_image', data.profile_image);
    }

    const response = await axios.post<{ user: UserProfile; token: string }>(`${API_URL}/register`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    if (response.data.token) {
      this.token = response.data.token;
      localStorage.setItem('token', response.data.token);
    }

    return response.data;
  }

  async login(data: LoginData): Promise<{ user: UserProfile; token: string }> {
    const response = await axios.post<{ user: UserProfile; token: string }>(`${API_URL}/login`, data);

    if (response.data.token) {
      this.token = response.data.token;
      localStorage.setItem('token', response.data.token);
    }

    return response.data;
  }

  async getProfile(): Promise<UserProfile> {
    const response = await axios.get<{ user: UserProfile }>(`${API_URL}/profile`, {
      headers: this.getHeaders()
    });
    return response.data.user;
  }

  async updateProfile(data: Partial<UserProfile> & { profile_image?: File }): Promise<UserProfile> {
    const formData = new FormData();
    
    // Append all text fields
    Object.entries(data).forEach(([key, value]) => {
      if (value !== undefined && key !== 'profile_image') {
        formData.append(key, String(value));
      }
    });

    // Append profile image if exists
    if (data.profile_image) {
      formData.append('profile_image', data.profile_image);
    }

    const response = await axios.put<{ user: UserProfile }>(`${API_URL}/profile`, formData, {
      headers: {
        ...this.getHeaders(),
        'Content-Type': 'multipart/form-data'
      }
    });

    return response.data.user;
  }

  logout(): void {
    this.token = null;
    localStorage.removeItem('token');
  }

  isAuthenticated(): boolean {
    return !!this.token;
  }

  async generateNewToken(): Promise<{ token: string; expires_at: string }> {
    const response = await axios.post<{ token: string; expires_at: string }>(
      `${API_URL}/token/generate`,
      {},
      { headers: this.getHeaders() }
    );

    if (response.data.token) {
      this.token = response.data.token;
      localStorage.setItem('token', response.data.token);
    }

    return response.data;
  }

  async getTokenInfo(): Promise<{
    token_id: number;
    name: string;
    abilities: string[];
    last_used_at: string;
    expires_at: string;
  }> {
    const response = await axios.get(
      `${API_URL}/token/info`,
      { headers: this.getHeaders() }
    );
    return (response.data as { token_info: {
      token_id: number;
      name: string;
      abilities: string[];
      last_used_at: string;
      expires_at: string;
    }}).token_info;
  }

  async revokeAllTokens(): Promise<void> {
    await axios.post(
      `${API_URL}/token/revoke`,
      {},
      { headers: this.getHeaders() }
    );
    this.logout();
  }

  async checkAndRefreshTokenIfNeeded(): Promise<boolean> {
    try {
      const tokenInfo = await this.getTokenInfo();
      const expiresAt = new Date(tokenInfo.expires_at);
      
      // If token expires in less than 1 day, generate a new one
      if (expiresAt.getTime() - Date.now() < 24 * 60 * 60 * 1000) {
        await this.generateNewToken();
      }
      return true;
    } catch {
      return false;
    }
  }
}

export const authService = new AuthService(); 