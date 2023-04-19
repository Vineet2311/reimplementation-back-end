class Api::V1::QuestionnairesController < ApplicationController
  
  # GET on /questionnaires
  def index
    begin
      @questionnaires = Questionnaire.order(:id)
      render json: @questionnaires, status: :ok and return
    rescue
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity and return
    end
  end
  
  # GET on /questionnaires/:id
  def show
    begin
      @questionnaire = Questionnaire.find(params[:id])
      render json: @questionnaire, status: :ok and return
    rescue
      render json: $ERROR_INFO.to_s, status: :not_found and return
    end
  end
  
  # POST on /questionnaires
  # Instructor Id statically defined since implementation of Instructor model is out of scope of E2345.
  def create
    if params[:name].blank?
      render json: "Questionnaire name cannot be blank.", status: :unprocessable_entity and return
    end
    begin
      @questionnaire = Questionnaire.new(questionnaire_params)
      @questionnaire.display_type = sanitize_display_type(@questionnaire.questionnaire_type)
      @questionnaire.save!
      render json: @questionnaire, status: :created and return
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity and return
    end
  end

  # DELETE on /questionnaires/:id
  def destroy
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.delete
    rescue
      render json: $ERROR_INFO.to_s, status: :not_found and return
    end
  end

  # PUT on /questionnaires/:id
  def update
    # Save questionnaire information
    begin
      @questionnaire = Questionnaire.find(params[:id])
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :not_found and return
    end
    begin
      @questionnaire.update(questionnaire_params)
      @questionnaire.save!
      render json: @questionnaire, status: :ok and return
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity and return
    end
  end

  # POST on /questionnaires/copy/:id
  def copy
    @questionnaire = Questionnaire.copy_questionnaire_details(params)
    render json: "Copy of the questionnaire has been created successfully.", status: :ok and return
  rescue StandardError
    render json: $ERROR_INFO.to_s, status: :not_found and return
  end

  # GET on /questionnaires/toggle_access/:id
  def toggle_access
    begin
      @questionnaire = Questionnaire.find(params[:id])
      @questionnaire.private = !@questionnaire.private
      @questionnaire.save!
      @access = @questionnaire.private == true ? 'private' : 'public'
      render json: "The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ", status: :ok and return
    rescue StandardError
      render json: $ERROR_INFO.to_s, status: :not_found and return
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :questionnaire_type, :private, :min_question_score, :max_question_score, :instructor_id)
  end

  def sanitize_display_type(type)
    display_type = type.split('Questionnaire')[0]
    if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
      display_type = (display_type.split(/(?=[A-Z])/)).join('%')
    end
    display_type
  end

end
