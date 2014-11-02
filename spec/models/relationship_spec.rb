require 'spec_helper'

describe Relationship do
  before do
    @follower = User.new(name: "Follower", email: "follower@example.com",
      password: "foobar", password_confirmation: "foobar")
    @follower.save

    @followed = User.new(name: "Followed", email: "followed@example.com",
      password: "foobar", password_confirmation: "foobar")
    @followed.save

    @relationship = @follower.relationships.build(followed_id: @followed.id)
  end

  subject { @relationship }
  it { should be_valid }

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should == @follower }
    its(:followed) { should == @followed }
  end

  describe "when followed id is not present" do
    before { @relationship.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { @relationship.follower_id = nil }
    it { should_not be_valid }
  end

end
