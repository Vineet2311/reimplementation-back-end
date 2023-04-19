require 'swagger_helper'

RSpec.describe 'api/v1/questionnaires', type: :request do

  # GET on /questionnaires
  path '/api/v1/questionnaires' do
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

    let(:questionnaire2) do
      instructor
      Questionnaire.create(
        name: 'Questionnaire 2',
        questionnaire_type: 'AuthorFeedbackReview',
        private: false,
        min_question_score: 0,
        max_question_score: 5,
        instructor_id: instructor.id
      )
    end

    get('list questionnaires') do
      produces 'application/json'
      response(200, 'successful') do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              questionnaire_type: { type: :string },
              private: { type: :boolean },
              min_question_score: { type: :integer },
              max_question_score: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' },
              instructor_id: { type: :integer }
            },
            required: %w[id name questionnaire_type private min_question_score max_question_score created_at updated_at instructor_id]
          }
        run_test! do
          expect(response.body.size).to eq(2)
        end
      end
    end

    post('create questionnaire') do

      let(:valid_questionnaire_params) do
        {
          name: 'Test Questionnaire',
          questionnaire_type: 'AuthorFeedbackReview',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          instructor_id: instructor.id
        }
      end

      let(:invalid_questionnaire_params) do
        {
          name: nil, # invalid name
          questionnaire_type: 'AuthorFeedbackReview',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          instructor_id: instructor.id
        }
      end

      consumes 'application/json'
      produces 'application/json'
      parameter name: :questionnaire, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          questionnaire_type: { type: :string },
          private: { type: :boolean },
          min_question_score: { type: :integer },
          max_question_score: { type: :integer },
          instructor_id: { type: :integer}
        },
        required: %w[id name questionnaire_type private min_question_score max_question_score instructor_id]
      }
  
      response(201, 'created') do
        let(:questionnaire) do
          instructor
          Questionnaire.create(valid_questionnaire_params)
        end
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            questionnaire_type: { type: :string },
            private: { type: :boolean },
            min_question_score: { type: :integer },
            max_question_score: { type: :integer },
            created_at: { type: :datetime },
            updated_at: { type: :datetime },
            instructor_id: { type: :integer }
          },
          required: %w[id name questionnaire_type private min_question_score max_question_score created_at updated_at instructor_id]
        run_test! do
          expect(response.body).to include('"name":"Test Questionnaire"')
        end
      end

      response(422, 'unprocessable entity') do
        let(:questionnaire) do
          instructor
          Questionnaire.create(invalid_questionnaire_params)
        end
        run_test!
      end
    end

  end

  path '/api/v1/questionnaires/{id}' do
    parameter name: 'id', in: :path, type: :integer
      let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
      let(:instructor) do 
        role
        Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
      end

      let(:valid_questionnaire_params) do
        {
          name: 'Test Questionnaire',
          questionnaire_type: 'AuthorFeedbackReview',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          instructor_id: instructor.id
        }
      end

      let(:questionnaire) do
        instructor
        Questionnaire.create(valid_questionnaire_params)
      end

      let(:id) do
        questionnaire
        questionnaire.id 
      end

    get('show questionnaire') do
      produces 'application/json'
      response(200, 'successful') do
        schema type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                questionnaire_type: { type: :string },
                private: { type: :boolean },
                min_question_score: { type: :integer },
                max_question_score: { type: :integer },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                instructor_id: { type: :integer }
              },
              required: %w[id name questionnaire_type private min_question_score max_question_score created_at updated_at instructor_id]
        run_test! 
      end

      response(404, 'not_found') do
        let(:id) { 'invalid' }
          run_test! do
            expect(response.body).to include("Couldn't find Questionnaire")
          end
      end
    end

    put('update questionnaire') do
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          min_question_score: { type: :integer }
        }
      }
      
      response(200, 'successful') do
        let(:body_params) do
          {
            min_question_score: 1
          }
        end
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            questionnaire_type: { type: :string },
            private: { type: :boolean },
            min_question_score: { type: :integer },
            max_question_score: { type: :integer },
            created_at: { type: :datetime },
            updated_at: { type: :datetime },
            instructor_id: { type: :integer }
          },
          required: %w[id name questionnaire_type private min_question_score max_question_score created_at updated_at instructor_id]
        run_test! do
          expect(response.body).to include('"min_question_score":1')
        end
      end

      response(404, 'not found') do
        let(:id) { 0 }
        let(:body_params) do
          {
            min_question_score: 0
          }
        end
        run_test! do
          expect(response.body).to include("Couldn't find Questionnaire")
        end
      end

      response(422, 'unprocessable entity') do
        let(:body_params) do
          {
            min_question_score: -1
          }
        end
        schema type: :string
        run_test! do
          expect(response.body).to_not include('"min_question_score":-1')
        end
      end  
    end

    delete('delete questionnaire') do
      produces 'application/json'
      response(204, 'successful') do
        run_test! do
          expect(Questionnaire.exists?(id)).to eq(false)
        end
      end

      response(404, 'not found') do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/v1/questionnaires/toggle_access/{id}' do
    parameter name: 'id', in: :path, type: :integer
      let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
      let(:instructor) do 
        role
        Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
      end

      let(:valid_questionnaire_params) do
        {
          name: 'Test Questionnaire',
          questionnaire_type: 'AuthorFeedbackReview',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          instructor_id: instructor.id
        }
      end

      let(:questionnaire) do
        instructor
        Questionnaire.create(valid_questionnaire_params)
      end

      let(:id) do
        questionnaire
        questionnaire.id 
      end

      get('toggle access') do
        produces 'application/json'
        response(200, 'successful') do
          run_test! do 
            expect(response.body).to include(" has been successfully made private. ")
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

  path '/api/v1/questionnaires/copy/{id}' do
    parameter name: 'id', in: :path, type: :integer
      let(:role) { Role.create(name: 'Instructor', parent_id: nil, default_page_id: nil) }
      let(:instructor) do 
        role
        Instructor.create(name: 'testinstructor', email: 'test@test.com', fullname: 'Test Instructor', password: '123456', role: role) 
      end

      let(:valid_questionnaire_params) do
        {
          name: 'Test Questionnaire',
          questionnaire_type: 'AuthorFeedbackReview',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          instructor_id: instructor.id
        }
      end

      let(:questionnaire) do
        instructor
        Questionnaire.create(valid_questionnaire_params)
      end

      let(:id) do
        questionnaire
        questionnaire.id 
      end

      post('copy questionnaire') do
        
      end
  end
end
