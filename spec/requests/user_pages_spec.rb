require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name", with: "Example User"
        fill_in "Email", with: "user@example.com"
        fill_in "Password", with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }
        it { should have_title(full_title(user.name)) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        # test the signout link to verify that the user was successfully signed in after signing up.
        it { should have_link('Sign out', href: signout_path) }
      end
    end
  end

  describe "edit" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user.save

      sign_in @user
      visit edit_user_path(@user)
    end

    describe "page" do
      it { should have_selector('h1', text: "Update your profile") }
      it { should have_title(full_title("Edit user")) }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end

    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: @user.password
        fill_in "Confirm Password", with: @user.password
        click_button "Save changes"
      end

      it { should have_title(full_title(new_name)) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { @user.reload.name.should == new_name}
      specify { @user.reload.email.should == new_email}
    end

  end

  describe "index" do
    before do
      @user1 = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user1.save
      @user2 = User.new(name: "Example User2", email: "user2@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user2.save

      sign_in @user1
      visit users_path
    end

    it { should have_selector('h1', text: "All users") }
    it { should have_title(full_title("All users")) }

    it { should have_selector('li', text: @user1.name) }
    it { should have_selector('li', text: @user2.name) }

    # Pagination not tested. We trust rails :)

    describe "delete links" do
      it { should_not have_link('delete') }

      describe "as an admin user" do
        before do
          @admin = User.new(name: "Example User", email: "admin@example.com",
          password: "foobar", password_confirmation: "foobar")
          @admin.toggle!(:admin)
          @admin.save

          sign_in @admin
          visit users_path
        end
        it { should have_link('delete', href: user_path(@user1)) }
        it "should be able to delete another user" do
          expect { click_link('delete', href: user_path(@user1)) }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(@admin)) }
      end
    end

  end

  describe "profile page" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user.save
      @micropost1 = @user.microposts.build(content: "Foo")
      @micropost2 = @user.microposts.build(content: "Bar")
      @micropost1.save # microposts.count check the database
      @micropost2.save

      visit user_path(@user)
    end

    it { should have_title(full_title(@user.name)) }
    it { should have_selector('h1', text: @user.name) }

    describe "microposts" do
      it { should have_content(@micropost1.content) }
      it { should have_content(@micropost2.content) }
      it { should have_content(@user.microposts.count) }
    end

    describe "follow/unfollow buttons" do
      before do
        @other_user = User.new(name: "Other User", email: "other_user@example.com",
        password: "foobar", password_confirmation: "foobar")
        @other_user.save
        sign_in @user
      end
      describe "following a user" do
        before { visit user_path(@other_user) }
        it "should increment the followed user count" do
          expect do
            click_button "Follow"
          end.to change(@user.followed_users, :count).by(1)
        end
        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(@other_user.followers, :count).by(1)
        end
        describe "toggling the button" do
          before { click_button "Follow" }
          #it { should have_selector('input', value: 'Unfollow') }
        end
      end
      describe "unfollowing a user" do
        before do
          @user.follow!(@other_user)
          visit user_path(@other_user)
        end
        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"
          end.to change(@user.followed_users, :count).by(-1)
        end
        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"
          end.to change(@other_user.followers, :count).by(-1)
        end
        describe "toggling the button" do
          before { click_button "Unfollow" }
          #it { should have_selector('input', value: 'Follow') }
        end
      end
    end

  end

  describe "following/followers" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user.save
      @other_user = User.new(name: "Example User2", email: "user2@example.com",
        password: "foobar", password_confirmation: "foobar")
      @other_user.save
      @user.follow!(@other_user)
    end

    describe "followed users" do
      before do
        sign_in @user
        visit following_user_path(@user)
      end
      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(@other_user.name, href: user_path(@other_user)) }
    end

    describe "followers" do
      before do
        sign_in @other_user
        visit followers_user_path(@other_user)
      end
      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(@user.name, href: user_path(@user)) }
    end
  end

end