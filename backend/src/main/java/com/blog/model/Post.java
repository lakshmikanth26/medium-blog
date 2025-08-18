package com.blog.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.TextIndexed;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "posts")
public class Post {
    @Id
    private String id;
    
    @TextIndexed
    private String title;
    
    @TextIndexed
    private String content;
    
    private String authorId;
    private String authorName;
    private String excerpt;
    private String coverImage;
    private Set<String> tags = new HashSet<>();
    private List<Comment> comments;
    private Set<String> likedBy = new HashSet<>();
    private int likeCount = 0;
    private int commentCount = 0;
    private int readCount = 0;
    private boolean published = false;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime publishedAt;
    
    public Post(String title, String content, String authorId, String authorName) {
        this.title = title;
        this.content = content;
        this.authorId = authorId;
        this.authorName = authorName;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
} 