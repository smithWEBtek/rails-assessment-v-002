class ConcertsController < ApplicationController
   skip_before_action :verify_authenticity_token
  def index
    @user = current_user
    @concerts = Concert.all
    @concert = @user.concerts
    respond_to do |format|
      format.html {render 'concerts/index', :layout => false}
      format.json {render json: @concerts.to_json(include: [users: {only: [:username]}])}
    end
  end


  def show
    @concert = Concert.find(params[:id])
    @user = User.find_by(params[:username])
    

    respond_to do |format|
      format.html {render :show}
      format.json {render json: @concert.to_json(include: [users: {only: [:username]}])}
    end
  end

  def create
    @concert = Concert.new(concert_params)

    if @concert.save
      params[:id] = @concert.id
      redirect_to new_user_concert_path(@concert)
    else
      redirect_to user_concerts_path(@user)
    end
  end


  def buy_tickets
    @user = User.find_by(params[:user_id])
    ticket = Ticket.new(user_id: params[:user_id], concert_id: params[:concert_id])
    ticket.save
    flash[:notice] = ticket.purchaseticket(@user.id)
    flash[:success] = flash[:notice] if flash[:notice] == "Success"
    redirect_to user_path(@user)
  end

  def refund
    @user = User.find_by(params[:user_id])
    ticket = Ticket.find(params[:ticket_id])
    concert = ticket.concert
    ticket.user
      if concert.time.to_i > Time.now.to_i
        @user.money = @user.money + concert.cost
        @user.save(validate: false)
        ticket.delete
        flash[:success] = "Successfully Refunded."
      else
        flash[:notice] = "You cannot refund a ticket that has already expired!"
      end
      redirect_to user_path(@user)
  end

  def most_popular
      @concert = Concert.find(Ticket.top)
    end

  

  def concert_data
    concert = Concert.find(params[:id])
    render json: concert.to_json
  end
  private

  def concert_params
    params.require(:user).permit(:id, :title, :min_age, :cost, :time)
  end

end
