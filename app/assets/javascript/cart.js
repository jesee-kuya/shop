document.addEventListener("turbolinks:load", function() {
  // Update cart count in navbar after AJAX cart operations
  function updateCartCount(count) {
    const cartLinks = document.querySelectorAll('a[href="/cart"]');
    cartLinks.forEach(link => {
      const cartText = link.textContent;
      const newText = cartText.replace(/\(\d+\)/, `(${count})`);
      link.textContent = newText;
    });
  }

  // Enhanced notification function with auto-dismiss
  function showNotification(message, type) {
    // Remove any existing notifications first
    const existingNotifications = document.querySelectorAll('.dynamic-notification');
    existingNotifications.forEach(notification => {
      notification.parentNode.removeChild(notification);
    });
    
    const notification = document.createElement('div');
    notification.className = `notification is-${type === 'success' ? 'success' : 'danger'} global-notification dynamic-notification`;
    notification.innerHTML = `<p>${message}</p>`;
    notification.style.opacity = '0';
    notification.style.transition = 'opacity 0.3s ease-in';
    
    document.body.insertBefore(notification, document.body.firstChild);
    
    // Fade in
    setTimeout(() => {
      notification.style.opacity = '1';
    }, 10);
    
    // Auto-dismiss after 4 seconds with fade out
    setTimeout(() => {
      fadeOutNotification(notification);
    }, 4000);
  }
  
  // Smooth fade-out function
  function fadeOutNotification(notification) {
    notification.style.transition = 'opacity 0.5s ease-out';
    notification.style.opacity = '0';
    
    setTimeout(() => {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 500);
  }

  // Handle AJAX responses for cart operations
  document.addEventListener('ajax:success', function(event) {
    const response = event.detail[0];
    if (response && response.cart_count !== undefined) {
      updateCartCount(response.cart_count);
      
      // Show success message if provided
      if (response.message) {
        showNotification(response.message, 'success');
      }
    }
  });

  document.addEventListener('ajax:error', function(event) {
    const response = event.detail[0];
    if (response && response.message) {
      showNotification(response.message, 'error');
    } else {
      showNotification('An error occurred. Please try again.', 'error');
    }
  });
});
