module NicoParser
  module NicoPlayerParser

    def self.parse_tag(info_file)
      tag_mode = false
      tags = []

      if File.exist?(info_file)
        File.open(info_file) {|file|
          file.binmode
          converted = NKF.nkf('-W16L -w', file.read)
          converted.each_line do |line|
            if line.chop.empty?
              tag_mode = false
            end

            if tag_mode == true
              tags << line.chop
            end

            if line.chop == "[tags]"
              tag_mode = true
            end
          end
        }
      end
      tags.map do |tag|
        CGI.unescapeHTML(tag)
      end
    end

    def self.parse_info(info_file)
      parse_mode = false
      info_set = {}
      info_key = ""

      if File.exist?(info_file)
        File.open(info_file) {|file|
          file.binmode
          converted = NKF.nkf('-W16L -w', file.read)
          converted.each_line do |line|
            if line.chomp.empty?
              parse_mode = false
            end

            if parse_mode == true
              if info_key == "view_counter" or info_key == "comment_num" or info_key == "mylist_counter"
                value = line.chomp.to_i
              else
                value = line.chomp
              end
              info_key = "nico_" + info_key
              info_set.merge!(info_key.to_sym => value)
            end

            if line.chomp =~ /\[(.*)\]/
              next if ($1 == "tags" or $1 == "title" or $1 == "comment")
              parse_mode = true
              info_key = $1
            end
          end
        }
      end
      info_set
    end

  end
end
