// Auto-dismissing notifications

document.addEventListener("turbolinks:load", function() {
  
  // Handle server-rendered flash notifications
  function initializeFlashNotifications() {
    const notifications = document.querySelectorAll('.global-notification');
    
    notifications.forEach(function(notification) {
      if (!notification.dataset.initialized) {
        notification.dataset.initialized = 'true';
        
        // Add fade-out animation after 4 seconds
        setTimeout(function() {
          fadeOutNotification(notification);
        }, 4000);
      }
    });
  }
  
  // Smooth fade-out animation
  function fadeOutNotification(notification) {
    notification.style.transition = 'opacity 0.5s ease-out';
    notification.style.opacity = '0';
    
    setTimeout(function() {
      if (notification.parentNode) {
        notification.parentNode.removeChild(notification);
      }
    }, 500);
  }
  
  // Initialize flash notifications on page load
  initializeFlashNotifications();
  
  // Re-initialize when new content is loaded via Turbolinks
  document.addEventListener('turbolinks:render', function() {
    initializeFlashNotifications();
  });
});
