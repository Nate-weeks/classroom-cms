class StudentworksController < ApplicationController
  def new
    @studentwork = Studentwork.new
    @assignment = Assignment.find(params[:assignment_id])
  end

  def show
    @studentwork = Studentwork.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
    @user = current_user
  end

  def create
    @studentwork = Studentwork.new(studentWork_params)
    @user = current_user
    @assignment = Assignment.find(params[:assignment_id])

    @studentwork.user_id = @user.id
    @studentwork.assignment_id = @assignment.id


    if @studentwork.save
      flash[:notice] = "studentWork created successfully"
      redirect_to assignment_studentwork_path(@assignment.id, @studentwork.id)
    else
      @form_errors = @studentwork.errors.full_messages
      render :new
    end
  end

  def edit
    @studentwork = Studentwork.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
  end

  def update
    @studentwork = Studentwork.new(studentWork_params)
    @user = current_user
    @assignment = Assignment.find(params[:assignment_id])

    @studentwork.user_id = @user.id
    @studentwork.assignment_id = @assignment.id

    if @studentwork.update(studentWork_params)
      redirect_to assignment_studentwork_path(@assignment.id, @studentwork.id)
    else
      @form_errors = @studentwork.errors.full_messages
      render :edit
    end
  end

  def destroy
    @studentwork = Studentwork.find(params[:id])
    @studentwork.destroy
    redirect_to studentWorks_path
  end

  def studentWork_params
    params.require(:studentwork).permit(:assignment, :work)
  end
end
