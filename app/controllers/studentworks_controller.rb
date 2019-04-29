# studentworks_controller.rb - controller for handling CRUD actions for studentworks
# all studentworks are nested inside in an assignment

class StudentworksController < ApplicationController
  # form for new studentwork
  def new
    @studentwork = Studentwork.new
    @assignment = Assignment.find(params[:assignment_id])
  end

  def show
    @studentwork = Studentwork.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
    @user = current_user
  end
# handles submission of the new form
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

# populates the edit form
  def edit
    @studentwork = Studentwork.find(params[:id])
    @assignment = Assignment.find(params[:assignment_id])
  end
# handles for submission of the edit form
  def update
    @studentwork = Studentwork.find(params[:id])
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

  # method for handling params passed from forms for CRUD actions
  def studentWork_params
    params.require(:studentwork).permit(:assignment, :work)
  end
end
