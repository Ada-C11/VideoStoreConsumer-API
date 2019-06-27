class Movie < ApplicationRecord
  has_many :rentals
  has_many :customers, through: :rentals

  def available_inventory
    self.inventory - Rental.where(movie: self, returned: false).length
  end

  def self.does_movie_exist(title)
    # raise
    existingMovie = Movie.find_by(title: title)
    puts "existingMovie: #{existingMovie}"

    if existingMovie
      existingMovie.inventory += 1
      puts "inventory: #{existingMovie.inventory}"
      return true
    end

    return false

  end

  def image_url
    orig_value = read_attribute :image_url
    if !orig_value
      MovieWrapper::DEFAULT_IMG_URL
    elsif external_id
      MovieWrapper.construct_image_url(orig_value)
    else
      orig_value
    end
  end
end
