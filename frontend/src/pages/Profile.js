import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { postService } from '../services/postService';

const Profile = () => {
  const { user } = useAuth();
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);

  useEffect(() => {
    if (user) {
      loadUserPosts();
    }
  }, [user, page]);

  const loadUserPosts = async () => {
    try {
      const response = await postService.getUserPosts(user.id, page, 10);
      if (page === 0) {
        setPosts(response.content);
      } else {
        setPosts(prev => [...prev, ...response.content]);
      }
      setHasMore(!response.last);
      setLoading(false);
    } catch (error) {
      console.error('Error loading user posts:', error);
      setLoading(false);
    }
  };

  const loadMore = () => {
    setPage(prev => prev + 1);
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

  return (
    <div className="max-w-4xl mx-auto">
      <div className="card mb-8">
        <div className="flex items-center space-x-6">
          <div className="w-20 h-20 bg-primary-600 rounded-full flex items-center justify-center">
            <span className="text-white text-2xl font-bold">
              {user.firstName ? user.firstName[0] : user.username[0]}
            </span>
          </div>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {user.firstName && user.lastName 
                ? `${user.firstName} ${user.lastName}` 
                : user.username
              }
            </h1>
            <p className="text-gray-600">@{user.username}</p>
            <p className="text-gray-600">{user.email}</p>
            {user.bio && <p className="text-gray-700 mt-2">{user.bio}</p>}
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Your Stories</h2>
        <Link to="/create" className="btn-primary">
          Write New Story
        </Link>
      </div>

      <div className="space-y-6">
        {posts.map((post) => (
          <article key={post.id} className="card hover:shadow-md transition-shadow duration-200">
            <div className="flex items-start space-x-4">
              {post.coverImage && (
                <img
                  src={post.coverImage}
                  alt={post.title}
                  className="w-24 h-24 object-cover rounded-lg"
                />
              )}
              <div className="flex-1">
                <div className="flex items-center space-x-2 mb-2">
                  <span className="text-sm text-gray-500">{formatDate(post.createdAt)}</span>
                  {!post.published && (
                    <>
                      <span className="text-gray-300">•</span>
                      <span className="text-sm text-orange-600 bg-orange-100 px-2 py-1 rounded-full">
                        Draft
                      </span>
                    </>
                  )}
                </div>
                <Link to={`/post/${post.id}`}>
                  <h3 className="text-xl font-semibold text-gray-900 mb-2 hover:text-primary-600 transition-colors">
                    {post.title}
                  </h3>
                </Link>
                {post.excerpt && (
                  <p className="text-gray-600 mb-3 line-clamp-3">{post.excerpt}</p>
                )}
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <span>{post.readCount} reads</span>
                    <span>{post.likeCount} likes</span>
                    <span>{post.commentCount} comments</span>
                  </div>
                  <div className="flex space-x-2">
                    {post.tags && post.tags.map((tag) => (
                      <span
                        key={tag}
                        className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full"
                      >
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </article>
        ))}
      </div>

      {hasMore && (
        <div className="text-center mt-8">
          <button
            onClick={loadMore}
            className="btn-primary"
          >
            Load More Stories
          </button>
        </div>
      )}

      {!hasMore && posts.length > 0 && (
        <div className="text-center mt-8 text-gray-500">
          <p>You've reached the end of your stories.</p>
        </div>
      )}

      {posts.length === 0 && !loading && (
        <div className="text-center py-12">
          <h3 className="text-xl font-semibold text-gray-900 mb-2">No stories yet</h3>
          <p className="text-gray-600 mb-4">Start writing your first story!</p>
          <Link to="/create" className="btn-primary">
            Write Your First Story
          </Link>
        </div>
      )}
    </div>
  );
};

export default Profile; 