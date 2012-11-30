class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :inviter_id
      t.integer :friend_id
      t.integer :status

      t.timestamps
    end

    add_index :friendships, :inviter_id
    add_index :friendships, :friend_id
    add_index :friendships, [:inviter_id, :friend_id], unique: true
  end
end
