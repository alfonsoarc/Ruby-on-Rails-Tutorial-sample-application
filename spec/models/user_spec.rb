require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
    password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }
  it { should_not be_admin }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
      foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when email address is already taken upCase" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                     password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "with admin attribute set to 'true'" do
    before { @user.toggle!(:admin) }
    it { should be_admin }
  end

  describe "micropost associations" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user.save

      @unfollowed_user = User.new(name: "Unfollowed User", email: "unfolloweduser@example.com",
        password: "foobar", password_confirmation: "foobar")
      @unfollowed_user.save
      
      @followed_user = User.new(name: "followed User", email: "followeduser@example.com",
        password: "foobar", password_confirmation: "foobar")
      @followed_user.save

      @micropost1 = @user.microposts.build(content: "Foo")
      @micropost2 = @user.microposts.build(content: "Bar")
      @unfollowedMicropost = @unfollowed_user.microposts.build(content: "Bar")
      @followedMicropost1 = @followed_user.microposts.build(content: "1")
      @followedMicropost2 = @followed_user.microposts.build(content: "2")
      @micropost1.save
      @micropost2.save
      @unfollowedMicropost.save
      @followedMicropost1.save
      @followedMicropost2.save
      
      @user.follow!(@followed_user)
    end

    #Note here the method include to check for the present of an element in an array
    its(:feed) { should include(@micropost1) }
    its(:feed) { should include(@micropost2) }
    its(:feed) { should_not include(@unfollowedMicropost) }
    its(:feed) { should include(@followedMicropost1) }
    its(:feed) { should include(@followedMicropost2) }

  end

  describe "following" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
        password: "foobar", password_confirmation: "foobar")
      @user.save
      @other_user = User.new(name: "Other User", email: "otheruser@example.com",
        password: "foobar", password_confirmation: "foobar")
      @other_user.save
      @user.follow!(@other_user)
    end
    it { should be_following(@other_user) }
    its(:followed_users) { should include(@other_user) }

    describe "followed user" do
      subject { @other_user }
      its(:followers) { should include(@user) }
    end
    
    describe "and unfollowing" do
      before { @user.unfollow!(@other_user) }
      it { should_not be_following(@other_user) }
      its(:followed_users) { should_not include(@other_user) }
    end
  end

end
