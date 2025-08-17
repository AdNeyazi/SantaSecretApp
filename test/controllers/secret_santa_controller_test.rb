require "test_helper"

class SecretSantaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get secret_santa_index_url
    assert_response :success
  end

  test "should get create_assignments" do
    get secret_santa_create_assignments_url
    assert_redirected_to secret_santa_index_path
  end

  test "should get upload_csv" do
    get secret_santa_upload_csv_url
    assert_response :success
  end

  test "should get download_csv" do
    get secret_santa_download_csv_url
    assert_response :success
  end
end
