require 'swagger_helper'

RSpec.describe 'api/v1/questions', type: :request do

  path '/api/v1/questions' do
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
    end

    let(:questionnaire1) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 1',
        questionnaire_type: 'AuthorFeedbackReview',
        private: true,
        min_question_score: 0,
        max_question_score: 10,
        instructor_id: instructor.id
      )
    end

    let(:question1) do
      questionnaire1
      Question.create(
        seq: 1, 
        txt: "test question 1", 
        question_type: "multiple_choice", 
        break_before: true, 
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire1
      Question.create(
        seq: 2, 
        txt: "test question 2", 
        question_type: "multiple_choice", 
        break_before: false, 
        questionnaire: questionnaire
      )
    end

    get('list questions') do
      produces 'application/json'
      response(200, 'successful') do
        run_test! do
          expect(response.body.size).to eq(2)
        end
      end
    end

  end
end