class Api::V1::DocumentsController < Api::V1::BaseController
  acts_as_token_authentication_handler_for User, except: [ :index, :show ]
  before_action :set_document, only: [:show]

  def index
    @documents = policy_scope(Document)
  end

  def show
  end

  def create
    url = "https://sandbox.clicksign.com/api/v1/documents?access_token=#{ENV['CLICKSIGN_KEY'].to_s}"
    body =   {
                "document": {
                  "path": params[:filename],
                  "content_base64": params[:base64],
                  "deadline_at": "2018-12-25T14:30:59-03:00",
                  "auto_close": true,
                  "locale": "pt-BR",
                  "signers": [
                    {
                      "email": params[:client_email],
                      "sign_as": "sign",
                      "auths": [
                        "email"
                      ],
                      "name": params[:client_name],
                      "documentation": "123.321.123-40",
                      "birthday": "1983-03-31",
                      "has_documentation": true,
                      "send_email": true,
                      "message": "Olá, por favor assine o documento."
                    }
                  ]
                }
              }.to_json


    headers = {:Content_Type => "application/json", :Accept => "application/json"}
    response = RestClient.post(url, body, headers)
    # @document = Document.new(document_params)
    # @document.user = current_user
    # authorize @document

    # if @document.save
    #   render :show, status: :created
    # else
    #   render_error
    # end
  end

  private

  def document_params
    params.require(:document).permit(:key, :filename, :status)
  end

  def set_document
    @document = Document.find(params[:id])
    authorize @document # For Pundit
  end

  def render_error
    render json: { errors: @document.errors.full_messages },
      status: :unprocessable_entity
  end

end
