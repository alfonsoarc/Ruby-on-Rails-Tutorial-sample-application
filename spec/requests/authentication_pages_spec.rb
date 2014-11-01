require 'spec_helper'

describe "Authentication" do
  subject { page }
  describe "signin page" do
    before { visit signin_path }
    it { should have_selector('h1', text: 'Sign in') }
    it { should have_title(full_title('Sign in'))  }
  end

  describe "signin" do
    before { visit signin_path }
    describe "with invalid information" do
      before { click_button "Sign in" }
      it { should have_title(full_title('Sign in')) }
      # Test flash message. Looking for something like this:
      # <div class="alert alert-error">Invalid...</div>
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end

    end

    describe "with valid information" do
      before do
        @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
        @user.save

        sign_in @user
      end

      it { should have_title(full_title(@user.name)) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(@user.id)) }
      it { should have_link('Settings', href: edit_user_path(@user.id)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end

  end

  describe "authorization" do

    describe "for non-signed-in users" do
      before do
        @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
        @user.save
      end

      describe "in the Users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(@user) }
          it { should have_title(full_title('Sign in')) }
        end

        describe "visiting the users index" do
          before { visit users_path }
          it { should have_title(full_title('Sign in')) }
        end

        describe "submitting to the update action" do
          before { patch user_path(@user) }
          specify { response.should redirect_to(signin_path) }
        end

      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(@user)
          fill_in "Email", with: @user.email
          fill_in "Password", with: @user.password
          click_button "Sign in"
        end
        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_title(full_title('Edit user'))
          end
        end

      end

    end

    describe "as wrong user" do
      before do
        @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
        @user.save

        @wrong_user = User.new(name: "Wrong User", email: "wrong@example.com",
        password: "foobar", password_confirmation: "foobar")
        @wrong_user.save

        sign_in @user
      end

      describe "visiting Users#edit page" do
        before { visit edit_user_path(@wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end
      describe "submitting a PUT request to the Users#update action" do
        before { patch user_path(@wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      before do
        @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
        @user.save

        @non_admin = User.new(name: "Non admin", email: "non_admin@example.com",
        password: "foobar", password_confirmation: "foobar")
        @non_admin.save

        sign_in @non_admin
      end

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(@user) }
        specify { response.should redirect_to(root_path) }
      end
    end

  end
end
