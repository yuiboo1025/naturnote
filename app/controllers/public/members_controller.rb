class Public::MembersController < ApplicationController
  # ログイン前はユーザー一覧だけ見れるようにする
  before_action :authenticate_member!, except: [:index]
  # ゲストユーザーにはユーザー情報編集できないようにするため
  before_action :ensure_guest_member, only: [:edit]

  def index
    # params[:q]には検索パラメータが渡され、resultにより検索結果を得られる。
    # rejectメソッド・・・各要素を評価し「偽」となる要素だけを抽出する。
    
    # params[:q]で、欲しいデータが送られてきているかチェック
    # 送られてきている、かつ、データが存在しているか確認している。
    # 左側のparams[:q]の記述がないと、そもそもデータが送られてきていない場合、エラーが出てきてしまう。
    @exist_members = Member.where(is_deleted: false)
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = @exist_members.ransack(search_params)
      @title = "検索結果"
    else
      @q = @exist_members.ransack
      @title = "全てのユーザー"
    end
    @members = @q.result.page(params[:page]).per(6)

  end

  def followings
    @member = Member.find(params[:id])
    @members = @member.followings.where(is_deleted: false)
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = @members.ransack(search_params)
      @title = "フォローしているユーザー(検索結果)"
    else
      @q = @members.ransack
      @title = "フォローしているユーザー"
    end
    @members = @q.result.page(params[:page]).per(6)
  end

  def followers
    @member = Member.find(params[:id])
    @members = @member.followers.where(is_deleted: false)
    if params[:q] && params[:q].reject { |key, value| value.blank? }.present?
      @q = @members.ransack(search_params)
      @title = "フォロワー(検索結果)"
    else
      @q = @members.ransack
      @title = "フォロワー"
    end
    @members = @q.result.page(params[:page]).per(6)
  end

  def show
    @member = current_member
  end

  def edit
    @member = current_member
  end

  def update
    @member = current_member
    if @member.update(member_params)
      flash[:notice] = "会員情報の更新が完了しました。"
      redirect_to member_path(@member)
    else
      flash[:error] = "情報が足りていないか、または情報が正しくありません。"
      render :edit
    end
  end

  # ブックマークした投稿一覧
  def bookmarks
    @member = Member.find(params[:id])
    # ユーザーidが、このユーザーの、ブックマークのレコードを全て取得。そのwine_idも一緒に持ってくる
    # bookmarksには、あるユーザーがブックマークした投稿のidが入っている
    # pluck=指定したカラムのレコードの配列を取得
    @bookmarks = Bookmark.where(member_id: @member.id).pluck(:wine_id)
    # データが配列で格納されている
    @bookmark_wines = Wine.find(@bookmarks)
    # 配列の降順メソッドを使用する
    @bookmark_wines = @bookmark_wines.reverse
    @genres = Genre.all
  end

  # フォローした人の投稿一覧
  def followings_wine
    @member = Member.find(params[:id])
    @members = @member.followings.where(is_deleted: false)
    @followings_wines = Wine.where(member_id: @members).order(id: "DESC")
    @genres = Genre.all
  end

  def unsubscribe
  end

  def withdraw
    @member = current_member
    # is_deletedカラムをtrueに変更することにより削除フラグを立てる。
    @member.update(is_deleted: true)
    reset_session
    flash[:notice] = "退会処理を実行いたしました"
    redirect_to root_path
  end

  private
    # ユーザーの編集画面へのURLを直接入力された場合にはメッセージを表示してユーザー詳細画面へリダイレクトさせる。
    # before_actionでeditアクション実行前に処理を行う。
    def ensure_guest_member
      @member = Member.find(params[:id])
      if @member.name == "guestuser"
        flash[:error] = "ゲストユーザーはプロフィール編集画面へ遷移できません。"
        redirect_to member_path(current_member)
      end
    end

    def set_current_member
      @member = current_member
    end

    def member_params
      params.require(:member).permit(:name, :email, :profile_image, :favorite_genre, :prefecture, :introduction)
    end

    def search_params
      params.require(:q).permit(:name_cont)
    end
end
