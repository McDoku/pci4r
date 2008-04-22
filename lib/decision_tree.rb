module Math
  def self.logb(num, base)
    log(num) / log(base)
  end
end

module DecisionTree
  
  ##
  # A node in a decision tree.
  class Node
    # The index of the criteria to be tested
    attr_reader :column_index
    # The value a column must match to be true
    attr_reader :value
    # The +Node+ for the "true" value
    attr_reader :t_node
    # The +Node+ for the "false" value
    attr_reader :f_node
    # A <tt>Hash</tt> of results for this branch
    attr_reader :results

    def initialize(column_index, value, t_node, f_node, results)
      @column_index = column_index
      @value = value
      @t_node = t_node
      @f_node = f_node
      @results = results
    end
  end

  ##
  # Divides a the given set (+rows+) based on the given +column+ index
  # using the given +value+ as a pivot value. Splitting on numeric values
  # is done based on whether or not a value is greater than or equal to
  # the given value.  Otherwise, splitting is done on whether or not the
  # set value is equal to the splitting value.
  def self.divide(rows, column, value)
    splitter = case value.class
    when Numeric
      lambda { |x| x[column] >= value }
    else
      lambda { |x| x[column] == value }
    end

    set1 = rows.select { |r| splitter.call(r) }
    set2 = rows.select { |r| not splitter.call(r) }
    [set1, set2]
  end

  ##
  # Calculates the expected error rate if one of the results is randomly
  # applied to one of the items in the set.
  def self.gini_impurity(rows)
    total = rows.size
    counts = unique_counts(rows)
    impurity = 0
    counts.each do |value, count|
      p1 = count.to_f / total.to_f
      counts.each do |value2, count2|
        unless value2 == value
          p2 = count2.to_f / total.to_f
          impurity += p1 * p2
        end
      end
    end
    impurity
  end

  ##
  # Measures the amount of disorder in the given set.
  def self.entropy(rows)
    log2 = lambda { |x| Math.log10(x).to_f / Math.log10(2).to_f }
    results = unique_counts(rows)
    entropy = 0.0
    results.values.each do |v|
      p = v.to_f / rows.size.to_f
      entropy = entropy - p * Math.logb(p, 2).to_f
    end
    entropy
  end

  private

  # :nodoc:
  def self.unique_counts(rows)
    results = Hash.new { |h,k| h[k] = 0 }
    rows.each do |row|
      results[row.last] += 1
    end
    results
  end
end