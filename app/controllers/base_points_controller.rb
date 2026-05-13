class BasePointsController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user
  before_action :set_base_point, only: [:edit, :update, :destroy]

  def index
    @base_points = BasePoint.all
  end

  def new
    @base_point = BasePoint.new
  end

  def create
    @base_point = BasePoint.new(base_point_params)
    if @base_point.save
      redirect_to base_points_path, notice: "拠点情報を追加しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @base_point.update(base_point_params)
      redirect_to base_points_path, notice: "拠点情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @base_point.destroy
    redirect_to base_points_path, notice: "拠点情報を削除しました。"
  end

  private

  def set_base_point
    @base_point = BasePoint.find(params[:id])
  end

  def base_point_params
    params.require(:base_point).permit(:base_number, :name, :base_type)
  end
end
