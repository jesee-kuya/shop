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
    }
  });

  function showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification is-${type === 'success' ? 'success' : 'danger'} global-notification`;
    notification.innerHTML = `<p>${message}</p>`;
    
    document.body.insertBefore(notification, document.body.firstChild);
    
    setTimeout(() => {
      notification.style.display = 'none';
    }, 4000);
  }
});