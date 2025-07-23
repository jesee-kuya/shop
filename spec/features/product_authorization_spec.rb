require 'rails_helper'

RSpec.feature "Product Authorization", type: :feature do
  let(:owner) { create(:user, name: "Product Owner", email: "owner@example.com") }
  let(:other_user) { create(:user, name: "Other User", email: "other@example.com") }
  let(:product) { create(:product, user: owner, title: "Test Product") }

  describe "Edit action authorization" do
    context "when user is the product owner" do
      it "allows access to edit page" do
        sign_in owner
        visit edit_product_path(product)
        
        expect(page).to have_content("Editing Product")
        expect(page).to have_field("Title", with: product.title)
      end
    end

    context "when user is not the product owner" do
      it "redirects with authorization error" do
        sign_in other_user
        visit edit_product_path(product)
        
        expect(current_path).to eq(products_path)
        expect(page).to have_content("You are not authorized to perform this action.")
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        visit edit_product_path(product)
        
        expect(current_path).to eq(new_user_session_path)
      end
    end
  end

  describe "Update action authorization" do
    context "when user is not the product owner" do
      it "prevents unauthorized updates" do
        sign_in other_user
        
        patch product_path(product), params: { 
          product: { title: "Hacked Title" } 
        }
        
        expect(response).to redirect_to(products_path)
        expect(product.reload.title).not_to eq("Hacked Title")
      end
    end
  end

  describe "Delete action authorization" do
    context "when user is the product owner" do
      it "allows product deletion" do
        sign_in owner
        
        expect {
          delete product_path(product)
        }.to change(Product, :count).by(-1)
      end
    end

    context "when user is not the product owner" do
      it "prevents unauthorized deletion" do
        sign_in other_user
        
        expect {
          delete product_path(product)
        }.not_to change(Product, :count)
        
        expect(response).to redirect_to(products_path)
      end
    end
  end

  describe "View layer authorization" do
    context "on index page" do
      it "shows edit/delete buttons only to product owner" do
        sign_in owner
        visit products_path
        
        within(".product", text: product.title) do
          expect(page).to have_link("Edit")
          expect(page).to have_link("Delete")
        end
      end

      it "hides edit/delete buttons from non-owners" do
        sign_in other_user
        visit products_path
        
        within(".product", text: product.title) do
          expect(page).not_to have_link("Edit")
          expect(page).not_to have_link("Delete")
        end
      end
    end

    context "on show page" do
      it "shows edit/delete buttons only to product owner" do
        sign_in owner
        visit product_path(product)
        
        expect(page).to have_link("Edit Product")
        expect(page).to have_link("Delete Product")
      end

      it "hides edit/delete buttons from non-owners" do
        sign_in other_user
        visit product_path(product)
        
        expect(page).not_to have_link("Edit Product")
        expect(page).not_to have_link("Delete Product")
      end
    end
  end
end