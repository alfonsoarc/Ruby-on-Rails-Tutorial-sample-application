class Relationship < ActiveRecord::Base
  # Required to use class_name as there is not any Follower or Followed model
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
