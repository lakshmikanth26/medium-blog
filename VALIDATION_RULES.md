# Signup Form Validation Rules

This document outlines all the validation rules applied to the signup form on both frontend and backend.

## Frontend Validation (Client-Side)

### First Name & Last Name
- **Required**: Yes ✓
- **Pattern**: Only letters, spaces, hyphens (`-`) and apostrophes (`'`) allowed
- **Min Length**: 2 characters
- **Max Length**: 50 characters
- **Validation Trigger**: On blur (when user leaves the field) and on submit
- **Error Display**: Red border + error message below field

### Username
- **Required**: Yes ✓
- **Pattern**: Any characters allowed (alphanumeric, special chars, etc.)
- **Min Length**: 3 characters
- **Max Length**: 30 characters
- **Validation Trigger**: On blur and on submit
- **Error Display**: Red border + error message below field

### Email
- **Required**: Yes ✓
- **Pattern**: Must be valid email format (user@domain.com)
- **Regex**: `^[^\s@]+@[^\s@]+\.[^\s@]+$`
- **Validation Trigger**: On blur and on submit
- **Error Display**: Red border + error message below field

### Password
- **Required**: Yes ✓
- **Min Length**: 6 characters
- **Max Length**: 100 characters
- **Validation Trigger**: On blur and on submit
- **Error Display**: Red border + error message below field

## Backend Validation (Server-Side)

All validations are also enforced on the backend using Jakarta Bean Validation annotations in `SignupRequest.java`:

### First Name
```java
@NotBlank(message = "First name is required")
@Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
@Pattern(regexp = "^[a-zA-Z\\s'-]+$", message = "First name can only contain letters, spaces, hyphens and apostrophes")
```

### Last Name
```java
@NotBlank(message = "Last name is required")
@Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
@Pattern(regexp = "^[a-zA-Z\\s'-]+$", message = "Last name can only contain letters, spaces, hyphens and apostrophes")
```

### Username
```java
@NotBlank(message = "Username is required")
@Size(min = 3, max = 30, message = "Username must be between 3 and 30 characters")
```

### Email
```java
@NotBlank(message = "Email is required")
@Email(message = "Email should be valid")
```

### Password
```java
@NotBlank(message = "Password is required")
@Size(min = 6, max = 100, message = "Password must be between 6 and 100 characters")
```

## Features

### Real-Time Validation
- Errors appear when user leaves a field (on blur)
- Errors clear when user starts typing again
- All fields validated on form submission

### Visual Feedback
- Invalid fields show red border
- Error messages appear in red text below fields
- Required fields marked with red asterisk (*)
- Submit button shows loading state during signup

### User-Friendly Messages
- Clear, specific error messages for each validation rule
- Examples in placeholders (e.g., "Choose a username (3-30 characters)")
- General error message if submission fails

## Example Valid Inputs

```
First Name: John
Last Name: O'Brien-Smith
Username: john_doe123
Email: john.doe@example.com
Password: SecurePass123
```

## Example Invalid Inputs

```
First Name: John123 ❌ (contains numbers)
Last Name: Smith@ ❌ (contains special char @)
Username: jo ❌ (too short, min 3 chars)
Email: invalid-email ❌ (not valid email format)
Password: 12345 ❌ (too short, min 6 chars)
```

