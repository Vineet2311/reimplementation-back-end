require 'swagger_helper'

RSpec.describe 'api/v1/questionnaires', type: :request do

  # GET on /questionnaires
  path '/api/v1/questionnaires' do
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
        run_test!
      end

      # response(400, 'invalid_request') do
      #   run_test!
      # end
    end
  end

  # GET on /questionnaires/:id
  path '/api/v1/questionnaires/{id}' do
    parameter name: 'id', in: :path, type: :integer
    get('show questionnaire') do
      produces 'application/json'
      response(200, 'successful') do
        let(:instructor_id) { 1 }
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
        let(:id) { create(:questionnaire).id }
        run_test!
      end

      response(404, 'not_found') do
        run_test!
      end
    end
  end

  # POST on /questionnaires
  path '/api/v1/questionnaires' do
    post('create questionnaire') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :questionnaire, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          questionnaire_type: { type: :string },
          private: { type: :boolean },
          min_question_score: { type: :integer },
          max_question_score: { type: :integer }
        },
        required: %w[name questionnaire_type]
      }

      response(201, 'created') do
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
    end
  end

end
