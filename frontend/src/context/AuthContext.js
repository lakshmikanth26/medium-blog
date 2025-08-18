import React, { createContext, useContext, useState, useEffect } from 'react';
import { authService } from '../services/authService';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [authLoading, setAuthLoading] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      authService.getProfile()
        .then(userData => {
          setUser(userData);
        })
        .catch(() => {
          localStorage.removeItem('token');
        })
        .finally(() => {
          setLoading(false);
        });
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (credentials) => {
    setAuthLoading(true);
    try {
      const response = await authService.login(credentials);
      localStorage.setItem('token', response.token);
      setUser({
        id: response.id,
        username: response.username,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName
      });
      return response;
    } catch (error) {
      console.error('Login error in context:', error);
      throw error; // Re-throw to let the component handle it
    } finally {
      setAuthLoading(false);
    }
  };

  const signup = async (userData) => {
    try {
      const response = await authService.signup(userData);
      localStorage.setItem('token', response.token);
      setUser({
        id: response.id,
        username: response.username,
        email: response.email,
        firstName: response.firstName,
        lastName: response.lastName
      });
      return response;
    } catch (error) {
      console.error('Signup error in context:', error);
      throw error; // Re-throw to let the component handle it
    }
  };

  const logout = () => {
    setAuthLoading(true);
    // Simulate a small delay to show loader (optional)
    setTimeout(() => {
      localStorage.removeItem('token');
      setUser(null);
      setAuthLoading(false);
    }, 300);
  };

  const value = {
    user,
    login,
    signup,
    logout,
    loading,
    authLoading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}; 