import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { postService } from '../services/postService';

const PostDetail = () => {
  const { id } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [post, setPost] = useState(null);
  const [loading, setLoading] = useState(true);
  const [comment, setComment] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [publishing, setPublishing] = useState(false);

  useEffect(() => {
    loadPost();
  }, [id]);

  const loadPost = async () => {
    try {
      const postData = await postService.getPostById(id);
      setPost(postData);
    } catch (error) {
      console.error('Error loading post:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLike = async () => {
    if (!user) {
      navigate('/login');
      return;
    }

    try {
      const updatedPost = await postService.likePost(id);
      setPost(updatedPost);
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  const handleComment = async (e) => {
    e.preventDefault();
    if (!user) {
      navigate('/login');
      return;
    }

    if (!comment.trim()) return;

    setSubmitting(true);
    try {
      const updatedPost = await postService.addComment(id, { content: comment });
      setPost(updatedPost);
      setComment('');
    } catch (error) {
      console.error('Error adding comment:', error);
    } finally {
      setSubmitting(false);
    }
  };

  const handlePublish = async () => {
    if (!user || !post || post.authorId !== user.id) {
      alert('You are not authorized to publish this post.');
      return;
    }

    // Debug information
    const token = localStorage.getItem('token');
    console.log('Publishing post. User:', user);
    console.log('Post author ID:', post.authorId);
    console.log('Current user ID:', user.id);
    console.log('Token exists:', !!token);
    console.log('Token preview:', token ? token.substring(0, 20) + '...' : 'No token');

    setPublishing(true);
    try {
      const updatedPost = await postService.publishPost(id);
      setPost(updatedPost);
      // Show success feedback
      alert('Post published successfully! It will now appear on the home page.');
    } catch (error) {
      console.error('Error publishing post:', error);
      console.error('Error details:', error.response);
      
      if (error.response?.status === 403) {
        alert('Authentication failed. Please log out and log in again.');
      } else if (error.response?.status === 404) {
        alert('Post not found. Please refresh the page.');
      } else {
        alert(`Failed to publish post: ${error.response?.status || 'Network error'}. Please try again.`);
      }
    } finally {
      setPublishing(false);
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (!post) {
    return (
      <div className="text-center py-12">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Post not found</h2>
        <button onClick={() => navigate('/')} className="btn-primary">
          Go Home
        </button>
      </div>
    );
  }

  const isLiked = user && post.likedBy && post.likedBy.includes(user.id);

  return (
    <div className="max-w-4xl mx-auto">
      <article className="card">
        {post.coverImage && (
          <img
            src={post.coverImage}
            alt={post.title}
            className="w-full h-64 object-cover rounded-lg mb-6"
          />
        )}

        <header className="mb-6">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">{post.title}</h1>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-4 text-gray-600">
              <span>{post.authorName}</span>
              <span>•</span>
              <span>{formatDate(post.createdAt)}</span>
              {post.publishedAt && (
                <>
                  <span>•</span>
                  <span>Published {formatDate(post.publishedAt)}</span>
                </>
              )}
              {!post.published && (
                <>
                  <span>•</span>
                  <span className="text-orange-600 bg-orange-100 px-2 py-1 rounded-full text-sm">
                    Draft
                  </span>
                </>
              )}
            </div>
            {user && user.id === post.authorId && !post.published && (
              <button
                onClick={handlePublish}
                disabled={publishing}
                className="btn-primary"
              >
                {publishing ? 'Publishing...' : 'Publish Now'}
              </button>
            )}
          </div>
          {post.tags && post.tags.length > 0 && (
            <div className="flex space-x-2">
              {post.tags.map((tag) => (
                <span
                  key={tag}
                  className="px-3 py-1 bg-gray-100 text-gray-700 text-sm rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
        </header>

        {post.excerpt && (
          <div className="mb-6 p-4 bg-gray-50 rounded-lg">
            <p className="text-lg text-gray-700 italic">{post.excerpt}</p>
          </div>
        )}

        <div 
          className="prose prose-lg max-w-none mb-8"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />

        <div className="border-t border-gray-200 pt-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-6">
              <button
                onClick={handleLike}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
                  isLiked 
                    ? 'bg-primary-100 text-primary-700' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                <svg className="w-5 h-5" fill={isLiked ? 'currentColor' : 'none'} stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
                <span>{post.likeCount} likes</span>
              </button>
              <div className="flex items-center space-x-2 text-gray-600">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
                <span>{post.readCount} reads</span>
              </div>
            </div>
          </div>

          <div className="border-t border-gray-200 pt-6">
            <h3 className="text-xl font-semibold text-gray-900 mb-4">
              Comments ({post.commentCount})
            </h3>

            {user && (
              <form onSubmit={handleComment} className="mb-6">
                <textarea
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  placeholder="Add a comment..."
                  className="input-field mb-3"
                  rows="3"
                />
                <button
                  type="submit"
                  disabled={submitting || !comment.trim()}
                  className="btn-primary"
                >
                  {submitting ? 'Posting...' : 'Post Comment'}
                </button>
              </form>
            )}

            <div className="space-y-4">
              {post.comments && post.comments.map((comment) => (
                <div key={comment.id} className="border-b border-gray-100 pb-4">
                  <div className="flex items-start space-x-3">
                    <div className="w-8 h-8 bg-primary-600 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm font-medium">
                        {comment.authorName[0]}
                      </span>
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <span className="font-medium text-gray-900">{comment.authorName}</span>
                        <span className="text-sm text-gray-500">{formatDate(comment.createdAt)}</span>
                      </div>
                      <p className="text-gray-700">{comment.content}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </article>
    </div>
  );
};

export default PostDetail; 