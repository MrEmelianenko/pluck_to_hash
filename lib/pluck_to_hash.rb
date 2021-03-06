require_relative "./pluck_to_hash/version"

module PluckToHash
  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_to_hash(*keys)
      block_given = block_given?
      keys = column_names if keys.blank?
      formatted_keys = format_keys(keys)
      pluck(*keys).map do |row|
        row = [row] if keys.size == 1
        value = HashWithIndifferentAccess[formatted_keys.zip(row)]
        yield(value) if block_given
        value
      end
    end

    def pluck_to_struct(*keys)
      block_given = block_given?
      keys = column_names if keys.blank?
      formatted_keys = format_keys(keys)

      struct = Struct.new(*formatted_keys)
      pluck(*keys).map do |row|
        row = [row] if keys.size == 1
        value = struct.new(*row)
        yield(value) if block_given
        value
      end
    end

    def format_keys(keys)
      keys.map do |k|
        case k
        when String
          k.split(/ as /i)[-1].to_sym
        when Symbol
          k
        end
      end
    end

    alias_method :pluck_h, :pluck_to_hash
    alias_method :pluck_s, :pluck_to_struct
  end
end

ActiveRecord::Base.send(:include, PluckToHash)
