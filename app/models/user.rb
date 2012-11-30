class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation
  has_secure_password
  has_many :friendships, foreign_key: "inviter_id", dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :reverse_friendships, foreign_key: "friend_id", class_name: "Friendship", dependent: :destroy
  has_many :friends, through: :reverse_friendships, source: :inviter

  before_save { |user| user.name = name.downcase }
  before_save :create_remember_token

  validates :name, presence: true, length: {maximum: 40}, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: 6, maximum: 10}
  validates :password_confirmation, presence: true

  #contants
  PENDING = 0
  ACTIVE = 1
  BLOCK = 2

  def is_friend?(other_user)
    relationship = friendship(other_user)
    !relationship.nil? && relationship.status == ACTIVE
  end

  def send_request!(other_user)
    friendships.create!(friend_id: other_user.id, status: PENDING)
  end

  def send_request?(other_user)
    relationship = friendships.find_by_friend_id(other_user.id)
    !relationship.nil? && relationship.status == PENDING
  end

  def block?(other_user)
    friendships.find_by_friend_id_and_status(other_user.id, BLOCK)
  end

  def is_blocked_by?(other_user)
    reverse_friendships.find_by_inviter_id_and_status(other_user.id, BLOCK)
  end

  def block!(other_user)
    relationship = friendship(other_user)
    if relationship.inviter == other_user
      relationship.update_attributes!(inviter_id: relationship.friend_id, friend_id: other_user.id)
    end
    relationship.update_attributes!(status: BLOCK)
  end

  def unblock!(other_user)
    friendships.find_by_friend_id(other_user.id).destroy
  end

  def unconfirmed_request?(other_user)
    relationship = reverse_friendships.find_by_inviter_id(other_user.id)
    !relationship.nil? && relationship.status == PENDING
  end

  def confirm_request!(other_user)
    relationship = reverse_friendships.find_by_inviter_id(other_user.id)
    relationship.update_attributes!(status: ACTIVE)
  end

  def friendship(other_user)
    friendships.find_by_friend_id(other_user.id) || reverse_friendships.find_by_inviter_id(other_user.id)
  end

  private
  def create_remember_token
    self.remember_token = SecureRandom.urlsafe_base64
  end
end
