class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  def index
    @matches = Match.all
  end

  def show
  end

  def new
    @match = Match.new
  end

  def create
    @match = Match.new(match_params)
    
    if @match.save
      redirect_to @match, notice: 'Match was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: 'Match was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: 'Match was successfully deleted.'
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(:result)
  end
end
