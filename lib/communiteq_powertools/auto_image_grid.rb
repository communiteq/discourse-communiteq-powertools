# frozen_string_literal: true

module CommuniteqPowertools
  module AutoImageGrid
    GRID_BLOCK_REGEX = /(\[grid\][\s\S]*?\[\/grid\])/i
    IMAGE_UPLOAD_MARKDOWN_REGEX = /!\[[^\]]*\]\((?<url>upload:\/\/[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)?)\)/
    WHITESPACE_ONLY_REGEX = /\A\s*\z/

    def self.wrap(raw, min_images: 2)
      return raw if raw.blank?

      segments = raw.split(GRID_BLOCK_REGEX)

      segments.each_with_index.map { |segment, idx| idx.odd? ? segment : wrap_segment(segment, min_images) }.join
    end

    def self.wrap_segment(segment, min_images)
      matches = segment.to_enum(:scan, IMAGE_UPLOAD_MARKDOWN_REGEX).map { Regexp.last_match }
      return segment if matches.length < min_images

      image_url_map = image_url_map_for(matches)

      groups = []
      current_group = []

      matches.each do |match|
        if !image_url_map[match[:url]]
          groups << current_group if current_group.length >= min_images
          current_group = []
          next
        end

        if current_group.empty?
          current_group = [match]
          next
        end

        in_between = segment[current_group.last.end(0)...match.begin(0)]
        if in_between.match?(WHITESPACE_ONLY_REGEX)
          current_group << match
        else
          groups << current_group if current_group.length >= min_images
          current_group = [match]
        end
      end

      groups << current_group if current_group.length >= min_images
      return segment if groups.empty?

      wrapped = segment.dup

      groups.reverse_each do |group|
        start_idx = group.first.begin(0)
        end_idx = group.last.end(0)
        original_block = wrapped[start_idx...end_idx]
        replacement = "[grid]\n#{original_block}\n[/grid]"
        wrapped[start_idx...end_idx] = replacement
      end

      wrapped
    end

    def self.image_url_map_for(matches)
      urls = matches.map { |m| m[:url] }.uniq
      sha1s = urls.map { |url| Upload.sha1_from_short_url(url) }.compact
      uploads_by_sha1 = Upload.where(sha1: sha1s).index_by(&:sha1)

      urls.to_h do |url|
        sha1 = Upload.sha1_from_short_url(url)
        upload = uploads_by_sha1[sha1]
        [url, image_upload?(upload)]
      end
    end

    def self.image_upload?(upload)
      return false if upload.blank?

      filename = upload.original_filename.presence || "upload.#{upload.extension}"
      FileHelper.is_supported_image?(filename)
    end
  end
end