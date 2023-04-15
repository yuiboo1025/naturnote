class Public::SpotsController < ApplicationController
  before_action :authenticate_member!, except: [:index, :show]

  def new
    @spot = Spot.new
  end

  def create
    spot = Spot.where(lat: params[:spot][:lat]).where(lng: params[:spot][:lng]).first
    if spot.blank?
      spot = Spot.new(spot_params)
      spot.save
    end
    redirect_to new_wine_path(spot_id: spot.id)

     #if spot.save
       # redirect_to new_wine_path(@spot.id)
     #else
       # redirect_to :action => "index"
     #end
  end

  def index
    @spots = Spot.all
  end

  def show
    @spot = Spot.find(params[:id])
    @wines = @spot.wines.all
    @genres = Genre.all
    if params[:genre_id]
		  @genre = Genre.find(params[:genre_id])
		  @wines = @genre.wines
    else
      @wines = @spot.wines.all
    end
  end

  def edit
    @spot = Spot.find(params[:id])
    @wine_id = params[:wine_id]
  end

  def update
    #編集からワインを取ってくる
    @wine = Wine.find(params[:spot][:wine_id])
    #編集画面で入力した緯度経度からspotを検索
    spot = Spot.where(lat: params[:spot][:lat]).where(lng: params[:spot][:lng]).first
    #spotが存在すれば
    unless spot.blank?
      #同じとこをろ探す
      spot = Spot.where(lat: params[:spot][:lat]).where(lng: params[:spot][:lng]).first
      #wineを更新をする(カラム名：↑で検索されたspotのid)
      @wine.update(spot_id: spot.id)
    #spotが存在しなければ
    else
      #新しいspotを作成
      spot = Spot.new(spot_params)
      spot.save
       #wineを更新をする(カラム名：↑で作成されたspotのid)
      @wine.update(spot_id: spot.id)
    end
    redirect_to edit_wine_path(params[:spot][:wine_id])

    #spot = Spot.where(lat: params[:spot][:lat]).where(lng: params[:spot][:lng]).first
    #if spot.blank?
     # spot = Spot.new(spot_params)
      #spot.save
   # else
     # spot.update(spot_params)
   # end
    #redirect_to edit_wine_path(params[:spot][:wine_id])


    #if @wine.update(wine_params)
     # redirect_to wine_path(@wine.id)
   # else
     # @message = "※情報が足りません"
     # render :edit
   # end

  end

  private

  def spot_params
    params.require(:spot).permit(:spot_name, :address, :telephone_number, :lat, :lng)
  end

end
