import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { postService } from '../services/postService';

const Home = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);

  useEffect(() => {
    loadPosts();
  }, []);

  const loadPosts = async () => {
    try {
      const response = await postService.getAllPosts(page, 10);
      if (page === 0) {
        setPosts(response.content);
      } else {
        setPosts(prev => [...prev, ...response.content]);
      }
      setHasMore(!response.last);
      setLoading(false);
    } catch (error) {
      console.error('Error loading posts:', error);
      setLoading(false);
    }
  };

  const loadMore = () => {
    setPage(prev => prev + 1);
    loadPosts();
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
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Latest Stories</h1>
        <p className="text-gray-600">Discover amazing stories from writers around the world.</p>
      </div>

      <div className="space-y-8">
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
                  <span className="text-sm text-gray-500">{post.authorName}</span>
                  <span className="text-gray-300">•</span>
                  <span className="text-sm text-gray-500">{formatDate(post.createdAt)}</span>
                </div>
                <Link to={`/post/${post.id}`}>
                  <h2 className="text-xl font-semibold text-gray-900 mb-2 hover:text-primary-600 transition-colors">
                    {post.title}
                  </h2>
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
          <p>You've reached the end of the stories.</p>
        </div>
      )}

      {posts.length === 0 && !loading && (
        <div className="text-center py-12">
          <h3 className="text-xl font-semibold text-gray-900 mb-2">No stories yet</h3>
          <p className="text-gray-600">Be the first to share a story!</p>
        </div>
      )}
    </div>
  );
};

export default Home; 