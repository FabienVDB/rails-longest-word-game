require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
    session[:score] = session[:score].round || 0
    session[:start_time] = Time.now
  end

  def score
    @word = params[:word]
    @letters = params[:letters]
    @authenticity_token = params[:authenticity_token]
    @well_done = valid_english_name?(@word) && word_in_grid?(@word, @letters)
    @not_an_english_word = (!valid_english_name?(@word) && word_in_grid?(@word, @letters))
    session[:end_time] = Time.now
    session[:score] += compute_score.round
  end

  def generate_grid(grid_size)
    (0...grid_size).map { |_| [*('A'..'Z')].sample }
  end

  def word_in_grid?(word, grid)
    grid_tmp = grid.clone
    word.upcase.chars.all? do |ch|
      grid_tmp.include? ch
      grid_tmp.slice!(grid_tmp.index(ch)) if grid_tmp.include? ch
    end
  end

  def valid_english_name?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    user_serialized = URI.open(url).read
    user = JSON.parse(user_serialized)
    user['found']
  end

  def compute_score
    @well_done ? (100_000_000_000 * @word.length.fdiv(session[:end_time].to_f - session[:start_time].to_f)).round : 0
  end
end
