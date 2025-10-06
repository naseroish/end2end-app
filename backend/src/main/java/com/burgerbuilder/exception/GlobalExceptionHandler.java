package com.burgerbuilder.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.ArrayList;
import java.util.List;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
            ResourceNotFoundException ex, HttpServletRequest request) {
        
        log.error("Resource not found: {}", ex.getMessage());
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                "Resource Not Found",
                ex.getMessage(),
                request.getRequestURI()
        );
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
    }
    
    @ExceptionHandler(CartException.class)
    public ResponseEntity<ErrorResponse> handleCartException(
            CartException ex, HttpServletRequest request) {
        
        log.error("Cart exception: {}", ex.getMessage());
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Cart Error",
                ex.getMessage(),
                request.getRequestURI()
        );
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
    
    @ExceptionHandler(OrderException.class)
    public ResponseEntity<ErrorResponse> handleOrderException(
            OrderException ex, HttpServletRequest request) {
        
        log.error("Order exception: {}", ex.getMessage());
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Order Error",
                ex.getMessage(),
                request.getRequestURI()
        );
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        
        log.error("Validation exception: {}", ex.getMessage());
        
        List<ErrorResponse.ValidationError> validationErrors = new ArrayList<>();
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            validationErrors.add(new ErrorResponse.ValidationError(
                    fieldError.getField(),
                    fieldError.getRejectedValue(),
                    fieldError.getDefaultMessage()
            ));
        }
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Validation Failed",
                "Invalid input data",
                request.getRequestURI()
        );
        errorResponse.setValidationErrors(validationErrors);
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
    
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolationException(
            ConstraintViolationException ex, HttpServletRequest request) {
        
        log.error("Constraint violation: {}", ex.getMessage());
        
        List<ErrorResponse.ValidationError> validationErrors = new ArrayList<>();
        ex.getConstraintViolations().forEach(violation -> {
            String fieldName = violation.getPropertyPath().toString();
            validationErrors.add(new ErrorResponse.ValidationError(
                    fieldName,
                    violation.getInvalidValue(),
                    violation.getMessage()
            ));
        });
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Validation Failed",
                "Invalid input data",
                request.getRequestURI()
        );
        errorResponse.setValidationErrors(validationErrors);
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
    }
    
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Void> handleNoResourceFound(
            NoResourceFoundException ex, HttpServletRequest request) {
        
        String requestURI = request.getRequestURI();
        
        // Don't log common static resource requests as errors
        if (isStaticResourceRequest(requestURI)) {
            log.debug("Static resource not found: {}", requestURI);
        } else {
            log.warn("Resource not found: {}", requestURI);
        }
        
        return ResponseEntity.notFound().build();
    }
    
    private boolean isStaticResourceRequest(String requestURI) {
        return requestURI.endsWith("favicon.ico") ||
               requestURI.endsWith(".css") ||
               requestURI.endsWith(".js") ||
               requestURI.endsWith(".png") ||
               requestURI.endsWith(".jpg") ||
               requestURI.endsWith(".jpeg") ||
               requestURI.endsWith(".gif") ||
               requestURI.endsWith(".svg") ||
               requestURI.endsWith(".ico") ||
               requestURI.equals("/") ||
               requestURI.equals("/api");
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, HttpServletRequest request) {
        
        String requestURI = request.getRequestURI();
        
        // Don't log static resource exceptions as errors
        if (isStaticResourceRequest(requestURI)) {
            log.debug("Exception for static resource: {} - {}", requestURI, ex.getMessage());
        } else {
            log.error("Unexpected error: ", ex);
        }
        
        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Internal Server Error",
                "An unexpected error occurred",
                requestURI
        );
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
}
