#================
# Gradebook Pages
#================

# The topmost page in a Site's Gradebook
class Gradebook < BasePage

  frame_element

  def items_titles
    titles = []
    1.upto(items_table.rows.size-1) do |x|
      titles << items_table.row(:index=>x).a(:index=>0).text
    end
    return titles
  end

  # Returns the value of the "Released to Students" column
  # for the specified assignment title.
  def released_to_students(assignment)
    items_table.row(:text=>/#{Regexp.escape(assignment)}/)[4].text
  end

  # Returns the due date value for the specified assignment.
  def due_date(assignment)
    items_table.row(:text=>/#{Regexp.escape(assignment)}/)[3].text
  end

  # ==========
  private
  # ==========

  element(:items_table) { |b| b.frm.table(class: 'listHier lines nolines') }

end