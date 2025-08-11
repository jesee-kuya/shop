# ImageUploader handles file uploads for product images in the e-commerce system
#
# This uploader is built on CarrierWave and provides comprehensive image processing
# capabilities including automatic resizing, format validation, and organized storage.
# It's designed to handle product images with multiple versions for different use cases.
#
# Key Features:
# - Automatic image resizing using MiniMagick
# - Multiple image versions (thumbnail and default sizes)
# - Organized file storage structure
# - File type validation for security
# - Optimized for web display and performance
#
# Storage Structure:
# - Files stored in: uploads/product/image/{product_id}/
# - Original file plus generated versions (thumb, default)
# - Maintains file organization and prevents naming conflicts
#
# Image Versions:
# - thumb: 400x300 pixels (for product listings, cards)
# - default: 800x600 pixels (for product detail pages)
# - Both versions maintain aspect ratio using resize_to_fit
#
# Supported Formats:
# - JPG/JPEG: Best for photographs with many colors
# - PNG: Best for images with transparency or few colors
# - GIF: Supported for compatibility (though not recommended for photos)
class ImageUploader < CarrierWave::Uploader::Base
  # Use MiniMagick for image processing (requires ImageMagick to be installed)
  # MiniMagick is preferred over RMagick for better memory management
  # Provides resize, crop, and other image manipulation capabilities
  include CarrierWave::MiniMagick

  # Configure storage backend for uploaded files
  # :file stores files on the local filesystem (suitable for development)
  # For production, consider switching to :fog for cloud storage (AWS S3, etc.)
  storage :file
  # storage :fog  # Uncomment for cloud storage in production

  # Define the directory structure for storing uploaded files
  # Creates organized storage: uploads/product/image/{product_id}/filename.ext
  # This structure prevents naming conflicts and organizes files by model
  #
  # @return [String] Directory path for storing this upload
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default image URL when no image has been uploaded
  # Uncomment and customize this method to show placeholder images
  # Useful for maintaining consistent UI when products don't have images
  #
  # @param args [Array] Version arguments (e.g., :thumb, :default)
  # @return [String] URL to default/placeholder image
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Apply processing to all uploaded images
  # Uncomment to add global processing (e.g., watermarks, quality adjustments)
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # Custom processing logic would go here
  # end

  # Create thumbnail version for product listings and cards
  # Resizes images to fit within 400x300 pixels while maintaining aspect ratio
  # This version is optimized for fast loading in product grids and lists
  version :thumb do
    process resize_to_fit: [400, 300]
  end

  # Create default version for product detail pages
  # Resizes images to fit within 800x600 pixels while maintaining aspect ratio
  # This version provides good quality for detailed product viewing
  version :default do
    process resize_to_fit: [800, 600]
  end

  # Define allowed file extensions for security and compatibility
  # Restricts uploads to common image formats to prevent malicious files
  # These formats are widely supported by browsers and image processing libraries
  #
  # @return [Array<String>] List of allowed file extensions
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Customize the filename of uploaded files
  # Uncomment and modify to implement custom naming schemes
  # Note: Avoid using model.id or version_name in filename for CarrierWave compatibility
  #
  # @return [String] Custom filename for the uploaded file
  # def filename
  #   "something.jpg" if original_filename
  # end
end
