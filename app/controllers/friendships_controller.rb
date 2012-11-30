class FriendshipsController < ApplicationController
  before_filter :signed_in_user

  def create
    @user = User.find(params[:friendship][:friend_id])
    current_user.send_request!(@user)
    redirect_to @user
  end

  def destroy
    @user = Friendship.find(params[:id]).inviter
    if current_user?(@user)
      @user = Friendship.find(params[:id]).friend
    end
    Friendship.find(params[:id]).destroy
    redirect_to @user
  end

  def confirm
    @user = User.find(params[:friendship][:inviter_id])#Friendship.find(params[:id]).inviter
    current_user.confirm_request!(@user)
    redirect_to @user
  end

  def block
    @user = Friendship.find(params[:id]).inviter
    if current_user?(@user)
      @user = Friendship.find(params[:id]).friend
    end
    current_user.block!(@user)
    redirect_to @user
  end

  def unblock
    @user = User.find(params[:friendship][:friend_id])
    current_user.unblock!(@user)
    redirect_to @user
  end
end
