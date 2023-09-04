helpers do
  def user
    session['name'] || ''
  end

  def page_number
    (params['page_number'] || 1).to_i
  end

  def page_size
    5.0
  end

  def previous_pages(current_page)
    left_border = current_page - 2
    left_border = 1 if left_border < 1

    left_border
  end

  def future_pages(current_page, max_page)
    right_border = current_page + 2
    right_border = max_page if right_border > max_page

    right_border
  end
end
