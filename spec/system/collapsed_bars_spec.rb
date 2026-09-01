# frozen_string_literal: true

RSpec.describe "Collapsed bars" do
  let!(:theme) do
    component = upload_theme_component
    component.update_setting(
      :bar_components,
      %w[left right right-alt top]
        .map do |position|
          {
            "component_name" => "bars-custom-html",
            "route" => "discovery",
            "position" => position,
            "params" => [
              { "name" => "content", "value" => "<div style='width: 600px'>#{position}</div>" },
            ],
          }
        end
        .to_json,
    )
    component.save!
    component
  end

  def rect(selector)
    find(selector).evaluate_script("this.getBoundingClientRect().toJSON()").transform_keys(&:to_sym)
  end

  def collapse(position)
    find(".bars-bar[data-position='#{position}'] .bars-bar__button.--toggle").click
  end

  it "returns collapsed bar space to adjacent content in every position" do
    visit "/latest"

    expanded_main = rect("#main-outlet")
    expanded_right = rect(".bars-bar[data-position='right']")
    collapse("right")
    collapsed_main = rect("#main-outlet")
    collapsed_right = rect(".bars-bar[data-position='right']")

    expect(collapsed_main[:width]).to be > expanded_main[:width]
    expect(collapsed_right[:width]).to be < expanded_right[:width]
    expect(collapsed_right[:left]).to be >= collapsed_main[:right]
    expect(
      find(".bars-bar[data-position='right'] .bars-bar__actions").evaluate_script(
        "getComputedStyle(this).flexDirection",
      ),
    ).to eq("column")

    expanded_list = rect("#list-area")
    expanded_right_alt = rect(".bars-bar[data-position='right-alt']")
    collapse("right-alt")
    collapsed_list = rect("#list-area")
    collapsed_right_alt = rect(".bars-bar[data-position='right-alt']")

    expect(collapsed_list[:width]).to be > expanded_list[:width]
    expect(collapsed_right_alt[:width]).to be < expanded_right_alt[:width]
    expect(collapsed_right_alt[:left]).to be >= collapsed_list[:right]
    expect(
      find(".bars-bar[data-position='right-alt'] .bars-bar__actions").evaluate_script(
        "getComputedStyle(this).flexDirection",
      ),
    ).to eq("column")

    expanded_main = rect("#main-outlet")
    expanded_left = rect(".bars-bar[data-position='left']")
    collapse("left")
    collapsed_main = rect("#main-outlet")
    collapsed_left = rect(".bars-bar[data-position='left']")

    expect(collapsed_main[:width]).to be > expanded_main[:width]
    expect(collapsed_left[:width]).to be < expanded_left[:width]
    expect(collapsed_left[:right]).to be <= collapsed_main[:left]
    expect(
      find(".bars-bar[data-position='left'] .bars-bar__actions").evaluate_script(
        "getComputedStyle(this).flexDirection",
      ),
    ).to eq("column")

    expanded_top = rect(".bars-bar[data-position='top']")
    collapse("top")
    collapsed_top = rect(".bars-bar[data-position='top']")

    expect(collapsed_top[:height]).to be < expanded_top[:height]
    expect(collapsed_top[:bottom]).to be < expanded_top[:bottom]
    expect(
      find(".bars-bar[data-position='top'] .bars-bar__actions").evaluate_script(
        "getComputedStyle(this).flexDirection",
      ),
    ).to eq("row")
  end
end
