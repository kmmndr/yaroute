class PositionHandler
  attr_reader :scope, :element

  def initialize(scope:, element:)
    @scope = scope
    @element = element
  end

  def move!(direction = :up)
    ids = scope.ids
    idx = ids.index(element.id)

    case direction
    when :up
      if idx > 0
        previous = ids[idx - 1]
        value = ids[idx]

        ids[idx] = previous
        ids[idx - 1] = value
      end
    when :down
      if idx < ids.count - 1
        previous = ids[idx + 1]
        value = ids[idx]

        ids[idx] = previous
        ids[idx + 1] = value
      end
    end

    ActiveRecord::Base.transaction do
      ids.each.with_index do |id, idx|
        element.class.find(id).update(position: idx)
      end
    end
  end
end
