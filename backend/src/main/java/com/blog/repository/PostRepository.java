package com.blog.repository;

import com.blog.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends MongoRepository<Post, String> {
    Page<Post> findByPublishedTrueOrderByCreatedAtDesc(Pageable pageable);
    Page<Post> findByAuthorIdOrderByCreatedAtDesc(String authorId, Pageable pageable);
    Page<Post> findByAuthorIdAndPublishedTrueOrderByCreatedAtDesc(String authorId, Pageable pageable);
    
    @Query("{'$and': [{'published': true}, {'$or': [{'title': {'$regex': ?0, '$options': 'i'}}, {'content': {'$regex': ?0, '$options': 'i'}}, {'tags': {'$in': [?0]}}]}]}")
    Page<Post> findBySearchTerm(String searchTerm, Pageable pageable);
    
    @Query("{'$and': [{'published': true}, {'tags': {'$in': ?0}}]}")
    Page<Post> findByTagsIn(List<String> tags, Pageable pageable);
    
    List<Post> findByTagsContaining(String tag);
} 