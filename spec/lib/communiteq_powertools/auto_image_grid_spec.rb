# frozen_string_literal: true

require "rails_helper"
require_relative "../../../lib/communiteq_powertools/auto_image_grid"

describe CommuniteqPowertools::AutoImageGrid do
  fab!(:user) { Fabricate(:user) }
  fab!(:image_upload_1) { Fabricate(:upload, user: user, extension: "png", original_filename: "one.png") }
  fab!(:image_upload_2) { Fabricate(:upload, user: user, extension: "jpg", original_filename: "two.jpg") }
  fab!(:image_upload_3) { Fabricate(:upload, user: user, extension: "webp", original_filename: "three.webp") }

  let(:img1) { "![one](#{image_upload_1.short_url})" }
  let(:img2) { "![two](#{image_upload_2.short_url})" }
  let(:img3) { "![three](#{image_upload_3.short_url})" }
  let(:non_image) { "![doc](upload://abc123fake.pdf)" }

  it "wraps consecutive image uploads with default min_images" do
    raw = <<~MD
      #{img1}

      #{img2}
    MD

    wrapped = described_class.wrap(raw)

    expect(wrapped).to include("[grid]")
    expect(wrapped).to include("[/grid]")
    expect(wrapped).to include(img1)
    expect(wrapped).to include(img2)
  end

  it "does not wrap if sequence length is below min_images" do
    raw = <<~MD
      #{img1}

      #{img2}
    MD

    wrapped = described_class.wrap(raw, min_images: 3)
    expect(wrapped).to eq(raw)
  end

  it "does not cross non-image uploads when grouping" do
    raw = <<~MD
      #{img1}

      #{non_image}

      #{img2}
    MD

    wrapped = described_class.wrap(raw)
    expect(wrapped).to eq(raw)
  end

  it "does not re-wrap content already inside grid blocks" do
    raw = <<~MD
      [grid]
      #{img1}

      #{img2}
      [/grid]
    MD

    wrapped = described_class.wrap(raw)
    expect(wrapped.scan("[grid]").length).to eq(1)
    expect(wrapped).to eq(raw)
  end

  it "supports multiple groups in one post" do
    raw = <<~MD
      #{img1}

      #{img2}

      Some text breaks grouping.

      #{img2}

      #{img3}
    MD

    wrapped = described_class.wrap(raw)
    expect(wrapped.scan("[grid]").length).to eq(2)
  end
end
