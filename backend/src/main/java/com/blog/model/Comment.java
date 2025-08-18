package com.blog.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.springframework.data.annotation.Id;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Comment {
    @Id
    private String id;
    private String content;
    private String authorId;
    private String authorName;
    private String authorAvatar;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public Comment(String content, String authorId, String authorName) {
        this.content = content;
        this.authorId = authorId;
        this.authorName = authorName;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
} 