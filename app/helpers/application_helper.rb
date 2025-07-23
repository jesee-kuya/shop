module ApplicationHelper
  def product_image_tag(product, version = :thumb, options = {})
    if product.image.present?
      image_tag(product.image_url(version), options)
    else
      # Fallback image or placeholder
      image_tag("placeholder.png", options.merge(alt: "No image available"))
    end
  end
end
