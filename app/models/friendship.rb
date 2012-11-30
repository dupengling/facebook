class Friendship < ActiveRecord::Base
  attr_accessible :inviter_id, :friend_id, :status

  belongs_to :inviter, class_name: "User"
  belongs_to :friend, class_name: "User"

  validates :inviter_id, presence: true
  validates :friend_id, presence: true
  validates :status, presence: true
end
