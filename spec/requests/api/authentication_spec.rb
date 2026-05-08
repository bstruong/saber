require "rails_helper"

RSpec.describe "API authentication", type: :request, auth: :real do
  it "returns 401 for unauthenticated requests" do
    get "/api/users/me"
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 for unauthenticated dashboard requests" do
    get "/api/dashboard/reconnect"
    expect(response).to have_http_status(:unauthorized)
  end

  it "signs in a valid user" do
    user = create(:user)

    post "/api/users/sign_in",
      params: { user: { email: user.email, password: "password123" } },
      as:     :json

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["user"]["email"]).to eq(user.email)
  end

  it "rejects invalid credentials" do
    post "/api/users/sign_in",
      params: { user: { email: "nobody@example.com", password: "wrong" } },
      as:     :json

    expect(response).to have_http_status(:unauthorized)
  end
end
