require 'swagger_helper'

RSpec.describe 'api/v1/questions', type: :request do

  path '/api/v1/questions' do
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
    end

    let(:questionnaire) do
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
      questionnaire
      Question.create(
        seq: 1, 
        txt: "test question 1", 
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Question.create(
        seq: 2, 
        txt: "test question 2", 
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
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

    post('create question') do
      consumes 'application/json'
      produces 'application/json'
      
      let(:valid_question_params) do
        {
          questionnaire_id: questionnaire.id,
          txt: "test question", 
          question_type: "multiple_choice", 
          break_before: false,
          weight: 10
        }
      end

      let(:invalid_question_params1) do
        {
          questionnaire_id: nil ,
          txt: "test question", 
          question_type: "multiple_choice", 
          break_before: false,
          weight: 10
        }
      end

      let(:invalid_question_params2) do
        {
          questionnaire_id: questionnaire.id ,
          txt: "test question", 
          question_type: nil, 
          break_before: false,
          weight: 10
        }
      end

      parameter name: :question, in: :body, schema: {
        type: :object,
        properties: {
          weight: { type: :integer },
          questionnaire_id: { type: :integer },
          break_before: { type: :boolean },
          txt: { type: :string },
          question_type: { type: :string },
        },
        required: %w[weight questionnaire_id break_before txt question_type]      
      }

      response(201, 'created') do
        let(:question) do
          questionnaire
          Question.create(valid_question_params)
        end
        run_test! do
          expect(response.body).to include('"seq":1')
        end
      end

      response(404, 'questionnaire id not found') do
        let(:question) do
          instructor
          Question.create(invalid_question_params1)
        end
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:question) do
          instructor
          Question.create(invalid_question_params2)
        end
        run_test!
      end

    end

  end

  path '/api/v1/questions/{id}' do

    parameter name: 'id', in: :path, type: :integer
    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
    end

    let(:questionnaire) do
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
      questionnaire
      Question.create(
        seq: 1, 
        txt: "test question 1", 
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire: questionnaire
      )
    end

    let(:question2) do
      questionnaire
      Question.create(
        seq: 2, 
        txt: "test question 2", 
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire: questionnaire
      )
    end

    
    let(:id) do
      questionnaire
      question1
      question1.id 
    end



    get('show question') do
      tags 'Questions'
      produces 'application/json'
      response(200, 'successful') do
        run_test! do
          expect(response.body).to include('"txt":"test question 1"') 
        end
      end

      response(404, 'not_found') do
        let(:id) { 'invalid' }
          run_test! do
            expect(response.body).to include("Couldn't find Question")
          end
      end
    end

    put('update question') do
      
      tags 'Questions'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          break_before: { type: :boolean },
          seq: { type: :integer }
        }
      }
      
      response(200, 'successful') do
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include('"break_before":true')
        end
      end

      response(404, 'not found') do
        let(:id) { 0 }
        let(:body_params) do
          {
            break_before: true
          }
        end
        run_test! do
          expect(response.body).to include("Couldn't find Question")
        end
      end

      response(422, 'unprocessable entity') do
        let(:body_params) do
          {
            seq: "Dfsd"
          }
        end
        schema type: :string
        run_test! do
          expect(response.body).to_not include('"seq":"Dfsd"')
        end
      end  


    end


    delete('delete question') do

      tags 'Questions'
      produces 'application/json'
      
      response(200, 'successful') do
        run_test! do
          expect(Question.exists?(id)).to eq(false)
        end
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test! do
          expect(response.body).to include("Couldn't find Question")
        end
      end
    end

  end

  path '/api/v1/questions/delete_all/{id}' do
    parameter name: 'id', in: :path, type: :integer

    let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
    
    let(:instructor) do 
      role
      Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
    end

    let(:questionnaire) do
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
      questionnaire
      Question.create(
        seq: 1, 
        txt: "test question 1", 
        question_type: "multiple_choice", 
        break_before: true, 
        weight: 5,
        questionnaire_id: questionnaire.id
      )
    end

    let(:question2) do
      questionnaire
      Question.create(
        seq: 2, 
        txt: "test question 2", 
        question_type: "multiple_choice", 
        break_before: false, 
        weight: 10,
        questionnaire_id: questionnaire.id
      )
    end

    
    let(:id) do
      questionnaire
      question1
      question2
      questionnaire.id 
    end

    delete('delete all questions') do
      tags 'Questionnaires'
      produces 'application/json'
      response(204, 'successful') do
        run_test! do
          puts(response.body)
          #expect(question1.exists?(id)).to eq(false)
          #expect(Question.where(questionnaire_id: id)).to eq(0)
        end
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test! do
          expect(response.body).to include("Couldn't find Questionnaire")
        end
      end
    end


  end
end