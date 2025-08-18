package com.blog.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import com.blog.security.SpringContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private final JwtTokenProvider tokenProvider;
    private final UserDetailsService userDetailsService;
    
    public JwtAuthenticationFilter(JwtTokenProvider tokenProvider, UserDetailsService userDetailsService) {
        this.tokenProvider = tokenProvider;
        this.userDetailsService = userDetailsService;
    }
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwt = getJwtFromRequest(request);
            System.out.println("JWT Authentication Filter - Request: " + request.getMethod() + " " + request.getRequestURI());
            System.out.println("JWT Token present: " + StringUtils.hasText(jwt));
            
            if (StringUtils.hasText(jwt)) {
                boolean isValid = tokenProvider.validateToken(jwt);
                System.out.println("JWT Token valid: " + isValid);
                
                if (isValid) {
                    String username = tokenProvider.getUsernameFromJWT(jwt);
                    System.out.println("JWT Username: " + username);
                    
                    // Get UserDetailsService from ApplicationContext if not injected
                    UserDetailsService userDetailsService = this.userDetailsService;
                    if (userDetailsService == null) {
                        userDetailsService = SpringContextHolder.getApplicationContext().getBean(UserDetailsService.class);
                    }
                    
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    System.out.println("User loaded: " + userDetails.getUsername());
                    
                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                    System.out.println("Authentication set for user: " + username);
                } else {
                    System.out.println("Invalid JWT token for request: " + request.getMethod() + " " + request.getRequestURI());
                }
            } else {
                System.out.println("No JWT token found for request: " + request.getMethod() + " " + request.getRequestURI());
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication in security context", ex);
        }
        
        filterChain.doFilter(request, response);
    }
    
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
} 