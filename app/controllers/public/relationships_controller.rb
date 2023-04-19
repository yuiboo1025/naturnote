class Public::RelationshipsController < ApplicationController
  
  def create
    @member = Member.find(params[:member_id])
    current_member.follow(@member)
  end
  
  def destroy
    @member = Member.find(params[:member_id])
    current_member.unfollow(@member)
  end
  
  #フォロー一覧
  def followings
    member = Member.find(params[:member_id])
		@members = member.followings
		
  end
  
  #フォロワー一覧
  def followers
    member = Member.find(params[:member_id])
		@members = member.followers
  end
  
end
