require 'spec_helper'

describe Micropost do
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
    @user.save

    # This code is wrong! (Notice the difference with the one below)
    # @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  subject { @micropost }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == @user }

  it { should be_valid }

  describe "when user id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "micropost associations" do
    before do
      @micropost.created_at = 1.day.ago
      @micropost.save

      @micropostNewer = @user.microposts.build(content: "Lorem ipsum")
      @micropostNewer.created_at = 1.hour.ago
      @micropostNewer.save
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@micropostNewer, @micropost]
    end
  end

  it "should destroy associated microposts" do
    microposts = @user.microposts
    @user.destroy
    microposts.each do |micropost|
      Micropost.find_by_id(micropost.id).should be_nil
    end
  end

  describe "when user id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end
  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end
  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end

end
