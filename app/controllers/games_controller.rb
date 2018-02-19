require 'open-uri'
require 'json'

class GamesController < ApplicationController
  @letters = ''
  @start_time = 0
  @end_time = 0
  @result = {}
  @attempt = ''

  def new
    def generate_grid(grid_size)
      grid = []
      (0...grid_size).each do
        grid << ("A".."Z").to_a.sample
      end
      grid
    end
    @letters = generate_grid(10)
  end

  def score
    @attempt = params[:word]
    url = "https://wagon-dictionary.herokuapp.com/#{@attempt}"
    serialized_dictionary = open(url).read
    dictionary = JSON.parse(serialized_dictionary)
    @start_time = params[:start].to_i
    @end_time = Time.now.to_i
    grid = params[:letters]

    result = {
    time: @end_time - @start_time,
    score: 0,
    message: "",
    letters: grid
    }

    if dictionary["found"] == true
      @attempt.upcase!
    else
      result[:message] = "not an english word"
      @result = result
    end

    @attempt.each_char do |letter|
      if grid.include?(letter)
        grid.delete(letter)
        result[:score] = @attempt.length * 200 - result[:time]
      else
        result[:score] = 0
        result[:message] = "the given word is not in the grid"
        @result = result
      end
    end

    if result[:score] > 120
      result[:message] = "Well done"
    elsif result [:score] < 120 && result[:score] > 1
      result [:message] = "Pretty good"
    end
    @result = result
  end
end
