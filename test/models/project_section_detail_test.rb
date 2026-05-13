require "test_helper"

class ProjectSectionDetailTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert project_section_details(:one).valid?
  end

  test "requires known section" do
    detail = projects(:one).project_section_details.build(
      section: "unknown",
      title: "不正なセクション",
      body: "保存しない"
    )

    assert_not detail.valid?
  end
end
