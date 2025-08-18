import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

const postService = {
  async getAllPosts(page = 0, size = 10) {
    const response = await axios.get(`${API_URL}/posts?page=${page}&size=${size}`);
    return response.data;
  },

  async getPostById(id) {
    const response = await axios.get(`${API_URL}/posts/${id}`);
    return response.data;
  },

  async createPost(postData) {
    const response = await axios.post(`${API_URL}/posts`, postData, {
      headers: getAuthHeaders()
    });
    return response.data;
  },

  async updatePost(id, postData) {
    const response = await axios.put(`${API_URL}/posts/${id}`, postData, {
      headers: getAuthHeaders()
    });
    return response.data;
  },

  async deletePost(id) {
    await axios.delete(`${API_URL}/posts/${id}`, {
      headers: getAuthHeaders()
    });
  },

  async likePost(id) {
    const response = await axios.post(`${API_URL}/posts/${id}/like`, {}, {
      headers: getAuthHeaders()
    });
    return response.data;
  },

  async addComment(id, commentData) {
    const response = await axios.post(`${API_URL}/posts/${id}/comments`, commentData, {
      headers: getAuthHeaders()
    });
    return response.data;
  },

  async searchPosts(query, page = 0, size = 10) {
    const response = await axios.get(`${API_URL}/posts/search?q=${query}&page=${page}&size=${size}`);
    return response.data;
  },

  async getPostsByTag(tag) {
    const response = await axios.get(`${API_URL}/posts/tags/${tag}`);
    return response.data;
  },

  async getUserPosts(userId, page = 0, size = 10) {
    const response = await axios.get(`${API_URL}/users/${userId}/posts?page=${page}&size=${size}`);
    return response.data;
  },

  async publishPost(id) {
    const response = await axios.post(`${API_URL}/posts/${id}/publish`, {}, {
      headers: getAuthHeaders()
    });
    return response.data;
  }
};

export { postService }; 