import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { postService } from '../services/postService';

const CreatePost = () => {
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    excerpt: '',
    coverImage: '',
    tags: '',
    published: false
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData({
      ...formData,
      [name]: type === 'checkbox' ? checked : value
    });
  };

  const handleContentChange = (content) => {
    setFormData({
      ...formData,
      content
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const postData = {
        ...formData,
        tags: formData.tags.split(',').map(tag => tag.trim()).filter(tag => tag)
      };

      const post = await postService.createPost(postData);
      navigate(`/post/${post.id}`);
    } catch (error) {
      setError(error.response?.data?.message || 'Failed to create post. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const quillModules = {
    toolbar: [
      [{ 'header': [1, 2, 3, false] }],
      ['bold', 'italic', 'underline', 'strike'],
      [{ 'list': 'ordered'}, { 'list': 'bullet' }],
      [{ 'color': [] }, { 'background': [] }],
      ['link', 'image'],
      ['clean']
    ],
  };

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Create a New Story</h1>
        <p className="text-gray-600 mt-2">Share your thoughts with the world.</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
            Title
          </label>
          <input
            type="text"
            id="title"
            name="title"
            required
            className="input-field text-2xl font-bold"
            placeholder="Your story title"
            value={formData.title}
            onChange={handleChange}
          />
        </div>

        <div>
          <label htmlFor="excerpt" className="block text-sm font-medium text-gray-700 mb-2">
            Excerpt (Optional)
          </label>
          <textarea
            id="excerpt"
            name="excerpt"
            rows="3"
            className="input-field"
            placeholder="A brief summary of your story"
            value={formData.excerpt}
            onChange={handleChange}
          />
        </div>

        <div>
          <label htmlFor="coverImage" className="block text-sm font-medium text-gray-700 mb-2">
            Cover Image URL (Optional)
          </label>
          <input
            type="url"
            id="coverImage"
            name="coverImage"
            className="input-field"
            placeholder="https://example.com/image.jpg"
            value={formData.coverImage}
            onChange={handleChange}
          />
        </div>

        <div>
          <label htmlFor="tags" className="block text-sm font-medium text-gray-700 mb-2">
            Tags (Optional)
          </label>
          <input
            type="text"
            id="tags"
            name="tags"
            className="input-field"
            placeholder="technology, programming, web development"
            value={formData.tags}
            onChange={handleChange}
          />
          <p className="text-sm text-gray-500 mt-1">Separate tags with commas</p>
        </div>

        <div className="mb-16">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Content
          </label>
          <div className="border border-gray-300 rounded-lg mb-4">
            <ReactQuill
              theme="snow"
              value={formData.content}
              onChange={handleContentChange}
              modules={quillModules}
              placeholder="Start writing your story..."
              style={{ height: '400px', marginBottom: '60px' }}
            />
          </div>
        </div>

        <div className="flex items-center cursor-pointer mt-8 mb-6">
          <input
            type="checkbox"
            id="published"
            name="published"
            className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded cursor-pointer"
            checked={formData.published}
            onChange={handleChange}
          />
          <label htmlFor="published" className="ml-2 block text-sm text-gray-900 cursor-pointer">
            Publish immediately
          </label>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
            {error}
          </div>
        )}

        <div className="flex space-x-4">
          <button
            type="submit"
            disabled={loading}
            className="btn-primary"
          >
            {loading ? 'Creating...' : (formData.published ? 'Publish Story' : 'Save Draft')}
          </button>
          <button
            type="button"
            onClick={() => navigate('/')}
            className="btn-secondary"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreatePost; 