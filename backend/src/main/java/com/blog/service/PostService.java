package com.blog.service;

import com.blog.model.Post;
import com.blog.model.Comment;
import com.blog.model.User;
import com.blog.repository.PostRepository;
import com.blog.repository.UserRepository;
import com.blog.dto.PostRequest;
import com.blog.dto.CommentRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PostService {
    
    @Autowired
    private PostRepository postRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    public Page<Post> getAllPublishedPosts(Pageable pageable) {
        return postRepository.findByPublishedTrueOrderByCreatedAtDesc(pageable);
    }
    
    public Page<Post> getPostsByAuthor(String authorId, Pageable pageable) {
        return postRepository.findByAuthorIdOrderByCreatedAtDesc(authorId, pageable);
    }
    
    public Page<Post> searchPosts(String searchTerm, Pageable pageable) {
        return postRepository.findBySearchTerm(searchTerm, pageable);
    }
    
    public Page<Post> getPostsByTags(List<String> tags, Pageable pageable) {
        return postRepository.findByTagsIn(tags, pageable);
    }
    
    public Optional<Post> getPostById(String id) {
        return postRepository.findById(id);
    }
    
    public Post createPost(PostRequest postRequest, String authorId) {
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Post post = new Post(
                postRequest.getTitle(),
                postRequest.getContent(),
                authorId,
                author.getUsername()
        );
        
        post.setExcerpt(postRequest.getExcerpt());
        post.setCoverImage(postRequest.getCoverImage());
        post.setTags(postRequest.getTags());
        post.setPublished(postRequest.isPublished());
        
        if (postRequest.isPublished()) {
            post.setPublishedAt(LocalDateTime.now());
        }
        
        return postRepository.save(post);
    }
    
    public Post updatePost(String id, PostRequest postRequest, String authorId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getAuthorId().equals(authorId)) {
            throw new RuntimeException("Not authorized to update this post");
        }
        
        post.setTitle(postRequest.getTitle());
        post.setContent(postRequest.getContent());
        post.setExcerpt(postRequest.getExcerpt());
        post.setCoverImage(postRequest.getCoverImage());
        post.setTags(postRequest.getTags());
        post.setUpdatedAt(LocalDateTime.now());
        
        if (postRequest.isPublished() && !post.isPublished()) {
            post.setPublished(true);
            post.setPublishedAt(LocalDateTime.now());
        }
        
        return postRepository.save(post);
    }
    
    public void deletePost(String id, String authorId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getAuthorId().equals(authorId)) {
            throw new RuntimeException("Not authorized to delete this post");
        }
        
        postRepository.delete(post);
    }
    
    public Post likePost(String postId, String userId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (post.getLikedBy().contains(userId)) {
            post.getLikedBy().remove(userId);
            post.setLikeCount(post.getLikeCount() - 1);
        } else {
            post.getLikedBy().add(userId);
            post.setLikeCount(post.getLikeCount() + 1);
        }
        
        return postRepository.save(post);
    }
    
    public Post addComment(String postId, CommentRequest commentRequest, String authorId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        User author = userRepository.findById(authorId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Comment comment = new Comment(
                commentRequest.getContent(),
                authorId,
                author.getUsername()
        );
        
        comment.setAuthorAvatar(author.getAvatar());
        
        if (post.getComments() == null) {
            post.setComments(List.of(comment));
        } else {
            post.getComments().add(comment);
        }
        
        post.setCommentCount(post.getCommentCount() + 1);
        post.setUpdatedAt(LocalDateTime.now());
        
        return postRepository.save(post);
    }
    
    public List<Post> getPostsByTag(String tag) {
        return postRepository.findByTagsContaining(tag);
    }
    
    public void incrementReadCount(String postId) {
        Post post = postRepository.findById(postId).orElse(null);
        if (post != null) {
            post.setReadCount(post.getReadCount() + 1);
            postRepository.save(post);
        }
    }
    
    public Post publishPost(String id, String authorId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getAuthorId().equals(authorId)) {
            throw new RuntimeException("Not authorized to publish this post");
        }
        
        if (post.isPublished()) {
            throw new RuntimeException("Post is already published");
        }
        
        post.setPublished(true);
        post.setPublishedAt(LocalDateTime.now());
        post.setUpdatedAt(LocalDateTime.now());
        
        return postRepository.save(post);
    }
} 