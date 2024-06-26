class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    # Check if there are params for ratings or sorting
    if params[:ratings].present?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = @ratings_to_show
    elsif session[:ratings].present?
      @ratings_to_show = session[:ratings]
    else
      @ratings_to_show = @all_ratings
    end
    if params[:sort].present?
      @sort_column = params[:sort]
      session[:sort] = @sort_column
    elsif session[:sort].present?
      @sort_column = session[:sort]
    end
    @ratings_to_show_hash = @ratings_to_show.map { |rating| [rating, "1"] }.to_h
    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.order(@sort_column) if @sort_column.present?
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
