package com.blog.controller;

import com.blog.dto.PostRequest;
import com.blog.dto.CommentRequest;
import com.blog.model.Post;
import com.blog.service.PostService;
import com.blog.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/posts")
@CrossOrigin(origins = "*")
public class PostController {
    
    @Autowired
    private PostService postService;
    
    @Autowired
    private UserService userService;
    
    @GetMapping
    public ResponseEntity<Page<Post>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> posts = postService.getAllPublishedPosts(pageable);
        return ResponseEntity.ok(posts);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Post> getPostById(@PathVariable String id) {
        return postService.getPostById(id)
                .map(post -> {
                    // Increment read count when post is viewed
                    postService.incrementReadCount(id);
                    return ResponseEntity.ok(post);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public ResponseEntity<Post> createPost(@Valid @RequestBody PostRequest postRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    Post post = postService.createPost(postRequest, user.getId());
                    return ResponseEntity.ok(post);
                })
                .orElse(ResponseEntity.badRequest().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePost(@PathVariable String id, @Valid @RequestBody PostRequest postRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    try {
                        Post post = postService.updatePost(id, postRequest, user.getId());
                        return ResponseEntity.ok(post);
                    } catch (RuntimeException e) {
                        return ResponseEntity.badRequest().build();
                    }
                })
                .orElse(ResponseEntity.badRequest().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePost(@PathVariable String id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    try {
                        postService.deletePost(id, user.getId());
                        return ResponseEntity.ok().build();
                    } catch (RuntimeException e) {
                        return ResponseEntity.badRequest().build();
                    }
                })
                .orElse(ResponseEntity.badRequest().build());
    }
    
    @PostMapping("/{id}/like")
    public ResponseEntity<Post> likePost(@PathVariable String id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    Post post = postService.likePost(id, user.getId());
                    return ResponseEntity.ok(post);
                })
                .orElse(ResponseEntity.badRequest().build());
    }
    
    @PostMapping("/{id}/comments")
    public ResponseEntity<Post> addComment(@PathVariable String id, @Valid @RequestBody CommentRequest commentRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    Post post = postService.addComment(id, commentRequest, user.getId());
                    return ResponseEntity.ok(post);
                })
                .orElse(ResponseEntity.badRequest().build());
    }
    
    @GetMapping("/search")
    public ResponseEntity<Page<Post>> searchPosts(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Post> posts = postService.searchPosts(q, pageable);
        return ResponseEntity.ok(posts);
    }
    
    @GetMapping("/tags/{tag}")
    public ResponseEntity<List<Post>> getPostsByTag(@PathVariable String tag) {
        List<Post> posts = postService.getPostsByTag(tag);
        return ResponseEntity.ok(posts);
    }
    
    @PostMapping("/{id}/publish")
    public ResponseEntity<?> publishPost(@PathVariable String id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        
        return userService.findByUsername(username)
                .map(user -> {
                    try {
                        Post post = postService.publishPost(id, user.getId());
                        return ResponseEntity.ok(post);
                    } catch (RuntimeException e) {
                        return ResponseEntity.badRequest().build();
                    }
                })
                .orElse(ResponseEntity.badRequest().build());
    }
} 