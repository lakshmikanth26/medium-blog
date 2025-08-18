import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

const authService = {
  async login(credentials) {
    const response = await axios.post(`${API_URL}/auth/login`, credentials);
    return response.data;
  },

  async signup(userData) {
    const response = await axios.post(`${API_URL}/auth/signup`, userData);
    return response.data;
  },

  async getProfile() {
    const token = localStorage.getItem('token');
    const response = await axios.get(`${API_URL}/users/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    return response.data;
  }
};

export { authService }; 