class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date, :sort)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    # handle user session for filtes
    ratings = params[:ratings]
    if ratings != nil && !ratings.keys.empty?
      session[:filtered_ratings] = ratings.keys
      ratings = ratings.keys
    elsif session[:filtered_ratings] != nil
      ratings = session[:filtered_ratings]
    else
      session[:filtered_ratings] = Movie.all_ratings
      ratings = session[:filtered_ratings]
    end

    # check criterias
    sort = params[:sort] != nil ? params[:sort].to_sym : nil
    if sort == :title || sort == :release_date
      session[:sorted] = sort
    elsif session[:sorted] != nil
      session[:sorted] = session[:sorted].to_sym
      sort = session[:sorted]
    end

    # do search
    logger.debug 'Ratings => ' + ratings.to_s
    logger.debug 'Sort => ' + sort.to_s
    if sort != nil
      @movies = Movie.where(rating: ratings).order(sort)
    else
      @movies = Movie.where(rating: ratings)
    end
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

end
