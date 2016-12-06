module ApiMe
  class Sorting
    attr_accessor :sort_criteria, :sort_reverse, :sort_association, :scope

    def initialize(scope:, sort_params:)
      self.scope = scope
      if sort_params
        self.sort_association = sort_params[:assoCriteria]
        self.sort_criteria = sort_params[:criteria] || default_sort_criteria
        self.sort_reverse = sort_params[:reverse]

        unless self.sort_association == ""
          relation_sorting(self.sort_criteria)
        end
      end
    end

    def results
      sorting? ? sort(sort_criteria) : scope
    end

    def sort_meta
      return Hash.new unless sorting?
      {
        criteria: sort_criteria.is_blank? || sort_criteria === "" ? default_sort_criteria : sort_criteria,
        reverse: sort_reverse,
        record_count: scope.size,
        total_records: scope.total_count,
      }
    end

    protected

    def sort(criteria = default_sort_criteria)
      unless sort_association == ""
        criteria_class = criteria.camelize.constantize

        if sort_reverse === "true"
          scope.joins(criteria.to_sym).merge(criteria_class.order(sort_association => :asc))
        else
          scope.joins(criteria.to_sym).merge(criteria_class.order(sort_association => :desc))
        end
      else
        if sort_reverse === "true"
          self.scope = scope.order(criteria => :asc)
        else
          self.scope = scope.order(criteria => :desc)
        end
      end
    end

    private

    def default_sort_criteria
      sort_criteria = "id"
    end

    def sorting?
      sort_criteria || sort_reverse
    end

    def relation_sorting(str)
      str.slice!(/_id/)
      return str
    end
  end
end
